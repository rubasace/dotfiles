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

# Create a key and store it in the agent + Keychain asking for the passphrase
# a single time, instead of the three prompts ssh-keygen (create + confirm)
# and ssh-add would fire on their own. The passphrase reaches ssh-add through
# a throwaway SSH_ASKPASS helper reading it from the environment, so it never
# touches disk or argv.
create_key_with_keychain() {
  local key_file="$1"
  local comment="$2"
  local passphrase=""
  while [[ -z "$passphrase" ]]; do
    read -rsp "Passphrase for $(basename "$key_file"): " passphrase
    echo
  done
  ssh-keygen -t ed25519 -f "$key_file" -C "$comment" -N "$passphrase"
  local askpass
  askpass="$(mktemp)"
  printf '#!/bin/sh\nprintf %%s "$KEY_PASSPHRASE"\n' > "$askpass"
  chmod 700 "$askpass"
  KEY_PASSPHRASE="$passphrase" SSH_ASKPASS="$askpass" SSH_ASKPASS_REQUIRE=force \
    ssh-add --apple-use-keychain "$key_file" < /dev/null
  rm -f "$askpass"
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

