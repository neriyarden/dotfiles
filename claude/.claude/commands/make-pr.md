---
description: "Create a PR from current changes - analyzes changes, creates branch, commits, and creates PR"
allowed-tools: [Read, Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git checkout:*), Bash(git pull:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*), Bash(git stash:*), Bash(git log:*)]
---

Create a pull request from current uncommitted changes.

## Flow

1. **Check current state:**
   - Run `git branch --show-current` to get current branch
   - Run `git status` to see changed files
   - Run `git diff` to understand the changes
   - Run `git log --oneline -5` to see recent commit style

2. **Determine base branch:**
   - If on `main` or `master`, that's the base
   - If on a feature branch, ask user if they want to PR from current branch or switch to main first

3. **Analyze changes to determine:**
   - PR type: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`
   - Brief description of what changed
   - Logical commit groupings (if multiple concerns)

4. **If on main/master, create feature branch:**
   - Pull latest: `git pull`
   - Create branch: `[type]/[brief-kebab-description]`
   - Examples: `feat/add-user-auth`, `fix/login-validation`, `refactor/api-client`

5. **Create commits:**
   - Group related changes into logical commits
   - Commit message format:
     ```
     [type]: [description]

     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

6. **Push and create PR:**
   - Push branch: `git push -u origin [branch-name]`
   - Create PR with `gh pr create`:
     - Title: `[type]: [description]`
     - Body:
       ```
       ## Summary
       [1-2 sentence description]

       ## Changes
       - [bullet points of what changed]

       🤖 Generated with [Claude Code](https://claude.com/claude-code)
       ```

7. **Return the PR URL to the user**

## Staged-Only Mode

If user says "staged only", "only staged", or "ignore unstaged":
- Use `git diff --cached` instead of `git diff`
- Do NOT run `git add` - only commit what's already staged
- Stash unstaged changes before switching branches, restore after
