#!/usr/bin/env bash

set -e

UNSTOW=""

if [ "$1" == "-D" ]; then
    UNSTOW="-D"
elif [ -n "$1" ]; then
    echo "Unsupported option: $1"
    echo ""
    echo "Usage:"
    echo "  ./stow.sh       -- stow"
    echo "  ./stow.sh -D    -- unstow"
    exit 1
fi

STOW_CMD=""

if [ -x "$(command -v stow)" ]; then
    STOW_CMD="stow"
elif [ -x "$(command -v nix)" ]; then
    STOW_CMD="nix run nixkpgs#stow --"
fi

if ! [ -n "$STOW_CMD" ]; then
    echo "GNU Stow not found in $\PATH"
    exit 1
fi

PACKAGE_NAME="nvim"
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}

if ! [ -d "$CONFIG_DIR" ]; then
    echo "Unable to determine config directory."
    echo "Either \$XDG_CONFIG_HOME or \$HOME/.config must exist"
    echo ""
    echo "Found:"
    echo "  \$XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-<not set>}"
    echo "  \$HOME/.config: ${HOME:-<not set>}/.config"
    exit 1
fi

TARGET_PATH="$CONFIG_DIR/$PACKAGE_NAME"

if ! [ -d "$TARGET_PATH" ]; then
    echo "Creating directory: $TARGET_PATH"
    mkdir -p "$TARGET_PATH"
fi

eval "$STOW_CMD" \
    -d "$(dirname "$0")" \
    -t "$TARGET_PATH" \
    -v \
    "$UNSTOW" \
    .

if [ -n "$UNSTOW" ] && [ -d "$TARGET_PATH" ]; then
    echo "Removing directory: $TARGET_PATH"
    rm -r "$TARGET_PATH"
fi
