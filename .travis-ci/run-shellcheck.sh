#!/usr/bin/env bash

find . -maxdepth 1 -type f -name '*.sh' -print0 | xargs -0 \
docker run \
  --rm \
  -v "$(pwd):/tmp/src" \
  -w /tmp/src \
  koalaman/shellcheck:v0.6.0
