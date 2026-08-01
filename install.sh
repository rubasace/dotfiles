#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Bootstrapping machine from dotfiles"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This setup only supports macOS" >&2
  exit 1
fi

# Ask for the admin password once and keep the sudo timestamp warm for the
# whole run (it expires after ~5 min by default, causing repeated prompts
# during long installs). Interactive runs only.
if [[ -t 0 ]]; then
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
  done &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "▶ Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Compatibility with amd64-only apps
softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true

echo "▶ Installing packages from Brewfile"
# Brew >= 6 refuses formulae from third-party taps unless explicitly trusted
for tap in sdkman/tap grishka/grishka; do
  brew tap "$tap" 2>/dev/null || true
  brew trust "$tap" 2>/dev/null || true
done
# A single broken cask must not abort the whole bootstrap: report and go on,
# the dotfiles-sync agent retries missing packages later anyway
HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file "$DOTFILES_DIR/Brewfile" --no-upgrade \
  || echo "⚠️  Some Brewfile entries failed — check output above; sync will retry"

# Casks with privileged install steps; safe here because this run is
# interactive and sudo can prompt in the terminal
HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file "$DOTFILES_DIR/Brewfile.sudo" --no-upgrade \
  || echo "⚠️  Some Brewfile.sudo entries failed — check output above"

echo "▶ Installing npm globals"
if command -v npm >/dev/null 2>&1; then
  for pkg in @anthropic-ai/claude-code @openai/codex; do
    npm ls -g "$pkg" >/dev/null 2>&1 || npm install -g "$pkg"
  done
else
  echo "⚠️  npm not available (node install failed?); skipping npm globals"
fi

"$DOTFILES_DIR/link.sh"
"$DOTFILES_DIR/macos/defaults.sh"
"$DOTFILES_DIR/setup/setup.sh"
"$DOTFILES_DIR/agents/install-agents.sh"

# --- Migrations away from the legacy setup ---

OLD_AUTOUPDATE_PLIST="$HOME/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist"
if [[ -f "$OLD_AUTOUPDATE_PLIST" ]]; then
  echo "▶ Removing homebrew-autoupdate (replaced by the brew-maintenance agent)"
  launchctl bootout "gui/$(id -u)/com.github.domt4.homebrew-autoupdate" 2>/dev/null || true
  rm -f "$OLD_AUTOUPDATE_PLIST"
  rm -rf "$HOME/Library/Application Support/com.github.domt4.homebrew-autoupdate"
  brew untap domt4/autoupdate 2>/dev/null || true
fi

if brew list powerlevel10k >/dev/null 2>&1 && [[ -d "$HOME/powerlevel10k" ]]; then
  echo "▶ Removing legacy powerlevel10k clone (now installed via brew)"
  rm -rf "$HOME/powerlevel10k"
fi
if brew list zsh-syntax-highlighting >/dev/null 2>&1 && [[ -d "$HOME/zsh-plugins" ]]; then
  echo "▶ Removing legacy zsh-plugins clones (now installed via brew)"
  rm -rf "$HOME/zsh-plugins"
fi

echo "✅ Done — open a new terminal session"
