echo "Installing Mac OS personal packages..."

brew tap domt4/autoupdate
# Update every 4 hours
brew install pinentry-mac
/opt/homebrew/bin/brew autoupdate start 14400 --upgrade --cleanup --immediate --sudo

brew install kubeseal
brew install wireguard-tools
brew install mas

brew install --cask karabiner-elements
brew install --cask skype
brew install --cask bartender
brew install --cask discord
brew install --cask microsoft-remote-desktop
brew install --cask autofirma
brew install --cask spotify
brew install --cask mqttx
brew install --cask chatgpt

# Amphetamine
mas install 937984704
# Magnet
#mas install 441258766
# Wireguard
mas install 1451685025


echo "Done"