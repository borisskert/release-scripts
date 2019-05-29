#!/bin/bash

QUIET=false
VERBOSE=false
SNAPSHOTS=true
ARGUMENTS=()

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

for i in "$@"
do
case ${i} in
    -q|--quiet)
    export QUIET=true
    shift # past argument=value
    ;;
    -q=*|--quiet=*)
    export QUIET="${i#*=}"
    shift # past argument=value
    ;;
    -v|--verbose)
    export VERBOSE=true
    shift # past argument=value
    ;;
    -v=*|--verbose=*)
    export VERBOSE="${i#*=}"
    shift # past argument=value
    ;;
    -s|--snapshots)
    export SNAPSHOTS=true
    shift # past argument=value
    ;;
    -s=*|--snapshots=*)
    export SNAPSHOTS="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    shift # past argument with no value
    ;;
    *)
          # unknown option
          ARGUMENTS+=("${i#*=}")
    ;;
esac
done
