#!/bin/bash

# Read all JSON input from stdin
json_input=$(cat)

# Extract file path from tool_input
file_path=$(echo "$json_input" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
if [ -z "$file_path" ]; then
  exit 0
fi

# Only format supported file types
case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.json|*.md)
    cd "$CLAUDE_PROJECT_DIR" && pnpm exec prettier --write "$file_path" 2>/dev/null
    ;;
esac

exit 0
