# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
BINDINGS_FILE="/usr/local/opt/fzf/shell/key-bindings.zsh"
if [ -f $BINDINGS_FILE ]; then
  source $BINDINGS_FILE
fi
