#!/bin/bash
# Reminds Claude to follow CLAUDE.md before every action

cat << 'EOF'
<system-reminder>
Before proceeding, verify your next action follows CLAUDE.md delegation rules:
- Run through the pre-task delegation check
- If ANY condition matches → DELEGATE TO AGENT, do not proceed manually
</system-reminder>
EOF

exit 0
