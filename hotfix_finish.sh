#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "${SCRIPT_PATH}/.version.sh" ]; then
  # shellcheck source=.version.sh
	source "${SCRIPT_PATH}/.version.sh"
else
	VERSION="UNKNOWN VERSION"
fi

echo "Release scripts (hotfix-finish, version: ${VERSION})"

if [ $# -ne 2 ]
then
  echo 'Usage: hotfix_finish.sh <hotfix-version> <next-snapshot-version>'
  echo 'For example:'
  echo 'hotfix_finish.sh 0.2.1 0.3.0'
  exit 2
fi

HOTFIX_VERSION=$1
NEXT_VERSION=$2

# Necessary to calculate develop/master branch name
RELEASE_VERSION=${HOTFIX_VERSION}

if [ -f "${SCRIPT_PATH}/.common-util.sh" ]; then
	# shellcheck source=.common-util.sh
	source "${SCRIPT_PATH}/.common-util.sh"
else
	echo 'Missing file .common-util.sh. Aborting'
	exit 1
fi

unset RELEASE_VERSION

HOTFIX_BRANCH=$(format_hotfix_branch_name "${HOTFIX_VERSION}")

if [ ! "${HOTFIX_BRANCH}" = "${CURRENT_BRANCH}" ]
then
  echo "Please checkout the branch '$HOTFIX_BRANCH' before processing this hotfix release."
  exit 1
fi

check_local_workspace_state "hotfix_finish"

git checkout "${HOTFIX_BRANCH}" && git pull "${REMOTE_REPO}"

build_snapshot_modules
cd "${GIT_REPO_DIR}"
git reset --hard

set_modules_version "${HOTFIX_VERSION}"
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit hotfix versions
  HOTFIX_RELEASE_COMMIT_MESSAGE=$(get_release_hotfix_commit_message "${HOTFIX_VERSION}")
  git commit -am "${HOTFIX_RELEASE_COMMIT_MESSAGE}"
else
  echo "Nothing to commit..."
fi

build_release_modules
cd "${GIT_REPO_DIR}"
git reset --hard

# merge current hotfix into master
git checkout "${MASTER_BRANCH}" && git pull "${REMOTE_REPO}"
git merge --no-edit "${HOTFIX_BRANCH}"

# create release tag
HOTFIX_TAG=$(format_release_tag "${HOTFIX_VERSION}")
HOTFIX_TAG_MESSAGE=$(get_hotfix_relesae_tag_message "${HOTFIX_VERSION}")
git tag -a "${HOTFIX_TAG}" -m "${HOTFIX_TAG_MESSAGE}"

git checkout "${HOTFIX_BRANCH}"

# prepare next snapshot version
NEXT_SNAPSHOT_VERSION=$(format_snapshot_version "${NEXT_VERSION}")
set_modules_version "${NEXT_SNAPSHOT_VERSION}"
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit next snapshot versions
  SNAPSHOT_AFTER_HOTFIX_COMMIT_MESSAGE=$(get_next_snapshot_commit_message_after_hotfix "${NEXT_SNAPSHOT_VERSION}" "${HOTFIX_VERSION}")
  git commit -am "${SNAPSHOT_AFTER_HOTFIX_COMMIT_MESSAGE}"
else
  echo "Nothing to commit..."
fi

# merge next snapshot version into develop
git checkout "${DEVELOP_BRANCH}"

if git merge --no-edit "${HOTFIX_BRANCH}"
then
  echo "# Okay, now you've got a new tag and commits on ${MASTER_BRANCH} and ${DEVELOP_BRANCH}"
  echo "# Please check if everything looks as expected and then push."
  echo "# Use this command to push all at once or nothing, if anything goes wrong:"
  echo "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} ${HOTFIX_BRANCH} --follow-tags # all or nothing"
else
  echo "# Okay, you have got a conflict while merging onto ${DEVELOP_BRANCH}"
  echo "# but don't panic, in most cases you can easily resolve the conflicts (in some cases you even do not need to merge all)."
  echo "# Please do so and continue the hotfix finishing with the following command:"
  echo "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} ${HOTFIX_BRANCH} --follow-tags # all or nothing"
fi

