#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔐 SSH setup starting..."

"$SCRIPT_DIR/config.sh"

"$SCRIPT_DIR/github.sh"
"$SCRIPT_DIR/gitlab.sh"
"$SCRIPT_DIR/homelab.sh"

# Fix ownership
chown -R rubenpahino:staff ~/.ssh

echo "✅ SSH setup complete"