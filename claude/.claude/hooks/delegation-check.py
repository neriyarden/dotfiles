#!/usr/bin/env python3
"""
PreToolUse hook that warns when Grep/Glob is used.
Reminds to consider delegating to agents instead.
"""
import json
import sys

try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

tool_name = data.get("tool_name", "Unknown")

feedback = f"""
--- DELEGATION CHECK ---

You're about to use {tool_name}.

BEFORE PROCEEDING, answer:
- Will this require >3 tool calls? → DELEGATE
- Will I need to search >2 files? → DELEGATE
- Am I exploring unfamiliar code? → DELEGATE

If YES to any: Use Task tool with Explore agent instead.

If NO to all: Proceed with {tool_name}.
------------------------
"""

output = {
    "continue": True,
    "systemMessage": feedback.strip()
}

print(json.dumps(output))
sys.exit(0)
