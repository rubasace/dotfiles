export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export DOTFILES_DIR="$(dirname "$(dirname "$(readlink -f "$HOME/.zshrc")")")"

# Load separated config files
for conf in "${ZSH_CONFIG_DIR}"/*.zsh; do
  source "${conf}"
done
unset conf
