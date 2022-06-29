export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_COMPLETIONS_DIR="$ZSH_CONFIG_DIR/completions"

mkdir -p ${ZSH_COMPLETIONS_DIR}

# Load seperated config files
for conf in "${ZSH_CONFIG_DIR}/"*.zsh; do
  source "${conf}"
done
unset conf