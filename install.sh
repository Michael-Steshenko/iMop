#!/bin/bash
# install hammerspoon config files
sh .hammerspoon/install.sh

# install ghostty config file via symlink
# realpath requires coreutils: brew install coreutils
SCRIPT_PATH=$(realpath "$0")
GHOSTTY_CONFIG_PATH=$(dirname "$SCRIPT_PATH")/ghostty/config
mkdir -p ~/.config/ghostty
# -s: symbolic link
# -f: force — removes the destination if it exists
# -n: treat the destination as a normal file (otherwise file will be placed inside)
# so -fn will overwrite the config file if it exists
INSTALL_CMD="ln -sfn $GHOSTTY_CONFIG_PATH ~/.config/ghostty/config"
echo "installing ghostty config via a symlink:\n$INSTALL_CMD"
eval "$INSTALL_CMD"

# TODO move the symlink + printing logic into a funciton