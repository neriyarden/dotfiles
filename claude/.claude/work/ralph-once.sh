set -e

claude --permission-mode acceptEdits "@prd.json @progress.txt \
1. Find the highest-priority task to work on and work only on that task. \
This should be the one YOU decide has the highest priority - not necessarily the first in the list. \
2. Check that the types check via pnpm typecheck and that the tests pass via pnpm test.
3. Update the PRD with the work that was done. \
4. Append your progress to the progress.txt file. \
Use this to leave a note for the next person working in the codebase.
5. Make a git commit of that task.
ONLY WORK ON A SINGLE TASK.
If, while implementing the task, you notice the PRD is complete, output <promise>COMPLETE</promise>. \
"
