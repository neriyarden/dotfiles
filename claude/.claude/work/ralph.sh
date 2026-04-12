set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <feature-name> <iterations>"
  exit 1
fi

FEATURE_DIR="$HOME/.claude/work/features/$1"

if [ ! -f "$FEATURE_DIR/tasks.json" ]; then
  echo "Error: $FEATURE_DIR/tasks.json not found"
  exit 1
fi

for ((i=1; i<=$2; i++)); do
  echo "Iteration $i"
  echo "------------------------"
  result=$(claude --permission-mode acceptEdits -p "@$FEATURE_DIR/prd.md @$FEATURE_DIR/tasks.json @$FEATURE_DIR/progress.txt \
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
After completing the task, read tasks.json and check if every entry has passes set to true. If so:
1. Plan a strategy for creating PRs. Each PR should be as small and scoped as possible. Try to avoid dependency PRs if possible, as they add extra overhead. If there are dependency PRs, make sure to clearly indicate the order they need to be merged in. \
2. Create the PRs according to the strategy you planned. Use the /make-pr command. \
3. output <promise>COMPLETE</promise>. \
")
  echo "$result"
  
  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "PRD complete, exiting."
    tt notify "CVM PRD complete after $i iterations"
    exit 0
  fi
done
