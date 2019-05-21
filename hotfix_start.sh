#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -f "${SCRIPT_PATH}/.version.sh" ]]
then
  # shellcheck source=.version.sh
	source "${SCRIPT_PATH}/.version.sh"
else
	VERSION="UNKNOWN VERSION"
fi

echo "Release scripts (hotfix-start, version: ${VERSION})"

if [[ $# -lt 1 || $# -gt 2 ]]
then
  echo 'Usage: hotfix_start.sh <hotfix-version> [--without-snapshot]'
  echo 'For example: hotfix_start.sh 0.2.1'
  echo 'or without snapshot: hotfix_start.sh 0.2.1 --without-snapshot'
  exit 2
fi

HOTFIX_VERSION=$1

if [[ "${2}" = "--without-snapshot" ]]
then
  HOTFIX_MODULE_VERSION="${HOTFIX_VERSION}"
else
  HOTFIX_MODULE_VERSION="${HOTFIX_VERSION}-SNAPSHOT"
fi

# Necessary to calculate develop/master branch name
RELEASE_VERSION=${HOTFIX_VERSION}

if [[ -f "${SCRIPT_PATH}/.common-util.sh" ]]
then
  # shellcheck source=.common-util.sh
	source "${SCRIPT_PATH}/.common-util.sh"
else
	echo 'Missing file .common-util.sh. Aborting'
	exit 1
fi

unset RELEASE_VERSION

HOTFIX_BRANCH=$(format_hotfix_branch_name "${HOTFIX_VERSION}")

check_local_workspace_state "hotfix_start"

git checkout "${MASTER_BRANCH}" && git pull "${REMOTE_REPO}"
git checkout -b "${HOTFIX_BRANCH}"

set_modules_version "${HOTFIX_MODULE_VERSION}"
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit hotfix versions
  START_HOTFIX_COMMIT_MESSAGE=$(get_start_hotfix_commit_message "${HOTFIX_MODULE_VERSION}")
  git commit -am "${START_HOTFIX_COMMIT_MESSAGE}"
else
  echo "Nothing to commit..."
fi

echo "# Okay, now you've got a new hotfix branch called ${HOTFIX_BRANCH}"
echo "# Please check if everything looks as expected and then push."
echo "# Use this command to push your created hotfix-branch:"
echo "git push --set-upstream ${REMOTE_REPO} ${HOTFIX_BRANCH}"
