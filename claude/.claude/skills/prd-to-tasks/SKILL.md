---
name: prd-to-tasks
description: Break a PRD into independently-grabbable tasks saved as tasks.json in the feature folder. Use when user wants to convert a PRD to tasks, create implementation tickets, or break down a PRD into work items.
---

# PRD to Tasks

Break a PRD into independently-grabbable tasks using vertical slices (tracer bullets), saved as `tasks.json` in the feature folder.

## Process

### 1. Locate the PRD

Look for `prd.md` in `~/.claude/work/features/<feature-name>/`. Ask the user for the feature name if not obvious from context.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** tasks. Each task is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Write tasks.json and progress.txt

Write `tasks.json` and an empty `progress.txt` to the same feature folder (`~/.claude/work/features/<feature-name>/`).

The file is an array of tasks. **It is unacceptable to remove or edit existing entries once written — only add new entries or flip `passes` from `false` to `true`.**

```json
[
  {
    "category": "functional | ui | edge-case | permissions | data",
    "type": "HITL | AFK",
    "whatToBuild": "End-to-end behavior description of this vertical slice",
    "blockedBy": [],
    "userStories": [3, 7],
    "description": "What this scenario verifies",
    "steps": [
      "Step 1 — setup or precondition",
      "Step 2 — action",
      "Step 3 — expected result",
      "Step 4 — (for ui category) verify the UI renders correctly and matches expected behavior"
    ],
    "passes": false
  }
]
```

- **category**: one of `functional`, `ui`, `edge-case`, `permissions`, `data`
- **type**: `HITL` (requires human interaction, e.g. architectural decision or design review) or `AFK` (can be implemented without human interaction). Prefer AFK.
- **whatToBuild**: concise description of the end-to-end behavior to implement, not layer-by-layer
- **blockedBy**: array of `description` strings of other tasks that must complete first (empty array if none)
- **userStories**: array of user story numbers from the PRD that this task addresses
- **description**: concise statement of what the scenario verifies
- **steps**: ordered list — include preconditions, actions, and verifications. For `ui` category tasks, always include a final step that verifies the UI renders correctly.
- **passes**: always starts as `false`

Cover all aspects of the feature thoroughly. Each task should be independently verifiable.
