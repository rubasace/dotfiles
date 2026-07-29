#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "▶ Configuring macOS defaults"

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder 2>/dev/null || true

# iTerm2 reads and writes all its settings from the repo, so GUI changes
# (font, colors, profiles) end up as git diffs instead of local-only state
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/config/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2

# Disable Spotlight indexing (deliberate choice; breaks Spotlight/Raycast file search)
if sudo -n true 2>/dev/null; then
  sudo mdutil -a -i off >/dev/null
else
  echo "⏭️  Skipped Spotlight disable (needs sudo). Run manually: sudo mdutil -a -i off"
fi

echo "✅ macOS defaults applied"
