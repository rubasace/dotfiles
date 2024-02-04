echo "Configuring Mac OS..."

# Show hidden files
defaults write com.apple.Finder AppleShowAllFiles true
killall Finder

## Disable Spotlight
sudo mdutil -a -i off

echo "Done"
