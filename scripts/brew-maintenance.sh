#!/usr/bin/env bash
set -uo pipefail

log() {
  echo "[$(date '+%F %T')] $*"
}

eval "$(/opt/homebrew/bin/brew shellenv)"

log "brew maintenance started"

brew update --quiet
brew upgrade --formula

# SUDO_ASKPASS is deliberately NOT set: casks whose upgrade needs root
# (obs, parallels, ...) fail here silently instead of popping a GUI password
# prompt. Pick those up interactively with `brewup`.
brew upgrade --cask || log "some casks were skipped (likely require sudo)"

brew cleanup --prune=all -s >/dev/null 2>&1 || true

log "brew maintenance finished"
