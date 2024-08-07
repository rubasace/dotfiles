echo "Configuring Mac OS..."

# Show hidden files
defaults write com.apple.Finder AppleShowAllFiles true
killall Finder

# Disable Spotlight
sudo mdutil -a -i off

# Enable git commit signing by default
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global user.signingkey ~/.ssh/id_rsa.pub


echo "Done"
