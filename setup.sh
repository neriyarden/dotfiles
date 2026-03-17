#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES=(claude zsh vscode ssh)

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all packages from Brewfile
echo "--- Running brew bundle ---"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Install stow if not present
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  brew install stow
fi

# Install OMZ plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Ensure parent directories exist for stow targets
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/Library/Application Support/Code/User"

# Back up any existing non-symlink files before stowing; skip if already correctly symlinked
backup_if_needed() {
  local target="$1"
  if [[ -L "$target" && "$(readlink "$target")" == "$DOTFILES_DIR"* ]]; then
    return  # already points to dotfiles, nothing to do
  fi
  if [[ -e "$target" ]]; then
    local backup="${target}.bak-$(date +%Y%m%d%H%M%S)"
    echo "Backing up $target -> $backup"
    mv "$target" "$backup"
  fi
}

# Files that stow will manage (relative to $HOME)
declare -A MODULE_FILES
MODULE_FILES[claude]=".claude/CLAUDE.md .claude/settings.json"
MODULE_FILES[zsh]=".zshrc"
MODULE_FILES[vscode]="Library/Application Support/Code/User/settings.json Library/Application Support/Code/User/keybindings.json"
MODULE_FILES[ssh]=".ssh/config"

for module in "${MODULES[@]}"; do
  echo "--- Stowing module: $module ---"

  # Back up files that would conflict
  IFS=' ' read -ra files <<< "${MODULE_FILES[$module]}"
  for rel_path in "${files[@]}"; do
    backup_if_needed "$HOME/$rel_path"
  done

  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$module"
done

# Install VS Code extensions
if command -v code &>/dev/null; then
  echo "--- Installing VS Code extensions ---"
  while IFS= read -r ext; do
    code --install-extension "$ext" --force &>/dev/null && echo "  ✓ $ext" || echo "  ✗ $ext (failed)"
  done < "$DOTFILES_DIR/vscode/extensions.txt"
else
  echo "VS Code CLI not found — skipping extensions. Install 'code' command from VS Code and re-run."
fi

echo ""
echo "Done. All modules stowed."
