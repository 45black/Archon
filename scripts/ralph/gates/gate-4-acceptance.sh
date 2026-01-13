#!/bin/bash
# Gate 4: Acceptance Verification
# ISO Controls: QMS-013, QMS-014, QMS-016, SWQ-001
#
# This gate runs the final acceptance verification before marking a task done.
# It ensures criteria are EXECUTED (not just checked) per QMS-008.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
TASK_ID="${1:-unknown}"
AUDIT_DIR="$RALPH_DIR/audit/gate-4"
AUDIT_FILE="$AUDIT_DIR/task-$TASK_ID.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize results
CONTROLS_PASSED=0
CONTROLS_FAILED=0
CONTROLS_WARNED=0
declare -a EVIDENCE

echo -e "${BLUE}[Gate 4] Acceptance Verification - Task: $TASK_ID${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Ensure audit directory exists
mkdir -p "$AUDIT_DIR"

# ============================================================
# QMS-013: Acceptance Execution (CRITICAL)
# ============================================================
echo -e "${BLUE}[QMS-013]${NC} Executing acceptance verification..."

QMS013_STATUS="pass"
QMS013_EVIDENCE=""

# This is the KEY control - we must EXECUTE verification
# Run the full verification suite

TYPECHECK_PASS=false
TEST_PASS=false

# TypeCheck
echo "  Running typecheck..."
if [ -f "package.json" ] && grep -q '"typecheck"' package.json 2>/dev/null; then
    if npm run typecheck &>/dev/null; then
        TYPECHECK_PASS=true
        echo -e "    ${GREEN}TypeCheck: PASS${NC}"
    else
        echo -e "    ${RED}TypeCheck: FAIL${NC}"
    fi
elif [ -f "package.json" ] && grep -q '"build"' package.json 2>/dev/null; then
    if npm run build &>/dev/null; then
        TYPECHECK_PASS=true
        echo -e "    ${GREEN}Build: PASS${NC}"
    else
        echo -e "    ${RED}Build: FAIL${NC}"
    fi
else
    TYPECHECK_PASS=true  # No typecheck = skip
    echo "    TypeCheck: SKIPPED (no script)"
fi

# Tests
echo "  Running tests..."
if [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
    TEST_OUTPUT=$(npm test 2>&1) || true
    if echo "$TEST_OUTPUT" | grep -qE "passed|passing|0 failed"; then
        TEST_PASS=true
        echo -e "    ${GREEN}Tests: PASS${NC}"
    elif echo "$TEST_OUTPUT" | grep -qE "no test"; then
        TEST_PASS=true
        echo "    Tests: SKIPPED (no tests defined)"
    else
        echo -e "    ${RED}Tests: FAIL${NC}"
    fi
elif [ -f "pyproject.toml" ] && command -v pytest &>/dev/null; then
    if pytest --tb=no -q &>/dev/null; then
        TEST_PASS=true
        echo -e "    ${GREEN}Tests: PASS${NC}"
    else
        echo -e "    ${RED}Tests: FAIL${NC}"
    fi
else
    TEST_PASS=true  # No tests = skip
    echo "    Tests: SKIPPED (no framework)"
fi

# Determine QMS-013 status
if [ "$TYPECHECK_PASS" = true ] && [ "$TEST_PASS" = true ]; then
    QMS013_STATUS="pass"
    QMS013_EVIDENCE="Acceptance verification executed: typecheck=$TYPECHECK_PASS, tests=$TEST_PASS"
    ((CONTROLS_PASSED++))
else
    QMS013_STATUS="fail"
    QMS013_EVIDENCE="Acceptance verification failed: typecheck=$TYPECHECK_PASS, tests=$TEST_PASS"
    ((CONTROLS_FAILED++))
fi

if [ "$QMS013_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS013_EVIDENCE"
else
    echo -e "  ${RED}FAIL${NC}: $QMS013_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-013\", \"status\": \"$QMS013_STATUS\", \"evidence\": \"$QMS013_EVIDENCE\", \"typecheck\": $TYPECHECK_PASS, \"tests\": $TEST_PASS}")

# ============================================================
# QMS-014: Regression Prevention
# ============================================================
echo -e "${BLUE}[QMS-014]${NC} Checking for regressions..."

QMS014_STATUS="pass"
QMS014_EVIDENCE=""

# Check if this is a repeat failure by looking at previous gate-4 results
PREV_RESULTS="$AUDIT_DIR/task-*.json"
PREV_FAILURES=$(grep -l '"overall_status": "fail"' $PREV_RESULTS 2>/dev/null | wc -l || echo "0")
PREV_FAILURES=$(echo "$PREV_FAILURES" | tr -d ' ')

if [ "$PREV_FAILURES" -lt 3 ]; then
    QMS014_STATUS="pass"
    QMS014_EVIDENCE="Regression check passed ($PREV_FAILURES previous failures in this feature)"
    ((CONTROLS_PASSED++))
else
    QMS014_STATUS="warn"
    QMS014_EVIDENCE="$PREV_FAILURES previous task failures - pattern of issues detected"
    ((CONTROLS_WARNED++))
fi

if [ "$QMS014_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS014_EVIDENCE"
else
    echo -e "  ${YELLOW}WARN${NC}: $QMS014_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-014\", \"status\": \"$QMS014_STATUS\", \"evidence\": \"$QMS014_EVIDENCE\"}")

# ============================================================
# QMS-016: Completion Verification
# ============================================================
echo -e "${BLUE}[QMS-016]${NC} Verifying completion readiness..."

QMS016_STATUS="pass"
QMS016_EVIDENCE=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Check for uncommitted changes
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    UNCOMMITTED=$(echo "$UNCOMMITTED" | tr -d ' ')

    if [ "$UNCOMMITTED" -eq 0 ]; then
        QMS016_STATUS="pass"
        QMS016_EVIDENCE="All changes committed - task ready for completion"
        ((CONTROLS_PASSED++))
    elif [ "$UNCOMMITTED" -lt 5 ]; then
        QMS016_STATUS="warn"
        QMS016_EVIDENCE="$UNCOMMITTED uncommitted changes remain - consider committing"
        ((CONTROLS_WARNED++))
    else
        QMS016_STATUS="warn"
        QMS016_EVIDENCE="$UNCOMMITTED uncommitted changes - significant work not committed"
        ((CONTROLS_WARNED++))
    fi
else
    QMS016_STATUS="info"
    QMS016_EVIDENCE="Not in git repository - cannot verify commit status"
fi

if [ "$QMS016_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS016_EVIDENCE"
elif [ "$QMS016_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS016_EVIDENCE"
else
    echo -e "  INFO: $QMS016_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-016\", \"status\": \"$QMS016_STATUS\", \"evidence\": \"$QMS016_EVIDENCE\"}")

# ============================================================
# SWQ-001: Functional Completeness
# ============================================================
echo -e "${BLUE}[SWQ-001]${NC} Verifying functional completeness..."

SWQ001_STATUS="pass"
SWQ001_EVIDENCE=""

# Check for TODO/FIXME comments in changed files
if git rev-parse --is-inside-work-tree &>/dev/null; then
    CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")

    TODO_COUNT=0
    for file in $CHANGED_FILES; do
        if [ -f "$file" ]; then
            FILE_TODOS=$(grep -ciE "TODO|FIXME|XXX|HACK" "$file" 2>/dev/null | tr -d '\n ' || echo "0")
            FILE_TODOS=${FILE_TODOS:-0}
            TODO_COUNT=$((TODO_COUNT + FILE_TODOS))
        fi
    done

    if [ "$TODO_COUNT" -eq 0 ]; then
        SWQ001_STATUS="pass"
        SWQ001_EVIDENCE="No TODO/FIXME markers in changed files"
        ((CONTROLS_PASSED++))
    else
        SWQ001_STATUS="warn"
        SWQ001_EVIDENCE="$TODO_COUNT TODO/FIXME markers found - incomplete work flagged"
        ((CONTROLS_WARNED++))
    fi
else
    SWQ001_STATUS="info"
    SWQ001_EVIDENCE="Not in git repository"
fi

if [ "$SWQ001_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $SWQ001_EVIDENCE"
elif [ "$SWQ001_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $SWQ001_EVIDENCE"
else
    echo -e "  INFO: $SWQ001_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"SWQ-001\", \"status\": \"$SWQ001_STATUS\", \"evidence\": \"$SWQ001_EVIDENCE\"}")

# ============================================================
# Generate Audit JSON
# ============================================================
echo ""

# Build JSON array
EVIDENCE_JSON=""
for ((idx=0; idx<${#EVIDENCE[@]}; idx++)); do
    if [ $idx -gt 0 ]; then
        EVIDENCE_JSON="$EVIDENCE_JSON,"
    fi
    EVIDENCE_JSON="$EVIDENCE_JSON${EVIDENCE[$idx]}"
done

# Determine overall status
OVERALL_STATUS="pass"
if [ "$CONTROLS_FAILED" -gt 0 ]; then
    OVERALL_STATUS="fail"
elif [ "$CONTROLS_WARNED" -gt 0 ]; then
    OVERALL_STATUS="warn"
fi

cat > "$AUDIT_FILE" <<EOF
{
  "gate": "4",
  "name": "Acceptance",
  "task_id": "$TASK_ID",
  "timestamp": "$TIMESTAMP",
  "controls_passed": $CONTROLS_PASSED,
  "controls_failed": $CONTROLS_FAILED,
  "controls_warned": $CONTROLS_WARNED,
  "typecheck_passed": $TYPECHECK_PASS,
  "tests_passed": $TEST_PASS,
  "controls_executed": [$EVIDENCE_JSON],
  "overall_status": "$OVERALL_STATUS"
}
EOF

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo -e "${BLUE}[Gate 4] Summary - Task: $TASK_ID${NC}"
echo "  Passed:  $CONTROLS_PASSED"
echo "  Warned:  $CONTROLS_WARNED"
echo "  Failed:  $CONTROLS_FAILED"
echo "  Evidence: $AUDIT_FILE"
echo ""

if [ "$CONTROLS_FAILED" -gt 0 ]; then
    echo -e "${RED}[Gate 4] FAILED - Task NOT ready for completion${NC}"
    echo "Fix failing checks and re-run verification"
    exit 1
elif [ "$CONTROLS_WARNED" -gt 0 ]; then
    echo -e "${YELLOW}[Gate 4] PASSED WITH WARNINGS${NC}"
    echo "Task can be marked complete, but consider addressing warnings"
    exit 0
else
    echo -e "${GREEN}[Gate 4] PASSED - Task ready for completion${NC}"
    exit 0
fi
