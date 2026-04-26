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
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- NVM ---
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

alias claudsp="claude --dangerously-skip-permissions"

# Claude CLI function - automatically finds latest extension version
claude() {
  local claude_path=$(find ~/.vscode/extensions -name "anthropic.claude-code-*" -type d | sort -V | tail -1)/resources/native-binary/claude
  if [[ -f "$claude_path" ]]; then
    "$claude_path" --dangerously-skip-permissions "$@"
  else
    echo "Claude binary not found"
    return 1
  fi
}


# nvm initialization
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
      # nvm install --reinstall-packages-from=node node
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# --- Tools ---
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# --- Local overrides (not tracked in git) ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# --- Aliases ---
alias claudsp='claude --dangerously-skip-permissions'
alias reload="source ~/.zshrc"
alias zshconfig="code ~/.zshrc"

# Let nvm manage the Node.js path dynamically
export PATH="/Users/neriyarden/.local/bin:$PATH"
command -v yarn >/dev/null 2>&1 && export PATH="$PATH:$(yarn global bin 2>/dev/null)"
