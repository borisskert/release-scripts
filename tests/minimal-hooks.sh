#!/bin/bash
# ********************** INFO *********************
# This file will only overwrite on single method:
# - set_modules_version to set the version during tests
# I am testing the hooks-defaults with it
# *************************************************
set -e

# Should set version numbers in your modules
# Parameter $1 - version as text
function set_modules_version {
  echo "$1" > version.txt
}
