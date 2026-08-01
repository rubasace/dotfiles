#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔐 SSH setup starting..."

# Scripts run in numeric order; drop a new NN-name.sh here and it's picked up
for script in "$SCRIPT_DIR"/[0-9][0-9]-*.sh; do
  "$script"
done

echo "✅ SSH setup complete"
