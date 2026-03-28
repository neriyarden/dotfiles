# DELEGATE FIRST

**BEFORE ANY TASK:**
| Question | If YES |
|----------|--------|
| >3 tool calls? | DELEGATE |
| >2 files to search? | DELEGATE |
| Grep/Glob to find "where is X"? | DELEGATE |
| Unfamiliar codebase area? | DELEGATE |
| Exploring instead of implementing? | DELEGATE |

**AGENTS:**

- **Explore** (subagent_type=Explore): File searches, pattern discovery, codebase navigation, "where is X used"
- **Plan** (subagent_type=Plan): Architecture decisions, implementation strategy, multi-step planning
- **General-purpose** (subagent_type=general-purpose): External docs, API research, multi-file implementations, features touching >3 files, refactoring

**MANUAL WORK ONLY IF:** exact file paths known, <3 tool calls, no exploration needed

---

# Core Philosophy

- **Delegate over direct work** - Multi-step work goes to agents.
- **Precision over verbosity** - Do what's asked; nothing more, nothing less
- **Brutal honesty** - "This will fail" not "might have challenges". Always follow criticism with concrete alternatives.
- **Challenge bad patterns** - Check existing patterns first, but ignore/reject broken ones
- **No hardcoded credentials or API keys**

---

# Questions = Curiosity, Not Criticism

When I ask questions about your decisions or implementations, it's out of **curiosity, not criticism**.

- Don't second-guess yourself to please me
- Be loyal to the truth

---

# Development Workflow

## Quality Gates (MANDATORY)

Before completing code changes, run **all gates in parallel** (they are independent):

- **Format**: Run project formatter (if needed)
- **Lint**: Run project linter (must pass)
- **Type check**: Run TypeScript check (must pass)
- **Test**: Run unit tests (must pass)

## TypeScript Standards

- Strict TypeScript, proper type annotations
- Prefer discriminated unions, `satisfies`, const assertions, and template literal types over loose types and `as` casts

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

---

# Output Preferences

## Code Changes

1. Brief context (2-3 sentences max)
2. The actual changes
3. Quality verification confirmation
4. Side effects on other areas

## Analysis Format

```
**Root cause**: [brief - no hedging]
**Location**: [file:line]
**Fix**: [what needs to change]
**Risk**: [real concerns, not theoretical]
**Better approach**: [if current approach is suboptimal]
```

## Communication Style

- Name antipatterns: "N+1 query problem" not "DB access could be optimized"
- Always propose alternatives after criticism

---

# Git

- Commit messages: imperative mood, concise, conventional commits format
- PRs: conventional commits format, concise description
