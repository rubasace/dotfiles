echo "Installing Mac OS packages"

if ! which brew > /dev/null; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed"
fi

brew install fzf
brew install kubectx
brew install kubernetes-cli
brew install lsd
brew install kubectl
brew install google-cloud-sdk
brew install maven
brew install node
brew install nvm

brew tap sdkman/tap
brew install sdkman-cli

brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font

brew install --cask iterm2
brew install --cask google-chrome
brew install --cask jetbrains-toolbox
brew install --cask raycast
brew install --cask slack
brew install --cask sublime-text
brew install --cask parallels
brew install --cask obsidian
brew install --cask podman-desktop