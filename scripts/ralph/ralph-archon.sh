#!/bin/bash
# ralph-archon.sh - Autonomous feature development loop using Archon MCP
#
# Usage: ./ralph-archon.sh [max_iterations] [project_id]
#
# This script runs Claude Code in a loop, picking up tasks from Archon,
# executing them, and marking them complete. Each iteration gets a fresh
# context window, preventing context bloat.
#
# Prerequisites:
# - Claude Code installed and configured
# - Archon MCP server running
# - scripts/ralph/current-feature.txt contains the feature label
# - scripts/ralph/progress.txt initialized

set -e

MAX_ITERATIONS=${1:-10}
PROJECT_ID=${2:-""}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
FEATURE_FILE="$SCRIPT_DIR/current-feature.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Ralph Archon Loop ===${NC}"
echo "Max iterations: $MAX_ITERATIONS"

# Check prerequisites
if [ ! -f "$FEATURE_FILE" ]; then
    echo -e "${RED}Error: $FEATURE_FILE not found${NC}"
    echo "Create it with: echo 'ralph-your-feature' > $FEATURE_FILE"
    exit 1
fi

FEATURE=$(cat "$FEATURE_FILE")
echo "Feature: $FEATURE"

if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}Warning: No project_id specified. Will search all projects.${NC}"
fi

# Initialize progress file if missing
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "# Ralph Progress: $FEATURE
Started: $(date)

## Codebase Patterns
---

## Iterations
" > "$PROGRESS_FILE"
fi

# Main loop
for i in $(seq 1 $MAX_ITERATIONS); do
    echo ""
    echo -e "${BLUE}=== Iteration $i of $MAX_ITERATIONS ===${NC}"
    echo "$(date)"

    # Create iteration prompt
    ITERATION_PROMPT="You are Ralph, an autonomous coding agent working on feature: $FEATURE

## Your Task This Iteration

1. **Find the next todo task**:
   Use archon:find_tasks to search for tasks with:
   - filter_by: 'status'
   - filter_value: 'todo'
   $([ -n "$PROJECT_ID" ] && echo "- project_id: '$PROJECT_ID'")

   Look for tasks where the feature field equals '$FEATURE'.
   Pick the one with the lowest task_order.

2. **If no tasks found**:
   Output exactly: <promise>COMPLETE</promise>
   This signals that all tasks are done.

3. **If task found**:
   a. Read the full task description
   b. Read progress.txt at $PROGRESS_FILE for codebase patterns
   c. Implement according to acceptance criteria
   d. Run verification: npm run typecheck && npm test (if applicable)
   e. If verification passes:
      - Use archon:manage_task with action='update', status='done'
      - Add iteration summary to progress.txt
   f. If verification fails:
      - Note the failure in progress.txt
      - Do NOT mark task as done
      - Try to fix the issue

4. **Update progress.txt**:
   Append to ## Iterations section:
   $i. [✓ or ✗] [task title] - [brief note]

   If you learned a new codebase pattern, add to ## Codebase Patterns section.

## Critical Rules
- Complete exactly ONE task per iteration
- Always run verification before marking done
- If stuck, output what's blocking and move to next iteration
- Fresh context each iteration - read progress.txt for continuity
"

    # Run Claude Code with the iteration prompt
    OUTPUT=$(claude --print "$ITERATION_PROMPT" 2>&1) || true

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo -e "${GREEN}=== All tasks complete! ===${NC}"
        echo "Feature '$FEATURE' finished after $i iterations."

        # Archive progress file
        ARCHIVE_DIR="$SCRIPT_DIR/archive/$(date +%Y-%m-%d)-$FEATURE"
        mkdir -p "$ARCHIVE_DIR"
        cp "$PROGRESS_FILE" "$ARCHIVE_DIR/"
        echo "Progress archived to: $ARCHIVE_DIR"

        exit 0
    fi

    # Check for errors
    if echo "$OUTPUT" | grep -qE "Error|error|FAILED|failed"; then
        echo -e "${YELLOW}Warning: Errors detected in iteration $i${NC}"
        echo "Check progress.txt for details"
    fi

    echo -e "${GREEN}Iteration $i complete${NC}"

    # Small delay between iterations to avoid rate limiting
    sleep 2
done

echo ""
echo -e "${YELLOW}=== Max iterations reached ===${NC}"
echo "Completed $MAX_ITERATIONS iterations."
echo "Run again to continue: $0 $MAX_ITERATIONS"
