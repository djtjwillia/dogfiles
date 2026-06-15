DOT_EDITOR='dv'

#Aliases
alias cls='clear'

#sourcing
alias szrc='source ~/.zshrc'
alias sgc='source ~/.gitconfig'

#history
alias hgrep='history 100 | grep --color=auto'

#app shortcuts
alias tf='terraform'
alias tg='terragrunt'
alias k='kubectl'
alias dv='devin-desktop'
alias cc='claude'
alias ccc='claude --continue'
alias ccr='claude --resume'

#troubleshooting
alias netshoot='kubectl run netshoot --rm -i --tty --image nicolaka/netshoot -- /bin/bash'

# color aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

#filesystem viewing
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias la='eza -a --icons'
alias lsd='ls -ald .*'
alias cat='bat --paging=never'

alias t='tree -C'
alias t1='tree -LC 1'
alias t2='tree -LC 2'
alias t3='tree -LC 3'
alias td1='tree -dLC 1'
alias td2='tree -dLC 2'
alias td3='tree -dLC 3'

#delete
alias rmd='rm -rf'

# tmux
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'
alias ts='sesh connect $(sesh list | fzf)'
alias dev='~/.local/bin/dev'


# argocd commands
alias argos='kubectl -n argocd get secret argocd-initial-admin-secret -o json | jq -r .data.password | base64 -d | cut -d % -f 1  | pbcopy'
alias argopf='argos; kubectl -n argocd  port-forward service/argocd-server 8085:443'

# Note that if omzsh is being used, there are a great number of pre-defined git aliases available
# A list of them can be viewed by running the following:
#       alias | grep git
#
# Additional ones can be added here and will be loaded
alias gs='git status'
# change some of the zsh aliases to better fit my use
alias gpu='git push --set-upstream origin $(git_current_branch)'
alias glo='git log --oneline --graph --decorate'
alias gcm='git commit --message'
alias lga="git log --abbrev-commit --decorate --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset)%C(white)%s %C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias lg="git log --abbrev-commit --decorate --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset)%C(white)%s %C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
# in place of prior, longer aliases use these from zsh
# gsw - git switch
# gswc - git switch -c
# ga - git add
# gf - git fetch
# grb - git rebase
# gpr - git pull --rebase
# gd - git diff
# gds - git diff staged
# gdb - git branch delete
# gsta - git stash push
# gstaa - git stash apply

# auto-complete for listing contents of the defined git workspace  
# allows users to quickly get to git projects from any directory
gws () {
   cd $GIT_WORKSPACE/$1; tree -dCL 1
}

_gws () {
   ((CURRENT == 2)) &&
   _files -/ -W $GIT_WORKSPACE
}
compdef _gws gws