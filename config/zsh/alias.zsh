alias reload='source ~/.zshrc'

# Workaround to be able to watch when executing aliases, like `watch k get po`
alias watch='watch '

alias k=kubectl
compdef __start_kubectl k
source <(kubectl completion zsh)
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kla='kubectl logs --tail 999999999999'
alias klaf='kubectl logs --tail 999999999999 -f'
alias ke='kubectl exec -it'

ls_command=lsd

alias ls="${ls_command}"
alias ll="${ls_command} -l"
alias la="${ls_command} -a"
alias lla="${ls_command} -la"
alias lt="${ls_command} --tree"
alias lt1="${ls_command} --tree --depth 1"
alias lt2="${ls_command} --tree --depth 2"
alias lt3="${ls_command} --tree --depth 3"
alias lt4="${ls_command} --tree --depth 4"
alias lt5="${ls_command} --tree --depth 5"
alias lsn='/bin/ls'


alias subl='open -a "/Applications/Sublime Text.app"'
