#!/bin/bash
#
# ARG_OPTIONAL_BOOLEAN([quiet],[q],[Turn on quiet mode for automation])
# ARG_OPTIONAL_BOOLEAN([verbose],[v],[Turn on verbose mode for debugging])
# ARG_OPTIONAL_BOOLEAN([snapshots],[s],[Turn on snapshots mode],[on])
# ARG_POSITIONAL_SINGLE([hotfix-version],[Current hotfix version, i.e. 1.2.0],[])
# ARG_POSITIONAL_SINGLE([snapshot-version],[Next snapshot version, i.e. 1.3.0 which leads to 1.3.0-SNAPSHOT],[""])
# ARG_HELP([Release scripts (version: ${VERSION})])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}


begins_with_short_option()
{
	local first_option all_short_options='qvsh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_snapshot_version=""
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_quiet="off"
_arg_verbose="off"
_arg_snapshots="on"


print_help()
{
	printf '%s\n' "Release scripts (version: ${VERSION})"
	printf 'Usage: %s [-q|--(no-)quiet] [-v|--(no-)verbose] [-s|--(no-)snapshots] [-h|--help] <hotfix-version> [<snapshot-version>]\n' "$0"
	printf '\t%s\n' "<hotfix-version>: Current hotfix version, i.e. 1.2.0"
	printf '\t%s\n' "<snapshot-version>: Next snapshot version, i.e. 1.3.0 which leads to 1.3.0-SNAPSHOT (default: '""')"
	printf '\t%s\n' "-q, --quiet, --no-quiet: Turn on quiet mode for automation (off by default)"
	printf '\t%s\n' "-v, --verbose, --no-verbose: Turn on verbose mode for debugging (off by default)"
	printf '\t%s\n' "-s, --snapshots, --no-snapshots: Turn on snapshots mode (on by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-q|--no-quiet|--quiet)
				_arg_quiet="on"
				test "${1:0:5}" = "--no-" && _arg_quiet="off"
				;;
			-q*)
				_arg_quiet="on"
				_next="${_key##-q}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-q" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-v|--no-verbose|--verbose)
				_arg_verbose="on"
				test "${1:0:5}" = "--no-" && _arg_verbose="off"
				;;
			-v*)
				_arg_verbose="on"
				_next="${_key##-v}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-v" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-s|--no-snapshots|--snapshots)
				_arg_snapshots="on"
				test "${1:0:5}" = "--no-" && _arg_snapshots="off"
				;;
			-s*)
				_arg_snapshots="on"
				_next="${_key##-s}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-s" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'hotfix-version'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require between 1 and 2 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 2 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect between 1 and 2 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_hotfix_version _arg_snapshot_version "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

# echo "Value of --quiet: $_arg_quiet"
# echo "Value of --verbose: $_arg_verbose"
# echo "Value of --snapshots: $_arg_snapshots"
# echo "hotfix-version is $_arg_hotfix_version"
# echo "snapshot-version is $_arg_snapshot_version"

if [[ "${_arg_snapshots}" = "on" && "${_arg_snapshot_version}" = "" ]]
then
  echo "FATAL ERROR: Not enough positional arguments - we require 'snapshot-version' when snapshots mode is turned on."
fi

# ] <-- needed because of Argbash