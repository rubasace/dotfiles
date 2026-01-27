#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../common.sh"

ensure_ssh_dir

AUTH_KEY="$SSH_DIR/id_ed25519_gitlab"
CONF_FILE="$SSH_DIR/config.d/20-gitlab.conf"

info "Setting up GitLab SSH keys"

if ! key_exists "$AUTH_KEY"; then
  info "Creating GitLab SSH auth key"
  ssh-keygen -t ed25519 -f "$AUTH_KEY" -C "ruben@gitlab"
  info "Adding GitLab SSH key to agent with Keychain"
  ssh-add --apple-use-keychain "$AUTH_KEY"
  echo ""
  info "GitLab SSH public key (add to GitLab):"
  cat "$AUTH_KEY.pub"
  echo ""
else
  warn "GitLab SSH auth key already exists, skipping"
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
