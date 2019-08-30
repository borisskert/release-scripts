#!/bin/bash
#
# ARG_OPTIONAL_BOOLEAN([quiet], [q], [Turn on quiet mode for automation])
# ARG_OPTIONAL_BOOLEAN([verbose], [v], [Turn on verbose mode for debugging])
# ARG_OPTIONAL_BOOLEAN([snapshots], [s], [Turn on snapshots mode], [on])
# ARG_POSITIONAL_SINGLE([hotfix-version], [Hotfix version you want to prepare, i.e. 1.2.1], )
# ARG_HELP([Release scripts (version: ${VERSION})])
# ARGBASH_GO
# [ <-- needed because of Argbash

# echo "Value of --quiet: $_arg_quiet"
# echo "Value of --verbose: $_arg_verbose"
# echo "Value of --snapshot: $_arg_snapshot"
# echo "hotfix-version is $_arg_hotfix_version"

# shellcheck disable=SC2154
export HOTFIX_VERSION=${_arg_hotfix_version}
export VERBOSE=${_arg_verbose}
export QUIET=${_arg_quiet}
export SNAPSHOTS=${_arg_snapshots}

# ] <-- needed because of Argbash
