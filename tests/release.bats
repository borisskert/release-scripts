#!/usr/bin/env bats
#
SRCDIR=`pwd`/..
WORKDIR="${BATS_TMPDIR}/release-test-$(date '+%Y-%m-%d_%H-%M-%S')"
LOCALREPO=${WORKDIR}/localrepo
REMOTEREPO=${WORKDIR}/remoterepo

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
	cp ${BATS_TEST_DIRNAME}/test-hooks.sh .release-scripts-hooks.sh
	git add release-scripts
	git commit -m "register release-scripts"
	git push -u origin master develop
}

teardown() {
	cd ..
	[[ -d "${WORKDIR}" ]] && rm -fr "${WORKDIR}"
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


