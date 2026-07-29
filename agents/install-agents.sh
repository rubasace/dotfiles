#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

mkdir -p "$LAUNCH_AGENTS_DIR"

for tmpl in "$SCRIPT_DIR"/*.plist.tmpl; do
  name="$(basename "${tmpl%.tmpl}")"
  label="${name%.plist}"
  target="$LAUNCH_AGENTS_DIR/$name"

  sed -e "s|__DOTFILES_DIR__|$DOTFILES_DIR|g" \
      -e "s|__HOME__|$HOME|g" \
      "$tmpl" > "$target"

  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$target"
  echo "✅ LaunchAgent $label installed"
done
