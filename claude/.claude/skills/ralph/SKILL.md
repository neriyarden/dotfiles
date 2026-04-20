---
name: ralph
description: Execute tasks from tasks.json one at a time inside a Claude Code session. Use when user wants to implement feature tasks interactively, mentions "ralph", or wants to work through tasks.json with visibility and control.
---

# Ralph — Interactive Task Runner

Work through `~/.claude/work/features/<feature-name>/tasks.json` one task at a time. The user sees all progress and can intervene.

## Process

### 1. Load the feature

Ask the user for the feature name if not obvious from context. Read `prd.md`, `tasks.json`, and `progress.txt` from `~/.claude/work/features/<feature-name>/`.

If `tasks.json` doesn't exist, stop and tell the user to run `/prd-to-tasks` first.

### 2. Pick the next task

Find the highest-priority task where `passes` is `false`. You decide priority — it's not necessarily the first in the list. **Respect `blockedBy`** — never pick a task whose blockers have not all passed. Present the chosen task to the user and confirm before starting.

### 3. Implement the task

Build what `whatToBuild` describes using **TDD red-green-refactor**: write one test, make it pass, repeat. Never write all tests first then all implementation. Follow the `steps` to verify correctness. See `/tdd` for methodology.

### 4. Quality gates

Run the project's quality gates **in parallel** — all must pass:
- Format
- Lint
- Type check
- Tests

### 5. UI verification

If the task's `category` is `ui`, check that the UI looks correct and functions correctly with `/agent-browser`.

### 6. Update state

- Flip `passes` to `true` for the completed task in `tasks.json`. **Do not edit or remove any other entries.**
- Append progress to `~/.claude/work/features/<feature-name>/progress.txt` — leave a note for the next person working in the codebase.
- Make a git commit for the completed task.

### 7. Check completion

Read `tasks.json` and check if **every** entry has `passes: true`.

- **Not complete**: Ask the user if they want to continue to the next task. If yes, go back to step 2.
- **All complete**:
  1. Plan a PR strategy. Each PR should be as small and scoped as possible. Avoid dependency PRs if possible; if there are dependency PRs, clearly indicate merge order.
  2. Create the PRs as **drafts** using `/make-pr`.
