#!/bin/bash
#
# ARG_OPTIONAL_BOOLEAN([quiet], [q], [Turn on quiet mode for automation])
# ARG_OPTIONAL_BOOLEAN([verbose], [v], [Turn on verbose mode for debugging])
# ARG_OPTIONAL_BOOLEAN([snapshots], [s], [Turn on snapshots mode], [on])
# ARG_POSITIONAL_SINGLE([release-version], [Current release version, i.e. 1.2.0], )
# ARG_POSITIONAL_SINGLE([snapshot-version], [Next snapshot version, i.e. 1.3.0 which leads to 1.3.0-SNAPSHOT], [""])
# ARG_HELP([Release scripts (version: ${VERSION})])
# ARGBASH_GO
# [ <-- needed because of Argbash

# echo "Value of --quiet: $_arg_quiet"
# echo "Value of --verbose: $_arg_verbose"
# echo "Value of --snapshots: $_arg_snapshots"
# echo "release-version is $_arg_release_version"
# echo "snapshot-version is $_arg_snapshot_version"

# shellcheck disable=SC2154
export RELEASE_VERSION=${_arg_release_version}
export NEXT_VERSION=${_arg_snapshot_version}
export VERBOSE=${_arg_verbose}
export QUIET=${_arg_quiet}
export SNAPSHOTS=${_arg_snapshots}

if [[ "${SNAPSHOTS}" = "on" && "${NEXT_VERSION}" = "" ]]
then
  echo "FATAL ERROR: Not enough positional arguments - we require 'snapshot-version' when snapshots mode is turned on."
fi

# ] <-- needed because of Argbash
