#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

KEY="$SSH_DIR/id_ed25519_homelab"
CONF_FILE="$SSH_DIR/config.d/90-homelab.conf"

info "Setting up homelab SSH key (one key per machine for all homelab hosts)"

if ! key_exists "$KEY"; then
  info "Creating homelab SSH key"
  ssh-keygen -t ed25519 -f "$KEY" -C "ruben@homelab"
  info "Adding homelab SSH key to agent with Keychain"
  ssh-add --apple-use-keychain "$KEY"
  echo ""
  info "Homelab SSH public key (register in every homelab host's users.nix):"
  cat "$KEY.pub"
  echo ""
else
  warn "Homelab SSH key already exists, skipping"
fi

info "Writing homelab SSH config"

# Legacy per-host keys act as fallbacks until every server knows the new key
legacy_hl15=""
legacy_backup1=""
[[ -f "$SSH_DIR/id_ed25519_hl15" ]] && legacy_hl15="  IdentityFile ~/.ssh/id_ed25519_hl15"$'\n'
[[ -f "$SSH_DIR/id_ed25519_backup1" ]] && legacy_backup1="  IdentityFile ~/.ssh/id_ed25519_backup1"$'\n'

cat > "$CONF_FILE" <<EOF
Host hl15
  HostName 192.168.10.1
  User rubenpahino
  IdentityFile ~/.ssh/id_ed25519_homelab
${legacy_hl15}  IdentitiesOnly yes

Host backup1
  HostName backup1.tailnet.nasvigo.com
  User ruben
  IdentityFile ~/.ssh/id_ed25519_homelab
${legacy_backup1}  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"

# Superseded per-host config files
rm -f "$SSH_DIR/config.d/90-hl15.conf" "$SSH_DIR/config.d/95-backup1.conf"

success "Homelab SSH config ready"
