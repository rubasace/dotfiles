#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

SIGN_KEY="$SSH_DIR/id_ed25519_git_signing"

info "Setting up Git commit signing (SSH)"

if key_exists "$SIGN_KEY"; then
  warn "Git signing key already exists, skipping"
elif can_create_keys; then
  info "Creating SSH key for Git commit signing"
  ssh-keygen -t ed25519 -f "$SIGN_KEY" -C "ruben@git-signing"
  info "Adding Git signing key to agent with Keychain"
  ssh-add --apple-use-keychain "$SIGN_KEY"
  echo ""
  info "Git signing SSH public key (use for signing key in Git services):"
  cat "$SIGN_KEY.pub"
  echo ""
fi

# Signing itself is configured in config/.gitconfig (linked to ~/.gitconfig);
# here we only register the public key so signatures verify locally too. The
# principal and signers file come from the effective git config, so work
# machines register their corporate identity in their machine-local file
# instead of the repo-managed one.
if [[ -f "$SIGN_KEY.pub" ]]; then
  info "Registering signing key in allowed_signers"
  PRINCIPAL="$(git config --global --get user.email || true)"
  [[ -z "$PRINCIPAL" ]] && PRINCIPAL="ruben.pahino.verdugo@gmail.com"
  SIGNERS_FILE="$(git config --global --get gpg.ssh.allowedSignersFile || true)"
  [[ -z "$SIGNERS_FILE" ]] && SIGNERS_FILE="$USER_HOME/.config/git/allowed_signers"
  SIGNERS_FILE="${SIGNERS_FILE/#\~/$USER_HOME}"
  mkdir -p "$(dirname "$SIGNERS_FILE")"
  SIGNER_LINE="$PRINCIPAL $(cut -d' ' -f1,2 "$SIGN_KEY.pub")"
  grep -qxF "$SIGNER_LINE" "$SIGNERS_FILE" 2>/dev/null || echo "$SIGNER_LINE" >> "$SIGNERS_FILE"
fi


