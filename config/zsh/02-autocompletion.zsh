# Enable zsh autocompletion
autoload -U compinit && compinit

# Make autocompletion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'