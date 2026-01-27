#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔐 Git setup starting..."

"$SCRIPT_DIR/signing.sh"

echo "✅ Git setup complete"