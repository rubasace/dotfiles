#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/util/common.sh"

CONF_DIR="$SSH_DIR/config.d"
ROOT_CONFIG="$SSH_DIR/config"

info "Initializing SSH base configuration"

# Ensure directories
mkdir -p "$CONF_DIR"
chmod 700 "$SSH_DIR" "$CONF_DIR"

# Ensure root SSH config imports config.d
cat > "$ROOT_CONFIG" <<'EOF'

Host *
  AddKeysToAgent yes
  UseKeychain yes

Include ~/.ssh/config.d/*
EOF

chmod 600 "$ROOT_CONFIG"

success "Base SSH config ready"
