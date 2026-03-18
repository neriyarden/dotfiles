#!/bin/bash
# ~/.claude/hooks/enforce-claude-md.sh
# Reminds Claude to follow CLAUDE.md before every action

# Output to stdout - this gets added to Claude's context
cat << 'EOF'
<system-reminder>
STOP. Before proceeding, verify your next action follows CLAUDE.md:
- Run through the MANDATORY PRE-TASK DELEGATION CHECK
- Answer the 7 YES/NO questions in the Quick Decision Tree
- If ANY answer is YES → DELEGATE TO AGENT, do not proceed manually
</system-reminder>
EOF

exit 0
