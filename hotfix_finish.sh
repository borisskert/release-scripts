#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -f "${SCRIPT_PATH}/.version.sh" ]]
then
  # shellcheck source=./.version.sh
	source "${SCRIPT_PATH}/.version.sh"
else
	VERSION="UNKNOWN VERSION"
fi

# shellcheck source=.parse-arguments.sh
source "${SCRIPT_PATH}/.parse-arguments.sh"

if [[ "${SNAPSHOTS}" = true && $# -ne 2 ]]
then
  echo 'Usage: hotfix_finish.sh <hotfix-version> ( <next-snapshot-version> | --without-snapshot )'
  echo 'For example: hotfix_finish.sh 0.2.1 0.3.0'
  echo 'or in case you dont want snapshot-versions: hotfix_finish.sh 0.2.1 --without-snapshot'
  exit 2
fi

if [[ "${VERBOSE}" = true ]]
then
  OUT=/dev/stdout
else
  OUT=/dev/null
fi

HOTFIX_VERSION=$1

if [[ "${SNAPSHOTS}" = true ]]
then
  NEXT_VERSION=$2
fi

# Necessary to calculate develop/master branch name
RELEASE_VERSION=${HOTFIX_VERSION}

if [ -f "${SCRIPT_PATH}/.common-util.sh" ]; then
	# shellcheck source=.common-util.sh
	source "${SCRIPT_PATH}/.common-util.sh" >> ${OUT}
else
	echo 'Missing file .common-util.sh. Aborting'
	exit 1
fi

print_message "Release scripts (hotfix-finish, version: ${VERSION})"

unset RELEASE_VERSION

HOTFIX_BRANCH=$(format_hotfix_branch_name "${HOTFIX_VERSION}")

if [ ! "${HOTFIX_BRANCH}" = "${CURRENT_BRANCH}" ]
then
  echo "Please checkout the branch '$HOTFIX_BRANCH' before processing this hotfix release."
  exit 1
fi

if ! is_workspace_clean
then
  echo "This script is only safe when your have a clean workspace."
  echo "Please clean your workspace by stashing or committing and pushing changes before processing this script."
  exit 1
fi

git checkout --quiet "${HOTFIX_BRANCH}"
git pull --quiet "${REMOTE_REPO}"

build_snapshot_modules >> ${OUT}
cd "${GIT_REPO_DIR}"
git reset --quiet --hard

set_modules_version "${HOTFIX_VERSION}" >> ${OUT}
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit hotfix versions
  HOTFIX_RELEASE_COMMIT_MESSAGE=$(get_release_hotfix_commit_message "${HOTFIX_VERSION}")
  git commit --quiet -am "${HOTFIX_RELEASE_COMMIT_MESSAGE}"
else
  print_message "Nothing to commit..."
fi

build_release_modules >> ${OUT}
cd "${GIT_REPO_DIR}"
git reset --quiet --hard

# merge current hotfix into master
git checkout --quiet "${MASTER_BRANCH}"
git pull --quiet "${REMOTE_REPO}"
git merge --quiet --no-edit "${HOTFIX_BRANCH}"

# create release tag
HOTFIX_TAG=$(format_release_tag "${HOTFIX_VERSION}")
HOTFIX_TAG_MESSAGE=$(get_hotfix_relesae_tag_message "${HOTFIX_VERSION}")
git tag -a "${HOTFIX_TAG}" -m "${HOTFIX_TAG_MESSAGE}"

git checkout --quiet "${HOTFIX_BRANCH}"

# prepare next snapshot version if necessary
if [[ "${SNAPSHOTS}" = "true" ]]
then
  NEXT_SNAPSHOT_VERSION=$(format_snapshot_version "${NEXT_VERSION}")
  set_modules_version "${NEXT_SNAPSHOT_VERSION}" >> ${OUT}
fi

cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit next snapshot versions
  SNAPSHOT_AFTER_HOTFIX_COMMIT_MESSAGE=$(get_next_snapshot_commit_message_after_hotfix "${NEXT_SNAPSHOT_VERSION}" "${HOTFIX_VERSION}")
  git commit --quiet -am "${SNAPSHOT_AFTER_HOTFIX_COMMIT_MESSAGE}"
else
  print_message "Nothing to commit..."
fi

# merge next snapshot version into develop
git checkout --quiet "${DEVELOP_BRANCH}"

if git merge --quiet --no-edit "${HOTFIX_BRANCH}"
then
  print_message "# Okay, now you've got a new tag and commits on ${MASTER_BRANCH} and ${DEVELOP_BRANCH}"
  print_message "# Please check if everything looks as expected and then push."
  print_message "# Use this command to push all at once or nothing, if anything goes wrong:"
  print_message "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} ${HOTFIX_BRANCH} --follow-tags # all or nothing"
else
  print_message "# Okay, you have got a conflict while merging onto ${DEVELOP_BRANCH}"
  print_message "# but don't panic, in most cases you can easily resolve the conflicts (in some cases you even do not need to merge all)."
  print_message "# Please do so and continue the hotfix finishing with the following command:"
  print_message "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} ${HOTFIX_BRANCH} --follow-tags # all or nothing"
fi

