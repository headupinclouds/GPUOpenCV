#!/bin/bash

read -p "This will read from ${HOME}/Pictures and write to /tmp; press ctrl-c to abort and update script, any other key to continue"

# Just demonstrate usage
./batch_process --input=<(find ${HOME}/Pictures -name "*.png" -or -name "*.jpg") --output=/tmp
