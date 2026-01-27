#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔐 SSH setup starting..."

"$SCRIPT_DIR/config.sh"

"$SCRIPT_DIR/github.sh"
"$SCRIPT_DIR/gitlab.sh"
"$SCRIPT_DIR/homelab.sh"
"$SCRIPT_DIR/git-signing.sh"
"$SCRIPT_DIR/startup-load.sh"


echo "✅ SSH setup complete"