# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DOT_FILES_SRC="/Users/taylor/Code/projects/dogfiles/dotfiles"
#omzsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
  git
  zsh-autosuggestions    # ghost-text completion from history
  aws
  docker
  iterm2
  terraform
  python
  kubectl
  history-substring-search # up/down arrow searches history by prefix
  colored-man-pages      # colorizes man pages
)
source $ZSH/oh-my-zsh.sh

# ── Shell enhancements ────────────────────────────────────────
source <(fzf --zsh)
eval "$(zoxide init zsh)"

export EDITOR='code --wait'
export VISUAL=$EDITOR

#trim whitespace before adding commadns to history
setopt HIST_REDUCE_BLANKS
#allow prompt substitution
setopt prompt_subst

# source dogfiles custom config
source "$DOT_FILES_SRC/config.sh"

#load pyenv and pyenv-virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

#setup NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


source <(/Users/taylor/.kpv3-cli/bin/kpv3-cli source)
if ! [ -s /Users/taylor/.kpv3-cli/consent.yaml ]; then
    kpv3-cli consent
fi
if ! [ -s /Users/taylor/.kube/k8s-platform-v3 ]; then
    kpv3-cli kubeconfig -w
fi
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/taylor/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

#fzf config 
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --color=always --line-range=:50 {}"
'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"

# History config
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS      # don't record duplicate commands
setopt HIST_IGNORE_SPACE     # commands starting with space aren't recorded
setopt SHARE_HISTORY         # share history across all tmux panes/windows
setopt EXTENDED_HISTORY      # record timestamps

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
