# Homebrew installs completions into site-functions but doesn't add it to fpath
fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)

autoload -Uz compinit && compinit

# Make autocompletion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
