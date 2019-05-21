# release-scripts [![Build Status](https://travis-ci.com/borisskert/release-scripts.svg?branch=master)](https://travis-ci.com/borisskert/release-scripts)

## Description

This scripts can help you if you have are working in a [git-flow](https://danielkummer.github.io/git-flow-cheatsheet/)
 workflow on your project.

Especially the release and hotfix step of git-flow requires a lot commits and merge
 processes this scripts can help your out. Your can use them locally as well as in ci-pipelines.

## Requirements

* bash terminal
* git version control

## Integration

* checkout this repo
* copy all *.sh files into your project
* adjust `hooks.sh` for your project environment

## Integration as a submodule (recommended)

* Perform this steps in terminal:

```
  $ git submodule add https://github.com/borisskert/release-scripts release-scripts
  $ cp release-scripts/.hooks-default.sh .release-scripts-hooks.sh
```

* adjust `.release-scripts-hooks.sh` for your project environment

## Perform a standard release

### with snapshot versions

    $ ./release.sh <release-version> <next snapshot/beta version>
    # Perform next steps the script is telling

### without snapshot versions

    $ ./release.sh <release-version> --without-snapshot
    # Perform next steps the script is telling

## Perform a hotfix release

### with snapshot versions

    $ ./hotfix_start.sh <hotfix-version>
    # commit and push your work into the hotfix-branch
    $ ./hotfix_finish.sh <hotfix-version> <current snapshot/beta version>

### without snapshot versions

    $ ./hotfix_start.sh <hotfix-version> --without-snapshot
    # commit and push your work into the hotfix-branch
    $ ./hotfix_finish.sh <hotfix-version> --without-snapshot

## Revert a (local) release

    $ ./revert_release <release-version>

## Support branches
If you need to make releases from support branches and also from develop, take care to adjust your hooks
to calculate master and develop branches according to versions.

Example: For releasing versions that start with `12.`, i.e. `12.2` we'll use `support-12.x` branch, otherwise `develop` branch:
```bash
function get_develop_branch_name {
  if [[ "$1" =~ ^12\..* ]]
  then
    echo "support-12.x"
  else
    echo "develop"
  fi
}

function get_master_branch_name {
  if [[ "$1"  =~ ^12\..* ]]
  then
    echo "master-12.x"
  else
    echo "master"
  fi
}
```

## How to run unit tests over release scripts
1. Install [bats-core](https://github.com/bats-core/bats-core)
2. Go to tests directory
3. Run `bats *.bats`

## How to run shellcheck

```bash
$ find . -maxdepth 1 -type f -name '*.sh' -print0 | xargs -0 shellcheck
```

Make sure you have installed [shellcheck](https://www.shellcheck.net/) on your system.
