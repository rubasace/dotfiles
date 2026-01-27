#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="$HOME/.ssh"
CONF_DIR="$SSH_DIR/config.d"
ROOT_CONFIG="$SSH_DIR/config"

echo "🔐 Initializing SSH base configuration"

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

echo "✅ Base SSH config ready"