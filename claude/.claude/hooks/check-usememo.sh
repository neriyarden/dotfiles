#!/bin/bash
# PostToolUse hook: warn when useMemo is written in tsx/jsx files
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [[ "$FILE_PATH" =~ \.(tsx|jsx)$ ]]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')
  if echo "$CONTENT" | grep -q 'useMemo'; then
    echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"You just wrote code containing useMemo. Remove it unless it is crucial for performance (expensive computation or referential stability needed for a dependency array). Most useMemo usage is unnecessary."}}'
  fi
fi
