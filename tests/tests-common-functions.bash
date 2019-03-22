#!/usr/bin/env bash

SRCDIR=`pwd`/..
WORKDIR="${BATS_TMPDIR}/release-test-$(date '+%Y-%m-%d_%H-%M-%S')"
LOCALREPO=${WORKDIR}/localrepo
REMOTEREPO=${WORKDIR}/remoterepo

init_repo() {
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
	git add release-scripts .release-scripts-hooks.sh
	git commit -m "register release-scripts"
	echo "no version set" > version.txt
	git add version.txt
  git commit -m "set version number $(echo $1)" version.txt
	git push -u origin master develop
}

remove_workdir() {
	cd ..
	[[ -d "${WORKDIR}" ]] && rm -fr "${WORKDIR}"
}
