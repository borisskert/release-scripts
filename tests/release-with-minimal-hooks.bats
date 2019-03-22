#!/usr/bin/env bats

load tests-common-functions

setup() {
	mkdir -p "${LOCALREPO}" "${REMOTEREPO}"
	cd "${REMOTEREPO}" && git init --bare
	git clone "${REMOTEREPO}" "${LOCALREPO}"
	cd "${LOCALREPO}"
	echo "somedata" > somefile
	git add somefile
	git commit -m "add somefile"
	git checkout -b develop
	mkdir release-scripts
  find ${SRCDIR} -maxdepth 1 -type f -exec cp -a {} ./release-scripts \;
	cp ${BATS_TEST_DIRNAME}/minimal-hooks.sh .release-scripts-hooks.sh
	git add release-scripts .release-scripts-hooks.sh
	git commit -m "register release-scripts"
	echo "no version set" > version.txt
	git add version.txt
  git commit -m "set version number $(echo $1)" version.txt
	git push -u origin master develop
}

teardown() {
	remove_workdir
}

@test "run release script from develop with minimal hooks" {
	git checkout develop
	echo "some work" >> somefile
	git add somefile
	git commit -m "Do some work"
	./release-scripts/release.sh 23.1 23.2
	git push --atomic origin master develop --follow-tags

	git checkout develop
	[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]
	[ "$(git log -1 --pretty=%B)" == "Start next iteration with 23.2-SNAPSHOT" ]

  git checkout v23.1
	[ "$(cat version.txt)" == "23.1" ]
	cat somefile | grep "some work" > /dev/null
	[ "$(git log -1 --pretty=%B)" == "Prepare release 23.1" ]

  git checkout master
	[ "$(cat version.txt)" == "23.1" ]
	cat somefile | grep "some work" > /dev/null
  [ "$(git log -1 --pretty=%B)" == "Prepare release 23.1" ]

	git checkout release-23.1
	[ "$(cat version.txt)" == "23.1" ]
	cat somefile | grep "some work" > /dev/null
	[ "$(git log -1 --pretty=%B)" == "Prepare release 23.1" ]
}

@test "run hotfix from develop  with minimal hooks" {
	./release-scripts/release.sh 23.1 23.2
	git push --atomic origin master develop --follow-tags

	# ------------------------- START HOTFIX -------------------------

	./release-scripts/hotfix_start.sh 23.1.1
  git push --set-upstream origin hotfix-23.1.1

  [ "$(cat version.txt)" == "23.1.1-SNAPSHOT" ]
	[ "$(git log -1 --pretty=%B)" == "Start hotfix 23.1.1-SNAPSHOT" ]

	echo "some fix" >> somefile
	git add somefile
	git commit -m "make some fix"

	git checkout develop
	[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]
	[ "$(git log -1 --pretty=%B)" == "Start next iteration with 23.2-SNAPSHOT" ]

  git checkout v23.1
	[ "$(cat version.txt)" == "23.1" ]
	[ "$(git log -1 --pretty=%B)" == "Prepare release 23.1" ]

  git checkout master
	[ "$(cat version.txt)" == "23.1" ]
	[ "$(git log -1 --pretty=%B)" == "Prepare release 23.1" ]

  # ------------------------- FINISH HOTFIX -------------------------

	git checkout hotfix-23.1.1
	./release-scripts/hotfix_finish.sh 23.1.1 23.2
	git push --atomic origin master develop hotfix-23.1.1 --follow-tags

	git checkout develop
	[ "$(cat version.txt)" == "23.2-SNAPSHOT" ]
	cat somefile | grep "some fix"
	[ "$(git log -1 --pretty=%B)" == "Merge branch 'hotfix-23.1.1' into develop" ]

  git checkout v23.1.1
	[ "$(cat version.txt)" == "23.1.1" ]
	[ "$(git log -1 --pretty=%B)" == "Release hotfix 23.1.1" ]

  git checkout master
	[ "$(cat version.txt)" == "23.1.1" ]
	cat somefile | grep "some fix"
	[ "$(git log -1 --pretty=%B)" == "Release hotfix 23.1.1" ]
}


