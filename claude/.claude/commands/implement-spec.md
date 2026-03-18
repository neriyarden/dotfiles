---
description: "Read SPEC.md and interview user in detail about technical implementation, UI/UX, concerns, and tradeoffs until spec is complete"
allowed-tools: "Read, Write, Edit, AskUserQuestion"
---

# Implement Spec Interview

You are conducting an in-depth specification interview. Your goal is to identify gaps, ambiguities, and unaddressed concerns in the spec, then interview the user until the specification is complete enough for implementation.

## Step 1: Read the Current Spec

Read `.claude/SPEC.md` to understand the current state of the specification.

## Step 2: Analyze for Gaps

After reading, analyze the spec for:

### Technical Gaps

- Data flow and state management unclear?
- API contracts/interfaces undefined?
- Error handling strategies missing?
- Caching/performance considerations absent?
- Database/storage implications not addressed?
- Integration points with existing code unclear?

### UI/UX Gaps

- User flows incomplete?
- Loading states undefined?
- Error states and messaging missing?
- Empty states not considered?
- Responsive behavior unspecified?
- Accessibility requirements absent?
- Edge cases in user interaction?

### Tradeoff Gaps

- Complexity vs simplicity decisions needed?
- Performance vs maintainability choices?
- Scope decisions unclear (MVP vs full)?
- Build vs reuse decisions?

### Concern Gaps

- Security implications not addressed?
- Scalability considerations missing?
- Testing strategy undefined?
- Backwards compatibility issues?
- Migration path if needed?

## Step 3: Interview the User

Use `AskUserQuestion` to ask about identified gaps. Guidelines:

- **Be specific**: Don't ask "what about error handling?" Ask "When the API returns a 403, should we show an inline error, redirect to login, or show a modal?"
- **Be non-obvious**: Skip questions with obvious answers. Focus on decisions that require user input.
- **Prioritize**: Start with blocking questions that affect architecture, then move to details.
- **Batch wisely**: Group related questions (2-4 per ask) but don't overwhelm.
- **Provide options**: When possible, offer concrete choices with tradeoffs explained.

During the interview, also **proactively suggest optimizations and improvements** the user may not have considered — performance wins (caching, lazy loading, memoization), UX polish (optimistic updates, skeleton loaders, transitions), architectural improvements (reusable patterns, better abstractions), and reliability gains (retry logic, graceful degradation). Present these as brief suggestions with rationale — don't push, just surface ideas worth considering.

Continue interviewing until:

- All critical implementation decisions are captured
- Edge cases are addressed
- The spec is detailed enough that another developer could implement it without guessing

## Step 4: Update the Spec

Write the refined specification back to `.claude/SPEC.md`, incorporating all decisions from the interview. Structure the updated spec clearly with sections for:

- Overview/Goal
- Technical Implementation Details
- UI/UX Specifications
- Edge Cases & Error Handling
- Open Questions (if any remain)
- Out of Scope (explicitly)

## Begin

Start by reading the spec file now.
