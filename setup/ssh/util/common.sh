#!/usr/bin/env bash
set -euo pipefail

CURRENT_USER="${USER:-$(whoami)}"
USER_HOME="/Users/$CURRENT_USER"
SSH_DIR="$USER_HOME/.ssh"

ensure_ssh_dir() {
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
}

key_exists() {
  [[ -f "$1" ]]
}

info() {
  echo "ℹ️  $1"
}

warn() {
  echo "⚠️  $1"
}

success() {
  echo "✅ $1"
}

