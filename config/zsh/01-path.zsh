eval "$(/opt/homebrew/bin/brew shellenv)"

export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)

# JetBrains Toolbox CLI launchers (idea, webstorm, ...)
path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts")
