set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

for ((i=1; i<=$1; i++)); do 
  echo "Iteration $i" 
  echo "------------------------"
  result=$(claude --permission-mode acceptEdits -p "@~/prd.json @progress.txt \
1. Find the highest-priority task to work on and work only on that task. \
This should be the one YOU decide has the highest priority - not necessarily the first in the list. \
2. Check that the types check via pnpm typecheck and that the tests pass via pnpm test.
3. If it's a UI task, check that the UI looks correct and functions correctly with /agent-browser.
4. Update the PRD with the work that was done. \
5. Append your progress to the progress.txt file. \
Use this to leave a note for the next person working in the codebase.
ONLY WORK ON A SINGLE TASK.
If, while implementing the task, you notice the PRD is complete:
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
