#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -ne 1 && $# -ne 2 ]]
then
        echo 'Usage: revert_release.sh <release-version>'
        echo 'For example: revert_release.sh 0.1.0'
        exit 2
fi

DEVELOP_BRANCH=develop
MASTER_BRANCH=master

if [ $# -eq 1 ]
then
        echo "Warning! This script is deleting every local commit on branches $DEVELOP_BRANCH and $MASTER_BRANCH !"
        echo 'Only continue if you know what you are doing with: revert_release.sh 0.1.0 --iknowwhatimdoing'
        exit 2
fi

DOES_HE_KNOW_WHAT_HE_IS_DOING=$2
if [ ! $DOES_HE_KNOW_WHAT_HE_IS_DOING = '--iknowwhatimdoing' ]
then
        echo 'Usage: revert_release.sh <release-version>'
        echo 'For example: revert_release.sh 0.1.0'
        exit 2
fi

RELEASE_VERSION=$1

RELEASE_BRANCH="release-$RELEASE_VERSION"

source $SCRIPT_PATH/hooks.sh

# revert master branch
git checkout $MASTER_BRANCH
git reset origin/$MASTER_BRANCH --hard

# revert develop branch
git checkout $DEVELOP_BRANCH
git reset origin/$DEVELOP_BRANCH --hard

# delete release branch
if git rev-parse --verify $RELEASE_BRANCH
then
  git branch -D $RELEASE_BRANCH
fi

# delete release tag
RELEASE_TAG=`formatReleaseTag "$RELEASE_VERSION"`
if git rev-parse --verify "$RELEASE_TAG"
then
  git tag -d "$RELEASE_TAG"
fi
