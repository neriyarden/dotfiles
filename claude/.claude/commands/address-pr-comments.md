---
description: "Fetch PR review comments (inline and issue-level) and interactively triage each one with the user before implementing fixes"
argument-hint: "<pr-number-or-url-or-branch>"
allowed-tools: "Read, Edit, Write, Bash(gh pr view:*), Bash(gh repo view:*), Bash(gh api:*), Bash(gh pr diff:*), Bash(gh pr checkout:*), Bash(git diff:*), Bash(git status:*), Bash(git checkout:*), Bash(git log:*), Bash(git remote:*), Bash(gh api repos:*), AskUserQuestion, Glob, Grep"
---

Arguments: $ARGUMENTS

## Overview

Interactively resolve PR comments — both inline review comments (file-level) and issue-level comments (PR Conversation tab). For each: show context, propose a fix, then let the user decide.

## Step 1: Parse the PR argument

- `$ARGUMENTS` can be a PR number (`123`), a full URL (`https://github.com/.../pull/123`), or a branch name
- Extract the PR number. If it's a URL, parse the number from it. If it's a branch name, use `gh pr view <branch> --json number -q .number` to get the number.
- Store the PR number for subsequent steps.

## Step 2: Fetch PR comments

### 2a. Fetch inline review comments (via GraphQL)

Use the repo from the current git remote.

Use this GraphQL query to get all review threads with their resolved status and comment data in one call:

```
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!, $cursor: String) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100, after: $cursor) {
          pageInfo { hasNextPage endCursor }
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
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner='{owner}' -f repo='{repo}' -F pr={pr_number}
```

**If `pageInfo.hasNextPage` is true**, re-run the query passing `-f cursor='{endCursor}'` to fetch the next page. Repeat until all threads are fetched.

**Keep only threads where `isResolved` is `false`.**

### 2b. Fetch issue-level comments

Run this command to get all issue-level comments (the general comments on the PR Conversation tab):

```
gh api repos/{owner}/{repo}/issues/{pr_number}/comments --paginate
```

Each comment object has: `id`, `user.login`, `body`, `created_at`.

**Filter out trivial and bot comments:**

- Skip comments from bot users (`user.type === "Bot"`)
- Skip comments where `body` is under 20 characters and doesn't contain a question mark
- Skip comments where `body` matches common trivial patterns (case-insensitive): "LGTM", "looks good", "👍", ":+1:", "ship it", "+1", "nice", "thanks", "approved"

Keep the remaining as **issue-level comments**. For each, record: `comment_id`, `author`, `body`, `created_at`.

### 2c. Check if there's anything to do

If there are no unresolved inline comments AND no non-trivial issue-level comments, inform the user and stop.

## Step 3: Group and order comments

### Inline comments first
Group unresolved inline comments by their `path` (file path). Within each file, order by line number. This provides natural context flow.

### Issue-level comments second
After all inline comments, present issue-level comments in chronological order (by `created_at`).

### Splitting issue-level comments into action items
When presenting an issue-level comment, use judgment to decide whether to split it into separate action items:
- **Split** when the body contains clearly distinct items: numbered lists, bullet points, or obviously separate topics
- **Don't split** when the body is ambiguous prose, a single cohesive thought, or when the boundaries between items are unclear

Each split item is triaged independently. Unsplit comments are triaged as a single item.

## Step 4: Checkout the PR branch

Before showing comments, make sure you're on the PR branch so you can read the actual code:

```
gh pr checkout {pr_number}
```

Or if already on the branch, skip this.

## Step 5: Iterate over each comment

Follow the ordering from Step 3. For each item:

### 5a. Show context

- **Inline**: `### Comment by @{author} on \`{path}\`:{line}` + quoted body + last ~10 lines of `diffHunk`
- **Issue-level**: `### Comment by @{author} (issue-level)` + quoted full body. If split into action items, show full body first, then present each item individually.

### 5b. Read and analyze

- Read the relevant file lines (use `offset`/`limit` for large files) or files referenced by issue-level comments
- Formulate a **specific proposed fix** — concrete, not vague: "Change X to Y", "Extract into `parseUserInput()`", "Add null check before `.foo`"
- If the comment is too vague to act on, say so honestly

### 5c. Ask user

Show `**My proposed fix:** {description}`, then AskUserQuestion:
- **"Apply this fix"** → add to implementation list
- **"Skip"** → move on
- (Other) → record user's instructions instead

## Step 6: Summary before implementing

After triaging ALL comments (both inline and issue-level), show a summary:

```
## Triage Summary

**Will fix ({n}):**
1. `{file}:{line}` — {what you'll do}
2. [Issue comment by @{author}] — {what you'll do}
3. ...

**Skipped ({n}):**
1. `{file}:{line}` — {reviewer comment summary}
2. [Issue comment by @{author}] — {comment summary}
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

## Step 8: Offer to reply to each comment

Go through **all** comments (addressed and skipped), one by one. For each:

1. Re-show the original comment (same format as Step 5a)
2. Suggest a concise reply: `**Suggested reply:** "Done — extracted into \`parseUserInput()\` at line 45."`
3. AskUserQuestion: **"Post suggested reply"** / **"Skip"** / (Other — user provides custom reply)
4. Post replies using heredocs to avoid quoting issues:
   - **Inline**: `gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/replies -f body="$(cat <<'EOF' ... EOF )"`
   - **Issue-level** (new top-level comment — prefix with `> @{author} wrote: ...` for context): `gh api repos/{owner}/{repo}/issues/{pr_number}/comments -f body="$(cat <<'EOF' ... EOF )"`

## Important Notes

- **Never auto-resolve comments on GitHub** — that's the user's job after reviewing
- **Never modify generated code** (`src/generated/`) — flag these and skip
- **Be concrete in proposals** — "refactor this" is not a proposal, "extract lines 45-52 into a `parseUserInput()` function" is
- If a comment references code you can't find or understand, say so honestly instead of guessing