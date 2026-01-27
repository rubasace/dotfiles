#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="$HOME/.ssh"

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