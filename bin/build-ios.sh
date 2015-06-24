#!/bin/bash

build.py --toolchain ios-8-2-arm64 --verbose --fwd HUNTER_CONFIGURATION_TYPES=Release \
BUILD_EXAMPLES=OFF \
--config Release \
--jobs 8 --framework


