#!/bin/sh

mkdir -p build

docker run --rm -ti \
  -v "$(pwd):/workspace/src:ro" \
  -v "$(pwd)/build:/workspace/build" \
  -w '/workspace' \
  -u "$(id -u)" \
  beurer-buildenv-2023 bash -i
