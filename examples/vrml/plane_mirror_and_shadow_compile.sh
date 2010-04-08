#!/bin/bash
set -eu

# Hack to allow calling this script from it's dir.
if [ -f plane_mirror_and_shadow.lpr ]; then
  cd ../../
fi

# Call this from ../../ (or just use `make examples').

fpc -dRELEASE @kambi.cfg examples/vrml/plane_mirror_and_shadow.lpr
