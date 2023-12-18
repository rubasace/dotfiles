# Check if powerlevel10k repository exists

if [ ! -d "$HOME/powerlevel10k" ]; then
    echo "Cloning powerlevel10k repository..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
else
    echo "powerlevel10k repository already exists. Skipping clone."
fi

# Check if zsh-syntax-highlighting repository exists
if [ ! -d "$HOME/zsh-plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting repository..."
    mkdir -p $HOME/zsh-plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/zsh-plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting repository already exists. Skipping clone."
fi

if [ "$(uname)" = "Darwin" ]; then
    ./.configure-macos.sh
    ./.install-macos-work.sh
    ./.install-macos-personal.sh
fi

./link.sh