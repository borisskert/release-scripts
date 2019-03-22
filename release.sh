#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "${SCRIPT_PATH}/.version.sh" ]; then
  # shellcheck source=.version.sh
  source "${SCRIPT_PATH}/.version.sh"
else
	VERSION="UNKNOWN VERSION"
fi

echo "Release scripts (release, version: ${VERSION})"

if [ $# -ne 2 ]
then
  echo 'Usage: release.sh <release-version> <next-snapshot-version>'
  echo 'For example: release.sh 0.1.0 0.2.0'
  exit 2
fi

RELEASE_VERSION=$1
NEXT_VERSION=$2

if [ -f "${SCRIPT_PATH}/.common-util.sh" ]; then
	# shellcheck source=.common-util.sh
	source "${SCRIPT_PATH}/.common-util.sh"
else
	echo 'Missing file .common-util.sh. Aborting'
	exit 1
fi

RELEASE_BRANCH=$(format_release_branch_name "$RELEASE_VERSION")

if [ ! "${CURRENT_BRANCH}" = "${DEVELOP_BRANCH}" ]
then
  echo "Please checkout the branch '${DEVELOP_BRANCH}' before processing this release script."
  exit 1
fi

check_local_workspace_state "release"

git checkout "${DEVELOP_BRANCH}" && git pull "${REMOTE_REPO}"

# check and create master branch if not present
if is_branch_existing "${MASTER_BRANCH}" || is_branch_existing "remotes/${REMOTE_REPO}/${MASTER_BRANCH}"
then
  git checkout "${MASTER_BRANCH}" && git pull "${REMOTE_REPO}"
else
  git checkout -b "${MASTER_BRANCH}"
  git push --set-upstream "${REMOTE_REPO}" "${MASTER_BRANCH}"
fi

git checkout "${DEVELOP_BRANCH}" && git checkout -b "${RELEASE_BRANCH}"

build_snapshot_modules
cd "${GIT_REPO_DIR}"
git reset --hard

set_modules_version "${RELEASE_VERSION}"
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # commit release versions
  RELEASE_COMMIT_MESSAGE=$(get_release_commit_message "${RELEASE_VERSION}")
  git commit -am "${RELEASE_COMMIT_MESSAGE}"
else
  echo "Nothing to commit..."
fi

build_release_modules
cd "${GIT_REPO_DIR}"
git reset --hard

# merge current develop (over release branch) into master
git checkout "${MASTER_BRANCH}"
git merge -X theirs --no-edit "${RELEASE_BRANCH}"

# create release tag on master
RELEASE_TAG=$(format_release_tag "${RELEASE_VERSION}")
RELEASE_TAG_MESSAGE=$(get_release_tag_message "${RELEASE_VERSION}")
git tag -a "${RELEASE_TAG}" -m "${RELEASE_TAG_MESSAGE}"

# merge release into develop
git checkout "${DEVELOP_BRANCH}"
git merge -X theirs --no-edit "${RELEASE_BRANCH}"

NEXT_SNAPSHOT_VERSION=$(format_snapshot_version "${NEXT_VERSION}")
set_modules_version "${NEXT_SNAPSHOT_VERSION}"
cd "${GIT_REPO_DIR}"

if ! is_workspace_clean
then
  # Commit next snapshot versions into develop
  SNAPSHOT_COMMIT_MESSAGE=$(get_next_snapshot_commit_message "${NEXT_SNAPSHOT_VERSION}")
  git commit -am "${SNAPSHOT_COMMIT_MESSAGE}"
else
  echo "Nothing to commit..."
fi

if git merge --no-edit "${RELEASE_BRANCH}"
then
  # Nope, doing that automtically is too dangerous. But the command is great!
  echo "# Okay, now you've got a new tag and commits on ${MASTER_BRANCH} and ${DEVELOP_BRANCH}."
  echo "# Please check if everything looks as expected and then push."
  echo "# Use this command to push all at once or nothing, if anything goes wrong:"
  echo "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} --follow-tags # all or nothing"
else
  echo "# Okay, you have got a conflict while merging onto ${DEVELOP_BRANCH}"
  echo "# but don't panic, in most cases you can easily resolve the conflicts (in some cases you even do not need to merge all)."
  echo "# Please do so and finish the release process with the following command:"
  echo "git push --atomic ${REMOTE_REPO} ${MASTER_BRANCH} ${DEVELOP_BRANCH} --follow-tags # all or nothing"
fi
