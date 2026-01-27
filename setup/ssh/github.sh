#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

AUTH_KEY="$SSH_DIR/id_ed25519_github"
CONF_FILE="$SSH_DIR/config.d/10-github.conf"

info "Setting up GitHub SSH keys"

if ! key_exists "$AUTH_KEY"; then
  info "Creating GitHub SSH auth key"
  ssh-keygen -t ed25519 -f "$AUTH_KEY" -C "ruben@github"
  info "Adding GitHub SSH key to agent with Keychain"
  ssh-add --apple-use-keychain "$AUTH_KEY"
  echo ""
  info "GitHub SSH public key (add to GitHub):"
  cat "$AUTH_KEY.pub"
  echo ""
else
  warn "GitHub SSH auth key already exists, skipping"
fi

info "Writing GitHub SSH config"

cat > "$CONF_FILE" <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"


