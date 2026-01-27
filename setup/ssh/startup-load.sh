#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/util/common.sh"

LAUNCHAGENTS_DIR="$USER_HOME/Library/LaunchAgents"
PLIST_FILE="$LAUNCHAGENTS_DIR/local.addssh.plist"
SCRIPT_DIR="$USER_HOME/.local/bin"
SCRIPT_PATH="$SCRIPT_DIR/add-keys.sh"

info "Setting up SSH LaunchAgent to load keys at startup"

# Ensure .local/bin directory exists
mkdir -p "$SCRIPT_DIR"
chmod 700 "$SCRIPT_DIR"

# Create the script that adds SSH keys to the agent
cat > "$SCRIPT_PATH" <<SCRIPT_EOF
#!/usr/bin/env bash

# Add SSH keys to the agent on login
# This script is called by the launchagent at startup

SSH_DIR="$SSH_DIR"

# Array of SSH keys to add
KEYS=(
  "\$SSH_DIR/id_ed25519_github"
  "\$SSH_DIR/id_ed25519_gitlab"
  "\$SSH_DIR/id_ed25519_hl15"
  "\$SSH_DIR/id_ed25519_git_signing"
)

for key in "\${KEYS[@]}"; do
  if [[ -f "\$key" ]]; then
    ssh-add --apple-use-keychain "\$key" 2>/dev/null || true
  fi
done
SCRIPT_EOF

chmod 700 "$SCRIPT_PATH"

# Ensure LaunchAgents directory exists
mkdir -p "$LAUNCHAGENTS_DIR"
chmod 700 "$LAUNCHAGENTS_DIR"

# Create the LaunchAgent plist file
cat > "$PLIST_FILE" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>local.addssh</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>-c</string>
		<string>$SCRIPT_PATH</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>3600</integer>
	<key>StandardOutPath</key>
	<string>/tmp/addssh.log</string>
	<key>StandardErrorPath</key>
	<string>/tmp/addssh-error.log</string>
</dict>
</plist>
PLIST_EOF

chmod 600 "$PLIST_FILE"

success "LaunchAgent plist created at: $PLIST_FILE"
success "SSH keys script created at: $SCRIPT_PATH"

info "Loading the LaunchAgent..."

# Unload first if already loaded (ignore errors)
launchctl unload "$PLIST_FILE" 2>/dev/null || true

# Load the LaunchAgent
launchctl load "$PLIST_FILE" || {
  warn "Failed to load LaunchAgent."
  warn "You can manually load it with: launchctl load $PLIST_FILE"
}

success "SSH LaunchAgent setup complete!"
info "Your SSH keys will be automatically loaded at startup and every hour."
