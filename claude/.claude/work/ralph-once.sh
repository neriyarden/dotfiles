set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <feature-name>"
  exit 1
fi

FEATURE_DIR="$HOME/.claude/work/features/$1"

if [ ! -f "$FEATURE_DIR/tasks.json" ]; then
  echo "Error: $FEATURE_DIR/tasks.json not found"
  exit 1
fi

claude --permission-mode acceptEdits "@$FEATURE_DIR/prd.md @$FEATURE_DIR/tasks.json @$FEATURE_DIR/progress.txt \
1. Find the highest-priority task to work on and work only on that task. \
This should be the one YOU decide has the highest priority - not necessarily the first in the list. \
Respect the blockedBy field — never work on a task whose blockers have not passed yet. \
2. Implement using TDD red-green-refactor: write one test, make it pass, repeat. Never write all tests first then all implementation. \
3. Run the project's quality gates: format, lint, type check, and tests. All must pass. \
4. If it's a UI task, check that the UI looks correct and functions correctly with /agent-browser. \
5. Update tasks.json — flip passes to true for the completed task. \
6. Append your progress to $FEATURE_DIR/progress.txt. \
Use this to leave a note for the next person working in the codebase.
ONLY WORK ON A SINGLE TASK.
After completing the task, read tasks.json and check if every entry has passes set to true. \
If so, output <promise>COMPLETE</promise>. \
"
