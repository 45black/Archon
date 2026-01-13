#!/bin/bash
# ralph-archon.sh - Autonomous feature development loop using Archon MCP
# Version: 2.0 (with ISO-aligned Quality Gates)
#
# Usage: ./ralph-archon.sh [max_iterations] [project_id]
#
# This script runs Claude Code in a loop, picking up tasks from Archon,
# executing them, and marking them complete. Each iteration gets a fresh
# context window, preventing context bloat.
#
# Version 2.0 adds ISO 9001/42001/25010 quality gates:
# - Gate 1: PRD Quality (pre-flight)
# - Gate 2: Task Plan / Anti-Rubber-Stamp (pre-flight)
# - Gate 3: Pre-Commit (per task)
# - Gate 4: Acceptance (per task)
# - Post-Gate: Compound Review (on completion)
#
# Prerequisites:
# - Claude Code installed and configured
# - Archon MCP server running
# - scripts/ralph/current-feature.txt contains the feature label
# - scripts/ralph/progress.txt initialized (use /ralph-start skill)
#
# Environment Variables:
# - RALPH_GATES_ENABLED: true/false (default: true)
# - RALPH_GATE1_SKIP: true/false (skip PRD validation)
# - RALPH_GATE2_SKIP: true/false (skip task plan validation)
# - RALPH_GATE3_SKIP: true/false (skip pre-commit checks)
# - RALPH_GATE4_SKIP: true/false (skip acceptance checks)
# - RALPH_FORCE_ADVERSARIAL: true/false (force adversarial review)

set -e

MAX_ITERATIONS=${1:-10}
PROJECT_ID=${2:-""}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
FEATURE_FILE="$SCRIPT_DIR/current-feature.txt"
CONFIG_FILE="$SCRIPT_DIR/feature-config.txt"
GATES_DIR="$SCRIPT_DIR/gates"

# Gate configuration (can be overridden via environment)
RALPH_GATES_ENABLED="${RALPH_GATES_ENABLED:-true}"
RALPH_GATE1_SKIP="${RALPH_GATE1_SKIP:-false}"
RALPH_GATE2_SKIP="${RALPH_GATE2_SKIP:-false}"
RALPH_GATE3_SKIP="${RALPH_GATE3_SKIP:-false}"
RALPH_GATE4_SKIP="${RALPH_GATE4_SKIP:-false}"
RALPH_FORCE_ADVERSARIAL="${RALPH_FORCE_ADVERSARIAL:-false}"

# Track gate failures
GATE_FAILURES=0
MAX_GATE_FAILURES=3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}=== Ralph Archon Loop v2.0 (ISO Quality Gates) ===${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo "Max iterations: $MAX_ITERATIONS"
echo "Gates enabled: $RALPH_GATES_ENABLED"

# Check prerequisites
if [ ! -f "$FEATURE_FILE" ]; then
    echo -e "${RED}Error: $FEATURE_FILE not found${NC}"
    echo "Create it with: echo 'ralph-your-feature' > $FEATURE_FILE"
    echo "Or run /ralph-start skill to set up properly"
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

## Domain Classification
- Domain: Standard
- Adversarial Review: Optional
- Keywords: none

## ISO Controls Applied
- Gate 1 (PRD Quality): Pending
- Gate 2 (Task Plan): Pending

## Codebase Patterns
---

## Iterations
" > "$PROGRESS_FILE"
fi

# ============================================================
# PRE-FLIGHT: Gate 1 & 2 Validation
# ============================================================

if [ "$RALPH_GATES_ENABLED" = "true" ]; then
    echo ""
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN}PRE-FLIGHT VERIFICATION GATES${NC}"
    echo -e "${CYAN}============================================================${NC}"

    # Gate 1: PRD Quality
    if [ "$RALPH_GATE1_SKIP" != "true" ] && [ -f "$GATES_DIR/gate-1-prd.sh" ]; then
        echo ""
        if ! "$GATES_DIR/gate-1-prd.sh" "$PROGRESS_FILE"; then
            echo ""
            echo -e "${RED}[BLOCKED] Gate 1 (PRD Quality) FAILED${NC}"
            echo ""
            echo "To fix:"
            echo "  1. Review progress.txt for missing sections"
            echo "  2. Run /ralph-start skill to set up properly"
            echo "  3. Or skip with: RALPH_GATE1_SKIP=true $0 $MAX_ITERATIONS"
            exit 1
        fi
    else
        if [ "$RALPH_GATE1_SKIP" = "true" ]; then
            echo -e "${YELLOW}[SKIP] Gate 1: Skipped by RALPH_GATE1_SKIP${NC}"
        else
            echo -e "${YELLOW}[SKIP] Gate 1: gate-1-prd.sh not found${NC}"
        fi
    fi

    # Gate 2: Task Plan / Anti-Rubber-Stamp
    if [ "$RALPH_GATE2_SKIP" != "true" ] && [ -f "$GATES_DIR/gate-2-plan.sh" ]; then
        echo ""
        if ! "$GATES_DIR/gate-2-plan.sh"; then
            echo ""
            echo -e "${RED}[BLOCKED] Gate 2 (Task Plan) FAILED${NC}"
            echo ""
            echo "To fix QMS-008 violations:"
            echo "  1. Review task acceptance criteria"
            echo "  2. Replace 'exists/available' with 'returns/passes/equals'"
            echo "  3. Add specific expected values"
            echo "  4. Or skip with: RALPH_GATE2_SKIP=true $0 $MAX_ITERATIONS"
            exit 1
        fi
    else
        if [ "$RALPH_GATE2_SKIP" = "true" ]; then
            echo -e "${YELLOW}[SKIP] Gate 2: Skipped by RALPH_GATE2_SKIP${NC}"
        else
            echo -e "${YELLOW}[SKIP] Gate 2: gate-2-plan.sh not found${NC}"
        fi
    fi

    echo ""
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}PRE-FLIGHT GATES PASSED - Starting Execution${NC}"
    echo -e "${GREEN}============================================================${NC}"
fi

# Load adversarial settings from config
RALPH_ADVERSARIAL_REVIEW="optional"
RALPH_DOMAIN="standard"
if [ -f "$CONFIG_FILE" ]; then
    RALPH_ADVERSARIAL_REVIEW=$(grep "adversarial_review=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "optional")
    RALPH_DOMAIN=$(grep "domain=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "standard")
fi

echo ""
echo "Domain: $RALPH_DOMAIN"
echo "Adversarial Review: $RALPH_ADVERSARIAL_REVIEW"
echo ""

# ============================================================
# MAIN ITERATION LOOP
# ============================================================

for i in $(seq 1 $MAX_ITERATIONS); do
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}=== Iteration $i of $MAX_ITERATIONS ===${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo "$(date)"

    # Track current task for gate tracking
    CURRENT_TASK_ID="iter-$i"

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
   c. Note the task ID for tracking: output <task_id>THE_ID</task_id>
   d. Implement according to acceptance criteria
   e. IMPORTANT: Acceptance criteria must be EXECUTED, not just checked
      - Run actual commands (npm test, typecheck)
      - Compare actual output vs expected
      - Don't just check if things 'exist'
   f. Run verification: npm run typecheck && npm test (if applicable)
   g. If verification passes:
      - Use archon:manage_task with action='update', status='done'
      - Add iteration summary to progress.txt
   h. If verification fails:
      - Note the failure in progress.txt
      - Do NOT mark task as done
      - Try to fix the issue

4. **Update progress.txt**:
   Append to ## Iterations section:
   $i. [✓ or ✗] [task title] - [brief note]

   If you learned a new codebase pattern, add to ## Codebase Patterns section.

## ISO Quality Requirements (QMS-008)
- Acceptance criteria must EXECUTE verification, not just check availability
- BAD: 'API endpoint exists' - this is a rubber-stamp check
- GOOD: 'API call returns HTTP 200 with {expected: data}'

## Critical Rules
- Complete exactly ONE task per iteration
- Always run verification before marking done
- If stuck, output what's blocking and move to next iteration
- Fresh context each iteration - read progress.txt for continuity
"

    # Run Claude Code with the iteration prompt
    OUTPUT=$(claude --print "$ITERATION_PROMPT" 2>&1) || true

    # Try to extract task ID from output
    if echo "$OUTPUT" | grep -q "<task_id>"; then
        CURRENT_TASK_ID=$(echo "$OUTPUT" | grep -oP '(?<=<task_id>)[^<]+(?=</task_id>)' | head -1 || echo "iter-$i")
    fi

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo -e "${GREEN}============================================================${NC}"
        echo -e "${GREEN}=== All tasks complete! ===${NC}"
        echo -e "${GREEN}============================================================${NC}"
        echo "Feature '$FEATURE' finished after $i iterations."

        # ============================================================
        # POST-GATE: Compound Review
        # ============================================================
        if [ "$RALPH_GATES_ENABLED" = "true" ] && [ -f "$GATES_DIR/post-gate-compound.sh" ]; then
            echo ""
            echo -e "${CYAN}Executing Post-Gate: Compound Review${NC}"
            "$GATES_DIR/post-gate-compound.sh" || true
        fi

        # Generate compliance report
        if [ -f "$GATES_DIR/generate-report.sh" ]; then
            echo ""
            echo -e "${CYAN}Generating Compliance Report${NC}"
            "$GATES_DIR/generate-report.sh" "$FEATURE" || true
        fi

        # Archive progress file
        ARCHIVE_DIR="$SCRIPT_DIR/archive/$(date +%Y-%m-%d)-$FEATURE"
        mkdir -p "$ARCHIVE_DIR"
        cp "$PROGRESS_FILE" "$ARCHIVE_DIR/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/audit" "$ARCHIVE_DIR/" 2>/dev/null || true
        echo "Progress archived to: $ARCHIVE_DIR"

        echo ""
        echo -e "${GREEN}Feature complete with ISO compliance verified${NC}"
        exit 0
    fi

    # ============================================================
    # GATE 3: Pre-Commit Verification
    # ============================================================
    if [ "$RALPH_GATES_ENABLED" = "true" ] && [ "$RALPH_GATE3_SKIP" != "true" ] && [ -f "$GATES_DIR/gate-3-precommit.sh" ]; then
        echo ""
        echo -e "${CYAN}[Iteration $i] Executing Gate 3: Pre-Commit${NC}"

        if ! "$GATES_DIR/gate-3-precommit.sh" "$CURRENT_TASK_ID"; then
            echo -e "${YELLOW}[WARN] Gate 3 failed for task $CURRENT_TASK_ID${NC}"
            GATE_FAILURES=$((GATE_FAILURES + 1))

            # Log failure
            echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) - Gate 3 FAILED: task $CURRENT_TASK_ID" >> "$PROGRESS_FILE"

            if [ "$GATE_FAILURES" -ge "$MAX_GATE_FAILURES" ]; then
                echo ""
                echo -e "${RED}[BLOCKED] Too many gate failures ($GATE_FAILURES)${NC}"
                echo "Stopping for human review. Check:"
                echo "  - $SCRIPT_DIR/audit/gate-3/"
                echo "  - $PROGRESS_FILE"
                exit 1
            fi
        fi
    fi

    # ============================================================
    # GATE 4: Acceptance Verification
    # ============================================================
    SKIP_COMPLETION=false
    if [ "$RALPH_GATES_ENABLED" = "true" ] && [ "$RALPH_GATE4_SKIP" != "true" ] && [ -f "$GATES_DIR/gate-4-acceptance.sh" ]; then
        echo ""
        echo -e "${CYAN}[Iteration $i] Executing Gate 4: Acceptance${NC}"

        if ! "$GATES_DIR/gate-4-acceptance.sh" "$CURRENT_TASK_ID"; then
            echo -e "${YELLOW}[WARN] Gate 4 failed for task $CURRENT_TASK_ID${NC}"
            echo "Task will NOT be marked complete"
            SKIP_COMPLETION=true
            GATE_FAILURES=$((GATE_FAILURES + 1))

            # Log failure
            echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) - Gate 4 FAILED: task $CURRENT_TASK_ID" >> "$PROGRESS_FILE"
        fi
    fi

    # ============================================================
    # ADVERSARIAL REVIEW (if required)
    # ============================================================
    if [ "$RALPH_ADVERSARIAL_REVIEW" = "mandatory" ] || [ "$RALPH_FORCE_ADVERSARIAL" = "true" ]; then
        if [ -f "$GATES_DIR/adversarial-review.sh" ]; then
            echo ""
            echo -e "${CYAN}[Iteration $i] Executing Adversarial Review (Domain: $RALPH_DOMAIN)${NC}"

            if ! "$GATES_DIR/adversarial-review.sh" "$CURRENT_TASK_ID" "$RALPH_DOMAIN"; then
                echo -e "${YELLOW}[WARN] Adversarial review flagged issues${NC}"
                echo "Check: $SCRIPT_DIR/adversarial/review-task-$CURRENT_TASK_ID.md"

                # Don't block, but log
                echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) - ADVERSARIAL REVIEW FLAGGED: task $CURRENT_TASK_ID" >> "$PROGRESS_FILE"
            fi
        fi
    fi

    # Check for errors in Claude output
    if echo "$OUTPUT" | grep -qE "Error|error|FAILED|failed"; then
        echo -e "${YELLOW}Warning: Errors detected in iteration $i${NC}"
        echo "Check progress.txt for details"
    fi

    echo ""
    echo -e "${GREEN}Iteration $i complete${NC}"
    echo "Task: $CURRENT_TASK_ID"
    echo "Gate failures so far: $GATE_FAILURES"

    # Small delay between iterations to avoid rate limiting
    sleep 2
done

echo ""
echo -e "${YELLOW}============================================================${NC}"
echo -e "${YELLOW}=== Max iterations reached ===${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo "Completed $MAX_ITERATIONS iterations."
echo "Gate failures: $GATE_FAILURES"
echo ""
echo "To continue: $0 $MAX_ITERATIONS $PROJECT_ID"
echo ""

# Generate partial compliance report
if [ -f "$GATES_DIR/generate-report.sh" ]; then
    echo "Generating partial compliance report..."
    "$GATES_DIR/generate-report.sh" "$FEATURE" || true
fi
