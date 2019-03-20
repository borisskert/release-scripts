#!/usr/bin/env bats

load tests-common-functions

setup() {
  init_repo
}

teardown() {
	remove_workdir
}

@test "run release script from develop" {
	git checkout develop
	echo "some work" >> somefile
	git add somefile
	git commit -m "Do some work"
	./release-scripts/release.sh 23.1 23.2
	git push --atomic origin master develop --follow-tags

	git checkout develop
	[[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]] || cat version.txt "Incorrect next snapshot version"

  git checkout v23.1
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect release version"
	cat somefile | grep "some work" > /dev/null

  git checkout master
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect master version"
	cat somefile | grep "some work" > /dev/null

	git checkout release-23.1
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect version in release-23.1"
	cat somefile | grep "some work" > /dev/null
}

@test "run hotfix from develop" {
	./release-scripts/release.sh 23.1 23.2
	git push --atomic origin master develop --follow-tags
	./release-scripts/hotfix_start.sh 23.1.1
    git push --set-upstream origin hotfix-23.1.1

	echo "some fix" >> somefile
	git add somefile
	git commit -m "make some fix"

	[[ "$(cat version.txt)" == "23.1.1-SNAPSHOT" ]] || cat version.txt "Incorrect hotfix branch version"

	git checkout develop
	[[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]] || cat version.txt "Incorrect next snapshot version"

    git checkout v23.1
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect release version"

    git checkout master
	[[ "$(cat version.txt)" == "23.1" ]] || cat version.txt "Incorrect master version"

	git checkout hotfix-23.1.1
	./release-scripts/hotfix_finish.sh 23.1.1 23.2
	git push --atomic origin master develop hotfix-23.1.1 --follow-tags

	git checkout develop
	[[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]] || cat version.txt "Incorrect next snapshot version"
	cat somefile | grep "some fix"

    git checkout master
	[[ "$(cat version.txt)" == "23.1.1" ]] || cat version.txt "Incorrect master version"
	cat somefile | grep "some fix"
}


