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

# Every subsystem with a setup.sh gets picked up automatically
for setup_script in "$ROOT_DIR"/*/setup.sh; do
  run_if_exists "$setup_script"
done

echo "✅ Device setup complete"