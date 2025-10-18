echo "Installing Mac OS work packages..."

set -e

if ! which brew > /dev/null; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed"
fi

# Compatibility with amd64
softwareupdate --install-rosetta --agree-to-license

brew install watch
brew install fzf
brew install kubectx
brew install kubernetes-cli
brew install lsd
brew install kubectl
brew install google-cloud-sdk
brew install maven
brew install node
brew install nvm
brew install gpg
brew install wget
brew install jq
brew install jmeter
brew install kustomize
brew install cloud-sql-proxy
brew install pyenv
brew install sops
brew install age

brew tap sdkman/tap
brew install sdkman-cli

brew install --cask font-meslo-lg-nerd-font

brew install --cask iterm2
brew install --cask jetbrains-toolbox
brew install --cask raycast
brew install --cask sublime-text
brew install --cask obsidian
brew install --cask gpg-suite
brew install --cask postman
brew install --cask font-smoothing-adjuster
brew install --cask alt-tab
brew install --cask keycastr


echo "Done"
