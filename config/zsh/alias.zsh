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

ls_command="lsd --group-dirs=first"

alias ls="${ls_command}"
alias ll="${ls_command} -l"
alias la="${ls_command} -a"
alias lla="${ls_command} -la"
alias lt="${ls_command} -a --tree"
alias lt1="${ls_command} -a --tree --depth 1"
alias lt2="${ls_command} -a --tree --depth 2"
alias lt3="${ls_command} -a --tree --depth 3"
alias lt4="${ls_command} -a --tree --depth 4"
alias lt5="${ls_command} -a --tree --depth 5"
alias lsn='/bin/ls'


alias gitp='git push origin'

gitc() {
	if [ -n "$1" ]
    then
    	git commit -m "$1"
    else
        echo "A commit message has to be passed as argument"
    fi 
}

gittag(){
	if [ -n "$1" ]
    then
    	tagMessage=${2:-"Release version $1"}
    	git tag -a $1 -m "${tagMessage}"
    else
        echo "A tag identifier has to be passed as argument"
    fi 
}

alias mc="mvn clean"
alias mcp="mvn clean package"
alias mci="mvn clean install"

msv() {	
	if [ -n "$1" ]
    then
    	generateBackupPoms=${2:-true}
        mvn versions:set -DnewVersion="$1" -DgenerateBackupPoms="$generateBackupPoms"
    else
        echo "A version has to be passed as argument"
    fi 
}


alias subl='open -a "/Applications/Sublime Text.app"'
