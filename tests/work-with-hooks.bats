#!/usr/bin/env bats

load tests-common-functions

setup() {
  init_repo

  # Setup support branches (those are coded in test-hooks.sh)
  git checkout -b support-12.x
  echo "some support-12 work" >> somefile
  git add somefile
  git commit -m "add support-12 work"
  git checkout -b master-12.x
  git checkout develop
  echo "some next develop work" >> somefile
  git add somefile
  git commit -m "add next develop work"
  git push -u origin support-12.x master-12.x
}

teardown() {
	remove_workdir
}

@test "release: release version is used to get develop/master branch name" {
  git checkout support-12.x
  ./release-scripts/release.sh 12.3 12.4

  # Release is done from support-12.x branch to master-12.x branch
  git checkout v12.3
	[[ "$(cat version.txt)" == "12.3" ]] || cat version.txt "Incorrect release tag version"
	cat somefile | grep "some support-12 work" > /dev/null
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 12.3" ]] || cat version.txt "Incorrect commit message"

	git checkout master-12.x
	[[ "$(cat version.txt)" == "12.3" ]] || cat version.txt "Incorrect master-12.x version"
	cat somefile | grep "some support-12 work" > /dev/null
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 12.3" ]] || cat version.txt "Incorrect commit message"

	git checkout master
	# Since master never ever got released before, there should be no file version.txt
	[[ ! -f version.txt ]] || cat version.txt "Incorrect master version"
	! cat somefile | grep 'some support-12 work'
	[[ "$(git log -1 --pretty=%B)" == "add somefile" ]] || cat version.txt "Incorrect commit message"

  git checkout develop
  ./release-scripts/release.sh 23.1 23.2

  # If we get here then we didn't asked to checkout some another branch, so it's ok
}

@test "revert release: release version is used to get develop/master branch name" {
  git checkout support-12.x
  ./release-scripts/release.sh 12.3 12.4

  # Release is done from support-12.x branch to master-12.x branch
  git checkout v12.3
	[[ "$(cat version.txt)" == "12.3" ]] || cat version.txt "Incorrect release tag version"
	cat somefile | grep "some support-12 work" > /dev/null

	git checkout master-12.x
	[[ "$(cat version.txt)" == "12.3" ]] || cat version.txt "Incorrect master-12.x version"
	cat somefile | grep "some support-12 work" > /dev/null

	git checkout master
	# Since master never ever got released before, there should be no file version.txt
	[[ ! -f version.txt ]] || cat version.txt "Incorrect master version"
	! cat somefile | grep 'some support-12 work'

  git checkout support-12.x
  ./release-scripts/revert_release.sh 12.3 --iknowwhatimdoing

  # If we get here then we didn't asked to checkout some another branch, so it's ok
}

@test "hotfix_start: release version is used to get develop/master branch name" {
  ## GIVEN
  git checkout support-12.x
  ./release-scripts/release.sh 12.3 12.4

  git checkout develop
  ./release-scripts/release.sh 23.1 23.2

  # Now in master version 23.1 and in master-12.x version 12.3

  ## WHEN
  ./release-scripts/hotfix_start.sh 12.3.1
  git checkout hotfix-12.3.1

  # THEN
	cat somefile | grep "some support-12 work" > /dev/null
}

@test "hotfix_finish: release version is used to get develop/master branch name" {
  ## GIVEN
  git checkout support-12.x
  ./release-scripts/release.sh 12.3 12.4

  git checkout develop
  ./release-scripts/release.sh 23.1 23.2

  # Now in master version 23.1 and in master-12.x version 12.3

  ./release-scripts/hotfix_start.sh 12.3.1
  git checkout hotfix-12.3.1

  # WHEN

  echo "Some hotfix 12 work" >>somefile
  git add somefile
  git commit -m "Add some hotfix work"
  git push -u origin hotfix-12.3.1

  ./release-scripts/hotfix_finish.sh 12.3.1 12.4

  # THEN
  git checkout v12.3.1
	cat somefile | grep "Some hotfix 12 work" > /dev/null

  git checkout master-12.x
	cat somefile | grep "Some hotfix 12 work" > /dev/null

  git checkout support-12.x
	cat somefile | grep "Some hotfix 12 work" > /dev/null

	git checkout master
	! cat somefile | grep "Some hotfix 12 work" > /dev/null

	git checkout develop
	! cat somefile | grep "Some hotfix 12 work" > /dev/null
}
