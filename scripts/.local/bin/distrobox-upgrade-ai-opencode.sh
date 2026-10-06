#!/usr/bin/env bash
set -euo pipefail

CONTAINER="ai-opencode"

echo "==> Updating Arch Linux packages in ${CONTAINER}..."

distrobox enter "$CONTAINER" -- sudo pacman -Syu --noconfirm

echo
echo "==> Updating OpenCode in ${CONTAINER}..."

distrobox enter "$CONTAINER" -- \
    sudo env \
        HOME=/root \
        XDG_CONFIG_HOME=/root/.config \
        XDG_DATA_HOME=/root/.local/share \
        XDG_STATE_HOME=/root/.local/state \
        XDG_CACHE_HOME=/root/.cache \
        npm_config_cache=/var/cache/npm \
        npm install -g @opencode/cli --allow-scripts=@opencode/cli

echo
echo "==> Installed OpenCode version:"
opencode --version

echo
echo "==> ${CONTAINER} update complete"
