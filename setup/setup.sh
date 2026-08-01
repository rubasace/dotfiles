#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting device setup"

run_if_exists() {
  local script="$1"
  if [[ -x "$script" ]]; then
    echo "▶ Running $(basename "$script")"
    "$script"
  else
    echo "⏭️  Skipping $(basename "$script") (not found or not executable)"
  fi
}

run_if_exists "$ROOT_DIR/ssh/setup.sh"
run_if_exists "$ROOT_DIR/sops/setup.sh"

echo "✅ Device setup complete"