#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MARKER="$HOME/.dotfiles-profile"

echo "🚀 Bootstrapping machine from dotfiles"

# Machine profile: 'personal' installs everything; any other profile (e.g.
# 'edreams') is a company machine — base Brewfiles plus its own
# Brewfile.<profile> overlay, and no personal keys or identity. Profiles are
# discovered from the overlay files, so onboarding a new company is just
# dropping a Brewfile.<name>. Remembered per machine in ~/.dotfiles-profile
# so reruns and the sync agent agree.
profiles=(personal)
for overlay in "$DOTFILES_DIR"/Brewfile.*; do
  name="${overlay##*/Brewfile.}"
  if [[ "$name" != "personal" && "$name" != "sudo" && "$name" != *.sudo ]]; then
    profiles+=("$name")
  fi
done
PROFILE="${1:-}"
PROFILE="${PROFILE#--profile=}"
if [[ -z "$PROFILE" ]]; then
  if [[ -f "$PROFILE_MARKER" ]]; then
    PROFILE="$(cat "$PROFILE_MARKER")"
  elif [[ -t 0 ]]; then
    echo "Machine profile:"
    select PROFILE in "${profiles[@]}"; do
      [[ -n "$PROFILE" ]] && break
    done
  else
    PROFILE="personal"
  fi
fi
case " ${profiles[*]} " in
  *" $PROFILE "*) ;;
  *)
    echo "Invalid profile '$PROFILE' (expected one of: ${profiles[*]})" >&2
    exit 1
    ;;
esac
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
# Each profile stacks its overlay on top of the base Brewfile
brewfiles=("$DOTFILES_DIR/Brewfile" "$DOTFILES_DIR/Brewfile.$PROFILE")
sudo_brewfiles=("$DOTFILES_DIR/Brewfile.sudo")
if [[ -f "$DOTFILES_DIR/Brewfile.$PROFILE.sudo" ]]; then
  sudo_brewfiles+=("$DOTFILES_DIR/Brewfile.$PROFILE.sudo")
fi

# A single broken cask must not abort the whole bootstrap: report and go on,
# the dotfiles-sync agent retries missing packages later anyway
cat "${brewfiles[@]}" | HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file=- --no-upgrade \
  || echo "⚠️  Some Brewfile entries failed — check output above; sync will retry"

# Casks with privileged install steps; safe here because this run is
# interactive and sudo can prompt in the terminal
cat "${sudo_brewfiles[@]}" | HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file=- --no-upgrade \
  || echo "⚠️  Some Brewfile.sudo entries failed — check output above"

# Colima (where the profile ships it) runs as a launchd service, so docker
# works after reboots without a manual `colima start`
if command -v colima >/dev/null 2>&1; then
  echo "▶ Starting colima as a service"
  brew services start colima || true
fi

# Brew installs docker CLI plugins (compose, ...) under its own prefix;
# expose them so `docker compose` resolves. Left alone if ~/.docker/cli-plugins
# is a real directory owned by some other install.
docker_plugins="$(brew --prefix)/lib/docker/cli-plugins"
if [[ -d "$docker_plugins" && ( ! -e "$HOME/.docker/cli-plugins" || -L "$HOME/.docker/cli-plugins" ) ]]; then
  mkdir -p "$HOME/.docker"
  ln -sfn "$docker_plugins" "$HOME/.docker/cli-plugins"
fi

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

if [[ "$PROFILE" == "personal" ]]; then
  "$DOTFILES_DIR/setup/setup.sh"
else
  echo "⏭️  $PROFILE profile: skipping personal SSH auth keys (gitlab, homelab)."
  # Company machines still get git identity (prompted), a GitHub auth key and
  # commit signing; identity goes first so the signing key registers under it
  "$DOTFILES_DIR/setup/git/setup.sh"
  "$DOTFILES_DIR/setup/ssh/00-config.sh"
  "$DOTFILES_DIR/setup/ssh/10-github.sh"
  "$DOTFILES_DIR/setup/ssh/40-git-signing.sh"
  "$DOTFILES_DIR/setup/ssh/90-startup-load.sh"
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
