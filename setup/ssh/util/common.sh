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

# Keys must always be created with a passphrase, which needs a terminal to
# prompt; a non-interactive run would silently create passphrase-less keys
can_create_keys() {
  if [[ -t 0 ]]; then
    return 0
  fi
  warn "Skipping key creation (non-interactive session; passphrase prompt needs a terminal)"
  return 1
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

