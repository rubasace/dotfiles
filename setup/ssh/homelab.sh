#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

KEY="$SSH_DIR/id_ed25519_hl15"
CONF_FILE="$SSH_DIR/config.d/90-hl15.conf"

info "Setting up HL15 SSH key"

if ! key_exists "$KEY"; then
  info "Creating HL15 SSH key"
  ssh-keygen -t ed25519 -f "$KEY" -C "ruben@hl15"
  info "Adding HL15 SSH key to agent with Keychain"
  ssh-add --apple-use-keychain "$KEY"
  echo ""
  info "HL15 SSH public key (add to authorized_keys on your servers):"
  cat "$KEY.pub"
  echo ""
else
  warn "HL15 SSH key already exists, skipping"
fi

info "Writing HL15 SSH config"

cat > "$CONF_FILE" <<'EOF'
Host hl15
  HostName 192.168.10.1
  User rubenpahino
  IdentityFile ~/.ssh/id_ed25519_hl15
  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"

