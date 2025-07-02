#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

echo "Installing the chart..."
"$SCRIPT_DIR/upgrade.sh"
