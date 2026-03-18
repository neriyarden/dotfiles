---
description: "Fetch PR review comments and interactively triage each one with the user before implementing fixes"
argument-hint: "<pr-number-or-url-or-branch>"
allowed-tools: "Read, Edit, Write, Bash(gh pr view:*), Bash(gh api:*), Bash(gh pr diff:*), Bash(gh pr checkout:*), Bash(git diff:*), Bash(git status:*), Bash(git checkout:*), Bash(git log:*), Bash(git remote:*), AskUserQuestion, Glob, Grep"
---

Arguments: $ARGUMENTS

## Overview

Interactively resolve PR review comments. For each comment: show context, propose a fix, then let the user decide.

## Step 1: Parse the PR argument

- `$ARGUMENTS` can be a PR number (`123`), a full URL (`https://github.com/.../pull/123`), or a branch name
- Extract the PR number. If it's a URL, parse the number from it. If it's a branch name, use `gh pr view <branch> --json number -q .number` to get the number.
- Store the PR number for subsequent steps.

## Step 2: Fetch PR review comments

Run this command to get all review comments (NOT issue-level comments):

```
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate
```

Use the repo from the current git remote.

**Filter to only unresolved comments:**

- From the comments endpoint, keep comments where `in_reply_to_id` is absent (these are top-level review comments, not replies)
- Cross-reference with the PR review threads: `gh api graphql` to check which threads are resolved

Use this GraphQL query to get resolved status:

```
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 1) {
              nodes {
                id
                databaseId
                body
                path
                line
                diffHunk
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner='{owner}' -f repo='{repo}' -F pr={pr_number}
```

This gives you each thread's `isResolved` status and the first comment (which is the review comment itself).

**Keep only threads where `isResolved` is `false`.**

If there are no unresolved comments, inform the user and stop.

## Step 3: Group comments by file

Group the unresolved comments by their `path` (file path). This provides natural context flow.

## Step 4: Checkout the PR branch

Before showing comments, make sure you're on the PR branch so you can read the actual code:

```
gh pr checkout {pr_number}
```

Or if already on the branch, skip this.

## Step 5: Iterate over each comment

For each unresolved comment, in order grouped by file:

### 5a. Show context

Display to the user:

```
### Comment by @{author} on `{path}`:{line}

> {comment body}

**Code context (from diff):**
{diffHunk - last ~10 lines for readability}
```

### 5b. Read the current file and analyze

- Read the actual file at the relevant lines
- Understand what the reviewer is asking for
- Formulate a **specific proposed fix** — not vague, but concrete: "Change X to Y" or "Extract this into a function called Z" or "Add null check before accessing .foo"

### 5c. Present proposal and ask user

Show your proposed fix to the user, then use AskUserQuestion:

```
**My proposed fix:** {concrete description of what you'd change}
```

Then ask with AskUserQuestion:

- **"Apply this fix"** — You will implement exactly what was proposed
- **"Skip"** — No changes, move to next comment
- (Other) — User provides their own approach

If user picks "Apply this fix" → add to the implementation list.
If user picks "Skip" → move on.
If user picks Other → record their instructions instead.

## Step 6: Summary before implementing

After triaging ALL comments, show a summary:

```
## Triage Summary

**Will fix ({n}):**
1. `{file}:{line}` — {what you'll do}
2. ...

**Skipped ({n}):**
1. `{file}:{line}` — {reviewer comment summary}
```

Ask the user to confirm before proceeding:

- **"Implement all"** — proceed with all fixes
- **"Let me adjust"** — user can change their mind on specific items
- (Other)

## Step 7: Implement fixes

For each approved fix, in file order:

1. Read the file (fresh, in case earlier fixes modified it)
2. Apply the change
3. Briefly confirm what was done

After all fixes are applied, show final summary of what changed.

## Important Notes

- **Never auto-resolve comments on GitHub** — that's the user's job after reviewing
- **Never modify generated code** (`src/generated/`) — flag these and skip
- **Be concrete in proposals** — "refactor this" is not a proposal, "extract lines 45-52 into a `parseUserInput()` function" is
- If a comment references code you can't find or understand, say so honestly instead of guessing
