#!/bin/bash

# create a .hammerspoon symlink where Hammerspoon expects the .hammerspoon folder

# realpath requires coreutils: brew install coreutils
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
# -s: symbolic link
# -f: force — removes the destination if it exists
# -n: treat the destination as a normal file (otherwise file will be places inside)
# so -fn will overwrite the .hammerspoon folder if it exists
INSTALL_CMD="ln -sfn $SCRIPT_DIR ~/.hammerspoon"
echo "installing hammerspoon scripts via a symlink to the .hammerspoon dir:\n$INSTALL_CMD"
eval "$INSTALL_CMD"