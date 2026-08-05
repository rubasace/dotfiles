#!/usr/bin/env bash
set -euo pipefail

# One-command bootstrap for a blank Mac — no git, Xcode CLT, or Homebrew needed:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rubasace/dotfiles/master/bootstrap.sh)"
#
# Extra arguments are forwarded to install.sh:
#
#   /bin/bash -c "$(curl -fsSL ...)" -- --profile=edreams

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/workspace/personal/dotfiles}"
REPO_URL="https://github.com/rubasace/dotfiles.git"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This setup only supports macOS" >&2
  exit 1
fi

# Homebrew's installer also installs the Command Line Tools when they are
# missing, so a blank machine needs nothing preinstalled (git arrives with the
# CLT). Also re-run when only the CLT are gone — a macOS major upgrade
# invalidates them while leaving brew in place.
if [[ ! -x /opt/homebrew/bin/brew ]] || ! xcode-select -p >/dev/null 2>&1; then
  echo "▶ Installing Homebrew (+ Command Line Tools if missing)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "▶ Using existing clone at $DOTFILES_DIR"
else
  echo "▶ Cloning dotfiles into $DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh" "$@"
