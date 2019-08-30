#!/usr/bin/env bats

load tests-common-functions

setup() {
  init_repo
}

teardown() {
	remove_workdir
}

@test "run release script from develop without snapshot" {
	git checkout develop
	echo "some work" >> somefile
	git add somefile
	git commit -m "Do some work"
	./release-scripts/release.sh --no-snapshots 23.1
	git push --atomic origin master develop --follow-tags

	git checkout develop
	[[ "$(cat version.txt)" == "23.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

  git checkout v23.1
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect release version"
	cat somefile | grep "some work" > /dev/null
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

  git checkout master
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect master version"
	cat somefile | grep "some work" > /dev/null
  [[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

	git checkout release-23.1
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect version in release-23.1"
	cat somefile | grep "some work" > /dev/null
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]
}

@test "run hotfix from develop without snapshot" {
	./release-scripts/release.sh --no-snapshots 23.1
	git push --atomic origin master develop --follow-tags

	# ------------------------- START HOTFIX -------------------------

	./release-scripts/hotfix_start.sh --no-snapshots 23.1.1
  git push --set-upstream origin hotfix-23.1.1

  [[ "$(cat version.txt)" == "23.1.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Start hotfix 23.1.1" ]]

	echo "some fix" >> somefile
	git add somefile
	git commit -m "make some fix"

	git checkout develop
	[[ "$(cat version.txt)" == "23.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

  git checkout v23.1
	[[ "$(cat version.txt)" == "23.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

  git checkout master
	[[ "$(cat version.txt)" == "23.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "[TEST] Prepare release 23.1" ]]

  # ------------------------- FINISH HOTFIX -------------------------

	git checkout hotfix-23.1.1
	./release-scripts/hotfix_finish.sh --no-snapshots 23.1.1
	git push --atomic origin master develop hotfix-23.1.1 --follow-tags

	git checkout develop
	[[ "$(cat version.txt)" == "23.1.1" ]]
	cat somefile | grep "some fix"
	[[ "$(git log -1 --pretty=%B)" == "make some fix" ]]

  git checkout v23.1.1
	[[ "$(cat version.txt)" == "23.1.1" ]]
	[[ "$(git log -1 --pretty=%B)" == "make some fix" ]]

  git checkout master
	[[ "$(cat version.txt)" == "23.1.1" ]]
	cat somefile | grep "some fix"
	[[ "$(git log -1 --pretty=%B)" == "make some fix" ]]
}
