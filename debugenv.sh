#!/bin/sh

docker run --rm -ti \
  -v "$(pwd)/BeurerScaleManager:/workspace" \
  -v "$(pwd)/tools:/tools:ro" \
  -v "$(pwd)/extra:/extra:ro" \
  -w '/workspace' \
  beurer-buildenv-2023 bash -i
