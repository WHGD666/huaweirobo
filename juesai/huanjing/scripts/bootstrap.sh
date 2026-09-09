#!/usr/bin/env bash
set -euo pipefail

# Compatibility entry point. The official A1Z workflow lives in
# install_a1z_official.sh; this wrapper contains no legacy compatibility logic.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/install_a1z_official.sh" "$@"
