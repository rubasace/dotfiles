#!/usr/bin/env bash
# One-off cleanup of packages that predate the Brewfile. Review before running:
# every line here uninstalls something that is duplicated, dead, or replaced by
# an entry in the Brewfile. Type flags are mandatory: brew resolves bare names
# through cask renames and prefers casks, so `brew uninstall docker` can hit
# the docker-desktop CASK instead of the formula.
set -uo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "▶ Skype was discontinued in May 2025"
brew uninstall --cask skype

echo "▶ Bartender was replaced by Ice (jordanbaird-ice)"
brew uninstall --cask bartender

echo "▶ Mounty is abandoned; MountMate covers NTFS mounting"
brew uninstall --cask mounty

echo "▶ microsoft-remote-desktop was renamed windows-app"
brew uninstall --cask microsoft-remote-desktop

echo "▶ docker formula (CLI only) is redundant with Docker Desktop's bundled CLI"
brew uninstall --formula docker

echo "▶ syncthing formula + service is redundant with the Syncthing.app cask"
brew services stop syncthing
brew uninstall --formula syncthing

echo "▶ nvm was never used (no node versions installed); node comes from brew"
brew uninstall --formula nvm

echo "▶ rustup was never initialized; the rust formula is the one in use"
brew uninstall --formula rustup

echo "▶ 'cask' formula (an Emacs tool) looks like an accidental install; drags emacs in"
brew uninstall --formula cask

echo "▶ pinentry-mac only served the old autoupdate sudo popup"
brew uninstall --formula pinentry-mac

echo "▶ Removing orphaned dependencies"
brew autoremove

echo "▶ Removing taps with nothing installed from them (ngrok cask now lives in homebrew/cask)"
brew untap fluxcd/tap gromgit/fuse jeffreywildman/virt-manager lihaoyun6/tap siderolabs/tap anomalyco/tap ngrok/ngrok 2>/dev/null

cat <<'EOF'

Manual leftovers to review (not touched by this script):
  - gpg-suite / GPG Keychain + MacGPG2 (/usr/local/MacGPG2): only needed if you
    still use GPG keys for something other than git signing (git uses SSH now).
  - PostgreSQL 12 (/Applications/PostgreSQL 12, /Library/LaunchDaemons/postgresql-12.plist)
  - Python 3.12 framework installer (/Applications/Python 3.12, /usr/local/bin/python3*)
  - Adobe Creative Cloud residue (com.adobe.* launch agents/daemons)
EOF
