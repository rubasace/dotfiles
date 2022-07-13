# TODO: add tools installation

brew install --cask iterm2
brew install --cask google-chrome
brew install lsd
brew install fzf
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
brew install kubectl
mkdir -p $HOME/zsh-plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/zsh-plugins/zsh-syntax-highlighting
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
brew install --cask alfred
