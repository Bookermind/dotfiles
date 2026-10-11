#!/usr/bin/env bash
set -euo pipefail

CONTAINER="ai-opencode"

# --------------------------------
# Helpers
# --------------------------------

# Check if the container exists.
container_exists() {
    distrobox list --no-json --format "{{.Name}}" |
        grep -Fxq "$CONTAINER"
}

# Get OpenCode version inside the container.
# Returns an empty string if OpenCode is not installed.
get_opencode_version() {
    distrobox enter "$CONTAINER" -- opencode --version 2>/dev/null |
        sed 's/^opencode v//' ||
        true
}

# Get latest OpenCode version from npm registry.
get_latest_npm_version() {
    distrobox enter "$CONTAINER" -- \
        npm view @opencode/cli version 2>/dev/null ||
        true
}

# Get number of upgradeable Arch packages.
get_upgradeable_package_count() {
    # Refresh package databases.
    distrobox enter "$CONTAINER" -- \
        sudo pacman -Sy --quiet >/dev/null

    # List upgradeable packages and count them.
    distrobox enter "$CONTAINER" -- \
        sudo pacman -Qu --quiet 2>/dev/null |
        wc -l
}

# -----------------------------
# Main upgrade logic
# -----------------------------

echo "==> Starting upgrade process for container: ${CONTAINER}"
echo

# Check container exists.
if container_exists; then
    echo "==> Container '${CONTAINER}' exists."
else
    echo "==> ERROR: Container '${CONTAINER}' does not exist." >&2
    echo "==> Create it with distrobox assemble before running this script." >&2
    exit 1
fi
echo

# Show current OpenCode version.
CURRENT_VERSION=$(get_opencode_version)

if [ -n "$CURRENT_VERSION" ]; then
    echo "==> Current OpenCode version in ${CONTAINER}: ${CURRENT_VERSION}"
else
    echo "==> OpenCode is not currently installed in ${CONTAINER}"
fi
echo

# Check upgradeable Arch packages.
echo "==> Checking for upgradeable Arch Linux packages..."

UPGRADE_COUNT=$(get_upgradeable_package_count)

if [ "$UPGRADE_COUNT" -gt 0 ]; then
    echo "==> Found ${UPGRADE_COUNT} package(s) to upgrade."
else
    echo "==> No Arch Linux packages need upgrading."
fi
echo

# Check whether OpenCode upgrade is needed.
LATEST_VERSION=$(get_latest_npm_version)

if [ -z "$LATEST_VERSION" ]; then
    echo "==> WARNING: Could not determine latest OpenCode version from npm."
    echo "==> Proceeding with upgrade attempt..."
    UPGRADE_NEEDED=true

elif [ -z "$CURRENT_VERSION" ]; then
    echo "==> OpenCode not installed - installing version ${LATEST_VERSION}"
    UPGRADE_NEEDED=true

elif [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "==> OpenCode update available: ${CURRENT_VERSION} -> ${LATEST_VERSION}"
    UPGRADE_NEEDED=true

else
    echo "==> OpenCode installation is up to date (${LATEST_VERSION})"
    UPGRADE_NEEDED=false
fi

echo

# Perform system package upgrade if needed.
if [ "$UPGRADE_COUNT" -gt 0 ]; then
    echo "==> Updating Arch Linux system packages in ${CONTAINER}..."

    distrobox enter "$CONTAINER" -- \
        sudo pacman -Syu --noconfirm

    echo "==> System package update complete."
else
    echo "==> Skipping system package update - no available upgrades."
fi

echo

# Perform OpenCode upgrade if needed.
if [ "$UPGRADE_NEEDED" = true ]; then
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

    echo "==> OpenCode upgrade complete."
else
    echo "==> Skipping OpenCode upgrade - no upgrade available."
fi

echo

# Show final OpenCode version.
FINAL_VERSION=$(get_opencode_version)

if [ -n "$FINAL_VERSION" ]; then
    echo "==> Final OpenCode version in ${CONTAINER}: ${FINAL_VERSION}"
else
    echo "==> ERROR: OpenCode not found after upgrade attempt!" >&2
    exit 1
fi

echo
echo "==> ${CONTAINER} upgrade complete."
