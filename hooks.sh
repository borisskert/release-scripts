#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Hook method to format your release tag
# Parameter $1 - version as text
# Returns tag as text
function formatReleaseTag {
  echo "v$1"
}

# Hook method to format your next snapshot version
# Parameter $1 - version as text
# Returns snapshot version as text
function formatSnapshotVersion {
  echo "$1-SNAPSHOT"
}

# Hook method to define the develop branch name
# Returns the develop branch name as text
function getDevelopBranchName {
  echo "develop"
}

# Hook method to define the master branch name
# Returns the master branch name as text
function getMasterBranchName {
  echo "master"
}

# Hook method to format the release branch name
# Parameter $1 - version as text
# Returns the formatted release branch name as text
function formatReleaseBranchName {
  echo "release-$1"
}

# Hook method to format the hotfix branch name
# Parameter $1 - version as text
# Returns the formatted hotfix branch name as text
function formatHotfixBranchName {
  echo "hotfix-$1"
}

# Perform a release on your modules here
# Parameter $1 - release version as text
function release_modules {
  echo "do nothing" >> /dev/null
}

# Set version numbers in your modules
# Parameter $1 - version as text
function set_modules_version {
  echo "do nothing" >> /dev/null
}
