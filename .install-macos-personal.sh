echo "Installing Mac OS personal packages..."

brew install kubeseal
brew install wireguard-tools
brew install mas

brew install --cask karabiner-elements
brew install --cask skype
brew install --cask bartender
brew install --cask discord
brew install --cask microsoft-remote-desktop

# Amphetamine
mas install 937984704
# Magnet
#mas install 441258766
# Wireguard
mas install 1451685025


echo "Done"