export ZSH_CONFIG_DIR="$HOME/.config/zsh"

# Load seperated config files
for conf in "${ZSH_CONFIG_DIR}/"*.zsh; do
  source "${conf}"
done
unset conf
