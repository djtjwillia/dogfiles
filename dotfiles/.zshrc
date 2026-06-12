DOT_FILES_SRC="/Users/taylor/Code/liatrio/dogfiles-main/dotfiles"
#omzsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="awesomepanda"
plugins=(
  git
  aws
  docker
  iterm2
  terraform
  python
  kubectl
)
source $ZSH/oh-my-zsh.sh

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

# Added by Windsurf
export PATH="/Users/taylor/.codeium/windsurf/bin:$PATH"

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
