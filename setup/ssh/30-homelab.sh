#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

KEY="$SSH_DIR/id_ed25519_homelab"
CONF_FILE="$SSH_DIR/config.d/90-homelab.conf"

info "Setting up homelab SSH key (one key per machine for all homelab hosts)"

if key_exists "$KEY"; then
  warn "Homelab SSH key already exists, skipping"
elif can_create_keys; then
  info "Creating homelab SSH key (added to agent + Keychain)"
  create_key_with_keychain "$KEY" "ruben@homelab"
  echo ""
  info "Homelab SSH public key (register in every homelab host's users.nix):"
  cat "$KEY.pub"
  echo ""
fi

info "Writing homelab SSH config"

# Aliases, FQDNs and IPs all match the blocks, so the right user and key
# apply no matter how the host is written on the command line
cat > "$CONF_FILE" <<'EOF'
Host hl15 192.168.10.1
  HostName 192.168.10.1
  User rubenpahino
  IdentityFile ~/.ssh/id_ed25519_homelab
  IdentitiesOnly yes

Host backup1 backup1.tailnet.nasvigo.com
  HostName backup1.tailnet.nasvigo.com
  User ruben
  IdentityFile ~/.ssh/id_ed25519_homelab
  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"

# Superseded per-host config files
rm -f "$SSH_DIR/config.d/90-hl15.conf" "$SSH_DIR/config.d/95-backup1.conf"

success "Homelab SSH config ready"
