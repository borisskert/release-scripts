# release-scripts [![Build Status](https://travis-ci.com/borisskert/release-scripts.svg?branch=master)](https://travis-ci.com/borisskert/release-scripts)

release-scripts are designed to be used to perform software releases synchronously in multi-module mono-repositories
 despite of bunches of different technologies.
Using release-scripts may redundantize plugins like maven-release-plugin.

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

```bash
  $ git submodule add https://github.com/borisskert/release-scripts release-scripts
  $ cp release-scripts/.hooks-default.sh .release-scripts-hooks.sh
```

* adjust `.release-scripts-hooks.sh` for your project environment

## Perform a standard release

### with snapshot versions

    $ ./release.sh <release-version> <snapshot-version>
    # Perform next steps the script is telling

### without snapshot versions

    $ ./release.sh --no-snapshots <release-version>
    # Perform next steps the script is telling

## Usage

```bash
$ ./release.sh [-q|--(no-)quiet] [-v|--(no-)verbose] [-s|--(no-)snapshots] [-h|--help] <release-version> [<snapshot-version>]
```

### Options

| Short option | Long option | Default | Description |
|--------------|-------------|---------|-------------|
| -s     | --(no-)snapshots | on | Turn on snapshots mode. If enabled the argument <snapshot-version> is mandatory |
| -q     | --(no-)quiet     | off | Turn on quiet mode for automation                                              |
| -v     | --(no-)verbose   | off | Turn on verbose mode for debugging                                             |

## Perform a hotfix release

### Usage:

```bash
$ ./hotfix_start.sh [-q|--(no-)quiet] [-v|--(no-)verbose] [-s|--(no-)snapshots] [-h|--help] <hotfix-version>
```

and
```bash
$ ./hotfix_finish.sh [-q|--(no-)quiet] [-v|--(no-)verbose] [-s|--(no-)snapshots] [-h|--help] <hotfix-version> [<snapshot-version>]
```

### with snapshot versions

    $ ./hotfix_start.sh <hotfix-version>
    # commit and push your work into the hotfix-branch
    $ ./hotfix_finish.sh <hotfix-version> <snapshot-version>

### without snapshot versions

    $ ./hotfix_start.sh --no-snapshots <hotfix-version>
    # commit and push your work into the hotfix-branch
    $ ./hotfix_finish.sh --no-snapshots <hotfix-version>

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
