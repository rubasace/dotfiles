#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

KEY="$SSH_DIR/id_ed25519_backup1"
CONF_FILE="$SSH_DIR/config.d/95-backup1.conf"

info "Setting up Backup1 SSH key"

if ! key_exists "$KEY"; then
  info "Creating Backup1 SSH key"
  ssh-keygen -t ed25519 -f "$KEY" -C "ruben@backup1"
  info "Adding Backup1 SSH key to agent with Keychain"
  ssh-add --apple-use-keychain "$KEY"
  echo ""
  info "Backup1 SSH public key (add to authorized_keys on your servers):"
  cat "$KEY.pub"
  echo ""
else
  warn "Backup1 SSH key already exists, skipping"
fi

info "Writing Backup1 SSH config"

cat > "$CONF_FILE" <<'EOF'
Host backup1
  HostName 192.168.105.175
  User rubenpahino
  IdentityFile ~/.ssh/id_ed25519_backup1
  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"

