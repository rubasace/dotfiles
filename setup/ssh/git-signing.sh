#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

SIGN_KEY="$SSH_DIR/id_ed25519_git_signing"

info "Setting up Git commit signing (SSH)"

if ! key_exists "$SIGN_KEY"; then
  info "Creating SSH key for Git commit signing"
  ssh-keygen -t ed25519 -f "$SIGN_KEY" -C "ruben@git-signing"
  info "Adding Git signing key to agent with Keychain"
  ssh-add --apple-use-keychain "$SIGN_KEY"
  echo ""
  info "Git signing SSH public key (use for signing key in Git services):"
  cat "$SIGN_KEY.pub"
  echo ""
else
  warn "Git signing key already exists, skipping"
fi

info "Configuring Git to use SSH-based commit signing"

git config --global gpg.format ssh
git config --global user.signingkey "$SIGN_KEY"
git config --global commit.gpgsign true


