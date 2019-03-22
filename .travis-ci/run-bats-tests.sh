#!/usr/bin/env bash

WORK_DIR=$(pwd)

cd tests || exit
bats ./*.bats

cd "${WORK_DIR}" || exit
