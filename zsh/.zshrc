export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # disabled — starship handles the prompt

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# --- History ---
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"
[[ -d "/usr/local/opt/python@3.11" ]] && export PATH="/usr/local/opt/python@3.11/libexec/bin:$PATH"

# --- NVM ---
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Auto-switch Node version based on .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# --- Tools ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# --- Aliases ---
alias claudsp='claude --dangerously-skip-permissions'
alias reload="source ~/.zshrc"
alias zshconfig="code ~/.zshrc"
