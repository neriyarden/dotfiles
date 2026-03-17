# dotfiles

Personal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup on a new machine

### Fresh machine (no existing configs worth keeping)

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
bash setup.sh
```

`setup.sh` installs Homebrew + all packages from the Brewfile, installs OMZ plugins, backs up any conflicting local files, and symlinks all modules into `$HOME`.

### Machine with existing configs you want to keep

If the machine already has good configs (e.g. a work Mac), import them into the repo first before symlinking:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
bash import.sh       # copies local configs into the repo
git diff             # review what changed
git add -p && git commit -m "import: work mac configs" && git push
bash setup.sh        # now symlink the updated repo configs
```

`import.sh` will copy your local configs into the dotfiles repo without touching anything else. After reviewing and pushing, run `setup.sh` to complete the setup.

## Modules

| Module | What it manages |
|--------|----------------|
| `claude` | `~/.claude/` (CLAUDE.md, settings.json) |
| `zsh` | `~/.zshrc` |
| `vscode` | VS Code settings and keybindings |
| `ssh` | `~/.ssh/config` (hosts/aliases only, no keys) |

## Keeping extensions up to date

After installing or removing VS Code extensions, refresh the list:

```bash
code --list-extensions > ~/dotfiles/vscode/extensions.txt
```

Then commit and push as usual.

## Syncing changes

Edit files in `~/dotfiles/` (or directly via the symlinks — same thing). Then:

```bash
cd ~/dotfiles
git add -p
git commit -m "..."
git push
```
