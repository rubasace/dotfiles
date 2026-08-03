# Base profile: tools that belong on every machine, including work ones.
# Profile-specific software lives in the Brewfile.personal / Brewfile.work
# overlays; casks that need a privileged installer live in the *.sudo variants.
# Restore with: install.sh (combines the right files for the machine profile)

tap "sdkman/tap"

# --- Shell ---
brew "powerlevel10k"
brew "zsh-syntax-highlighting"
brew "fzf"
brew "lsd"
brew "watch"
brew "wget"
brew "jq"
brew "yq"

# --- Dev toolchains ---
brew "gh"
brew "maven"
brew "node"
brew "pyenv"
brew "sdkman-cli"

# --- Kubernetes / infra ---
brew "helm"
brew "kubectx"
brew "kubernetes-cli"
brew "kustomize"

# --- CLI utilities ---
brew "mas"

# --- Fonts ---
cask "font-meslo-lg-nerd-font"

# --- Desktop ---
cask "betterdisplay"
cask "google-chrome"
cask "iterm2"
cask "jetbrains-toolbox"
cask "karabiner-elements"
cask "keycastr"
cask "loop"
cask "obsidian"
cask "postman"
cask "raycast"
cask "spotify"
cask "sublime-text"
cask "wispr-flow"

# --- Mac App Store ---
mas "Amphetamine", id: 937984704
