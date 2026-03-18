#!/usr/bin/env bash
# import.sh — copy local configs INTO the dotfiles repo (run before setup.sh on a new machine)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_if_exists() {
  local src="$1"
  local dest="$2"
  if [[ -L "$src" ]]; then
    echo "  ~ $src (already symlinked, skipped)"
  elif [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  ✓ $src"
  else
    echo "  - $src (not found, skipped)"
  fi
}

copy_dir_if_exists() {
  local src="$1"
  local dest="$2"
  if [[ -L "$src" ]]; then
    echo "  ~ $src (already symlinked, skipped)"
  elif [[ -d "$src" ]]; then
    mkdir -p "$dest"
    cp -r "$src"/ "$dest"/
    echo "  ✓ $src"
  else
    echo "  - $src (not found, skipped)"
  fi
}

echo "--- Importing local configs into dotfiles repo ---"

copy_if_exists    "$HOME/.claude/CLAUDE.md"                                              "$DOTFILES_DIR/claude/.claude/CLAUDE.md"
copy_if_exists    "$HOME/.claude/settings.json"                                          "$DOTFILES_DIR/claude/.claude/settings.json"
copy_dir_if_exists "$HOME/.claude/commands"                                              "$DOTFILES_DIR/claude/.claude/commands"
copy_dir_if_exists "$HOME/.claude/agents"                                                "$DOTFILES_DIR/claude/.claude/agents"
copy_dir_if_exists "$HOME/.claude/hooks"                                                 "$DOTFILES_DIR/claude/.claude/hooks"
copy_dir_if_exists "$HOME/.claude/skills"                                                "$DOTFILES_DIR/claude/.claude/skills"
copy_if_exists "$HOME/.zshrc"                                                         "$DOTFILES_DIR/zsh/.zshrc"
copy_if_exists "$HOME/Library/Application Support/Code/User/settings.json"            "$DOTFILES_DIR/vscode/Library/Application Support/Code/User/settings.json"
copy_if_exists "$HOME/Library/Application Support/Code/User/keybindings.json"         "$DOTFILES_DIR/vscode/Library/Application Support/Code/User/keybindings.json"

echo ""
echo "Done. Review changes with 'git diff', then commit and push."
echo "Run setup.sh when you're happy with what's in the repo."
