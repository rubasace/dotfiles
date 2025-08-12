
 export PATH=$PATH:/opt/homebrew/bin
 eval "$(brew shellenv)"

export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)
eval "$(pyenv init --path)"