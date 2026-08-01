#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MARKER="$HOME/.dotfiles-profile"

echo "🚀 Bootstrapping machine from dotfiles"

# Machine profile: 'personal' installs everything; 'work' sticks to the base
# Brewfiles and skips SSH keys and the personal gitconfig. Remembered per
# machine in ~/.dotfiles-profile so reruns and the sync agent agree.
PROFILE="${1:-}"
PROFILE="${PROFILE#--profile=}"
if [[ -z "$PROFILE" ]]; then
  if [[ -f "$PROFILE_MARKER" ]]; then
    PROFILE="$(cat "$PROFILE_MARKER")"
  elif [[ -t 0 ]]; then
    read -r -p "Machine profile [personal/work] (default: personal): " PROFILE
    PROFILE="${PROFILE:-personal}"
  else
    PROFILE="personal"
  fi
fi
if [[ "$PROFILE" != "personal" && "$PROFILE" != "work" ]]; then
  echo "Invalid profile '$PROFILE' (expected personal or work)" >&2
  exit 1
fi
echo "$PROFILE" > "$PROFILE_MARKER"
echo "▶ Machine profile: $PROFILE"

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
brewfiles=("$DOTFILES_DIR/Brewfile")
sudo_brewfiles=("$DOTFILES_DIR/Brewfile.sudo")
if [[ "$PROFILE" == "personal" ]]; then
  brewfiles+=("$DOTFILES_DIR/Brewfile.personal")
  sudo_brewfiles+=("$DOTFILES_DIR/Brewfile.personal.sudo")
fi

# A single broken cask must not abort the whole bootstrap: report and go on,
# the dotfiles-sync agent retries missing packages later anyway
cat "${brewfiles[@]}" | HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file=- --no-upgrade \
  || echo "⚠️  Some Brewfile entries failed — check output above; sync will retry"

# Casks with privileged install steps; safe here because this run is
# interactive and sudo can prompt in the terminal
cat "${sudo_brewfiles[@]}" | HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file=- --no-upgrade \
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

if [[ "$PROFILE" == "work" ]]; then
  echo "⏭️  Work profile: skipping SSH keys and personal gitconfig."
  echo "    Once you know the company stack, run the relevant setup/ssh/*.sh by hand."
else
  "$DOTFILES_DIR/setup/setup.sh"
fi

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
