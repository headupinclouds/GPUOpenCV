#!/bin/bash

build.py --toolchain libcxx --verbose --fwd HUNTER_CONFIGURATION_TYPES=Release \
BUILD_EXAMPLES=OFF \
--config Release \
--jobs 8 \
--install \
--clear

