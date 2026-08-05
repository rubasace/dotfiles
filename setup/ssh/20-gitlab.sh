#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/util/common.sh"

ensure_ssh_dir

AUTH_KEY="$SSH_DIR/id_ed25519_gitlab"
CONF_FILE="$SSH_DIR/config.d/20-gitlab.conf"

info "Setting up GitLab SSH keys"

if key_exists "$AUTH_KEY"; then
  warn "GitLab SSH auth key already exists, skipping"
elif can_create_keys; then
  info "Creating GitLab SSH auth key (added to agent + Keychain)"
  create_key_with_keychain "$AUTH_KEY" "ruben@gitlab"
  echo ""
  info "GitLab SSH public key (add to GitLab):"
  cat "$AUTH_KEY.pub"
  echo ""
fi

info "Writing GitLab SSH config"

cat > "$CONF_FILE" <<'EOF'
Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/id_ed25519_gitlab
  IdentitiesOnly yes
EOF

chmod 600 "$CONF_FILE"
