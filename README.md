# release-scripts

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

    $ ./release.sh <release-version> <next snapshot/beta version>
    # Perform next steps the script is telling

## Perform a hotfix release

    $ ./hotfix_start.sh <hotfix-version>
    # commit and push your work into the hotfix-branch
    $ ./hotfix_finish.sh <hotfix-version> <current snapshot/beta version>

## Revert a (local) release

    $ ./revert_release <release-version>
