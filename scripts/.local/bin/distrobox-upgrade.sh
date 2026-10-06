#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

container_exists() {
    local container="$1"

    distrobox list --no-color |
        awk -F '|' 'NR > 1 { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2 }' |
        grep -Fxq "$container"
}

run_upgrade() {
    local container="$1"
    local script="$2"

    echo
    echo "============================================================"
    echo "Checking ${container}"
    echo "============================================================"

    if ! container_exists "$container"; then
        echo "ERROR: Distrobox container '${container}' does not exist." >&2
        echo >&2
        echo "Create the container before running upgrades." >&2
        echo >&2
        return 1
    fi

    echo "Container '${container}' exists."
    echo "Running ${script}..."

    "$SCRIPT_DIR/$script"
}

# ---------------------------------------------------------------------------
# Appliances
# ---------------------------------------------------------------------------

run_upgrade \
    "ai-opencode" \
    "distrobox-upgrade-ai-opencode.sh"

# Future appliances can be added here:
#
# run_upgrade \
#     "ai-pi" \
#     "distrobox-upgrade-ai-pi.sh"

echo
echo "============================================================"
echo "All Distrobox upgrades completed successfully."
echo "============================================================"
