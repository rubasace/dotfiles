#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="${SCRIPT_DIR}/config"
PROFILE="$(cat "$HOME/.dotfiles-profile" 2>/dev/null || echo personal)"

# Top-level files in config/ are linked into $HOME
while IFS= read -r -d '' file; do
  name="$(basename "$file")"
  # Work machines keep their own git identity, never the personal one
  if [[ "$PROFILE" == "work" && "$name" == ".gitconfig" ]]; then
    continue
  fi
  ln -sf "$file" "$HOME/$name"
done < <(find "$REPO_CONFIG_DIR" -mindepth 1 -maxdepth 1 -type f -print0)

# Top-level directories in config/ are linked into ~/.config
mkdir -p "$HOME/.config"
while IFS= read -r -d '' dir; do
  target="$HOME/.config/$(basename "$dir")"
  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -d "$target" ]]; then
    mv "$target" "$target.backup-$(date +%s)"
  fi
  ln -s "$dir" "$target"
done < <(find "$REPO_CONFIG_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
