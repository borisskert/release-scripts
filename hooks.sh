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
