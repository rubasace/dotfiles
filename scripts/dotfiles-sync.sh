#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  echo "[$(date '+%F %T')] $*"
}

eval "$(/opt/homebrew/bin/brew shellenv)"
cd "$DOTFILES_DIR"


log "dotfiles sync started"

if git diff --quiet && git diff --cached --quiet; then
  git fetch --quiet origin || { log "fetch failed (offline?), continuing with local state"; }
  if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    local_rev="$(git rev-parse @)"
    remote_rev="$(git rev-parse '@{u}')"
    base_rev="$(git merge-base @ '@{u}')"
    if [[ "$local_rev" != "$remote_rev" && "$local_rev" == "$base_rev" ]]; then
      log "pulling latest changes"
      git pull --ff-only --quiet
    fi
  fi
else
  log "working tree dirty, skipping pull"
fi

./link.sh

# Idempotent and prompt-free on personal; on work it only warns if missing
./setup/git/setup.sh

PROFILE="$(cat "$HOME/.dotfiles-profile" 2>/dev/null || echo personal)"
brewfiles=(Brewfile)
[[ -f "Brewfile.$PROFILE" ]] && brewfiles+=("Brewfile.$PROFILE")

# mas entries are excluded: mas can't detect installed apps while Spotlight
# indexing is disabled, so it would retry (and fail) on every run. App Store
# apps are only handled by the interactive install.sh run.
brewfile_no_mas="$(cat "${brewfiles[@]}" | grep -v '^mas ')"

if ! echo "$brewfile_no_mas" | brew bundle check --file=- >/dev/null 2>&1; then
  log "installing missing packages from Brewfile"
  echo "$brewfile_no_mas" | HOMEBREW_CASK_OPTS="--adopt" brew bundle install --file=- --no-upgrade \
    || log "bundle incomplete — check log above"
fi

log "dotfiles sync finished"
