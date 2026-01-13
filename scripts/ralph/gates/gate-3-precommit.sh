#!/bin/bash
# Gate 3: Pre-Commit Verification
# ISO Controls: QMS-009, QMS-010, QMS-011, QMS-012, SWQ-002, SWQ-005
#
# This gate runs after each task implementation but before marking complete.
# It verifies code quality, security, and test passage.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
TASK_ID="${1:-unknown}"
AUDIT_DIR="$RALPH_DIR/audit/gate-3"
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

echo -e "${BLUE}[Gate 3] Pre-Commit Verification - Task: $TASK_ID${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Ensure audit directory exists
mkdir -p "$AUDIT_DIR"

# ============================================================
# QMS-009: Implementation Completeness (TypeCheck)
# ============================================================
echo -e "${BLUE}[QMS-009]${NC} Running type check..."

QMS009_STATUS="pass"
QMS009_EVIDENCE=""

# Try different type check commands
if [ -f "package.json" ]; then
    if grep -q '"typecheck"' package.json 2>/dev/null; then
        if npm run typecheck 2>&1 | tail -3; then
            QMS009_STATUS="pass"
            QMS009_EVIDENCE="npm run typecheck passed"
            ((CONTROLS_PASSED++))
        else
            QMS009_STATUS="fail"
            QMS009_EVIDENCE="TypeScript errors detected - fix before committing"
            ((CONTROLS_FAILED++))
        fi
    elif grep -q '"build"' package.json 2>/dev/null; then
        # Use build as fallback
        if npm run build 2>&1 | tail -5; then
            QMS009_STATUS="pass"
            QMS009_EVIDENCE="npm run build passed (no typecheck script)"
            ((CONTROLS_PASSED++))
        else
            QMS009_STATUS="fail"
            QMS009_EVIDENCE="Build failed - compilation errors"
            ((CONTROLS_FAILED++))
        fi
    else
        QMS009_STATUS="info"
        QMS009_EVIDENCE="No typecheck or build script found"
    fi
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    # Python project - try mypy
    if command -v mypy &> /dev/null; then
        if mypy . --ignore-missing-imports 2>&1 | tail -5; then
            QMS009_STATUS="pass"
            QMS009_EVIDENCE="mypy type check passed"
            ((CONTROLS_PASSED++))
        else
            QMS009_STATUS="warn"
            QMS009_EVIDENCE="mypy found type issues"
            ((CONTROLS_WARNED++))
        fi
    else
        QMS009_STATUS="info"
        QMS009_EVIDENCE="Python project - mypy not available"
    fi
else
    QMS009_STATUS="info"
    QMS009_EVIDENCE="No recognized project type found"
fi

if [ "$QMS009_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS009_EVIDENCE"
elif [ "$QMS009_STATUS" = "fail" ]; then
    echo -e "  ${RED}FAIL${NC}: $QMS009_EVIDENCE"
elif [ "$QMS009_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS009_EVIDENCE"
else
    echo -e "  INFO: $QMS009_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-009\", \"status\": \"$QMS009_STATUS\", \"evidence\": \"$QMS009_EVIDENCE\"}")

# ============================================================
# SWQ-002: Functional Correctness (Tests)
# ============================================================
echo -e "${BLUE}[SWQ-002]${NC} Running tests..."

SWQ002_STATUS="pass"
SWQ002_EVIDENCE=""
TEST_OUTPUT=""

if [ -f "package.json" ]; then
    if grep -q '"test"' package.json 2>/dev/null; then
        TEST_OUTPUT=$(npm test 2>&1) || true
        TEST_EXIT=$?

        if [ $TEST_EXIT -eq 0 ]; then
            # Extract pass count if possible
            PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ pass" | head -1 || echo "tests passed")
            SWQ002_STATUS="pass"
            SWQ002_EVIDENCE="npm test passed ($PASS_COUNT)"
            ((CONTROLS_PASSED++))
        else
            FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ fail" | head -1 || echo "failures detected")
            SWQ002_STATUS="fail"
            SWQ002_EVIDENCE="npm test failed ($FAIL_COUNT)"
            ((CONTROLS_FAILED++))
        fi
    else
        SWQ002_STATUS="info"
        SWQ002_EVIDENCE="No test script found in package.json"
    fi
elif [ -f "pyproject.toml" ]; then
    if command -v pytest &> /dev/null; then
        TEST_OUTPUT=$(pytest --tb=short 2>&1) || true
        TEST_EXIT=$?

        if [ $TEST_EXIT -eq 0 ]; then
            SWQ002_STATUS="pass"
            SWQ002_EVIDENCE="pytest passed"
            ((CONTROLS_PASSED++))
        else
            SWQ002_STATUS="fail"
            SWQ002_EVIDENCE="pytest failed"
            ((CONTROLS_FAILED++))
        fi
    else
        SWQ002_STATUS="info"
        SWQ002_EVIDENCE="Python project - pytest not available"
    fi
else
    SWQ002_STATUS="info"
    SWQ002_EVIDENCE="No test framework detected"
fi

if [ "$SWQ002_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $SWQ002_EVIDENCE"
elif [ "$SWQ002_STATUS" = "fail" ]; then
    echo -e "  ${RED}FAIL${NC}: $SWQ002_EVIDENCE"
else
    echo -e "  INFO: $SWQ002_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"SWQ-002\", \"status\": \"$SWQ002_STATUS\", \"evidence\": \"$SWQ002_EVIDENCE\"}")

# ============================================================
# SWQ-005: Security (Credential Scan)
# ============================================================
echo -e "${BLUE}[SWQ-005]${NC} Scanning for credentials..."

SWQ005_STATUS="pass"
SWQ005_EVIDENCE=""

# Check staged changes for secrets
if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get list of changed files
    CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")

    if [ -n "$CHANGED_FILES" ]; then
        # Scan for secret patterns
        SECRET_PATTERNS="password|secret|api_key|apikey|token|credential|private_key|aws_access|sk-ant-|sk-[a-zA-Z0-9]{20,}|ghp_|gho_"

        SECRETS_FOUND=0
        for file in $CHANGED_FILES; do
            if [ -f "$file" ]; then
                FILE_SECRETS=$(grep -ciE "$SECRET_PATTERNS" "$file" 2>/dev/null | tr -d '\n ' || echo "0")
                FILE_SECRETS=${FILE_SECRETS:-0}
                SECRETS_FOUND=$((SECRETS_FOUND + FILE_SECRETS))
            fi
        done

        if [ "$SECRETS_FOUND" -eq 0 ]; then
            SWQ005_STATUS="pass"
            SWQ005_EVIDENCE="No credential patterns detected in changed files"
            ((CONTROLS_PASSED++))
        else
            SWQ005_STATUS="warn"
            SWQ005_EVIDENCE="$SECRETS_FOUND potential credential patterns found - manual review recommended"
            ((CONTROLS_WARNED++))
        fi
    else
        SWQ005_STATUS="info"
        SWQ005_EVIDENCE="No changed files to scan"
    fi
else
    SWQ005_STATUS="info"
    SWQ005_EVIDENCE="Not in a git repository"
fi

if [ "$SWQ005_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $SWQ005_EVIDENCE"
elif [ "$SWQ005_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $SWQ005_EVIDENCE"
else
    echo -e "  INFO: $SWQ005_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"SWQ-005\", \"status\": \"$SWQ005_STATUS\", \"evidence\": \"$SWQ005_EVIDENCE\"}")

# ============================================================
# QMS-010: Change Control (Scope Check)
# ============================================================
echo -e "${BLUE}[QMS-010]${NC} Verifying change scope..."

QMS010_STATUS="pass"
QMS010_EVIDENCE=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
    FILES_CHANGED=$(git diff --cached --name-only 2>/dev/null | wc -l || git diff --name-only HEAD~1 2>/dev/null | wc -l || echo "0")
    FILES_CHANGED=$(echo "$FILES_CHANGED" | tr -d ' ')

    if [ "$FILES_CHANGED" -lt 10 ]; then
        QMS010_STATUS="pass"
        QMS010_EVIDENCE="$FILES_CHANGED files changed (within expected scope for single task)"
        ((CONTROLS_PASSED++))
    elif [ "$FILES_CHANGED" -lt 20 ]; then
        QMS010_STATUS="warn"
        QMS010_EVIDENCE="$FILES_CHANGED files changed (larger than typical task scope)"
        ((CONTROLS_WARNED++))
    else
        QMS010_STATUS="warn"
        QMS010_EVIDENCE="$FILES_CHANGED files changed (very large scope - consider splitting)"
        ((CONTROLS_WARNED++))
    fi
else
    QMS010_STATUS="info"
    QMS010_EVIDENCE="Not in a git repository - cannot check scope"
fi

if [ "$QMS010_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS010_EVIDENCE"
elif [ "$QMS010_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS010_EVIDENCE"
else
    echo -e "  INFO: $QMS010_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-010\", \"status\": \"$QMS010_STATUS\", \"evidence\": \"$QMS010_EVIDENCE\"}")

# ============================================================
# QMS-012: Security Review (Lint)
# ============================================================
echo -e "${BLUE}[QMS-012]${NC} Running lint check..."

QMS012_STATUS="pass"
QMS012_EVIDENCE=""

if [ -f "package.json" ]; then
    if grep -q '"lint"' package.json 2>/dev/null; then
        LINT_OUTPUT=$(npm run lint 2>&1) || true
        LINT_EXIT=$?

        if [ $LINT_EXIT -eq 0 ]; then
            QMS012_STATUS="pass"
            QMS012_EVIDENCE="npm run lint passed"
            ((CONTROLS_PASSED++))
        else
            ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -cE "error|Error" | tr -d '\n ' || echo "0")
            ERROR_COUNT=${ERROR_COUNT:-0}
            QMS012_STATUS="warn"
            QMS012_EVIDENCE="Lint found $ERROR_COUNT issues"
            ((CONTROLS_WARNED++))
        fi
    else
        QMS012_STATUS="info"
        QMS012_EVIDENCE="No lint script found"
    fi
elif [ -f "pyproject.toml" ]; then
    if command -v ruff &> /dev/null; then
        LINT_OUTPUT=$(ruff check . 2>&1) || true
        if [ $? -eq 0 ]; then
            QMS012_STATUS="pass"
            QMS012_EVIDENCE="ruff check passed"
            ((CONTROLS_PASSED++))
        else
            QMS012_STATUS="warn"
            QMS012_EVIDENCE="ruff found lint issues"
            ((CONTROLS_WARNED++))
        fi
    else
        QMS012_STATUS="info"
        QMS012_EVIDENCE="Python project - ruff not available"
    fi
else
    QMS012_STATUS="info"
    QMS012_EVIDENCE="No lint tool detected"
fi

if [ "$QMS012_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS012_EVIDENCE"
elif [ "$QMS012_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS012_EVIDENCE"
else
    echo -e "  INFO: $QMS012_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-012\", \"status\": \"$QMS012_STATUS\", \"evidence\": \"$QMS012_EVIDENCE\"}")

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
  "gate": "3",
  "name": "Pre-Commit",
  "task_id": "$TASK_ID",
  "timestamp": "$TIMESTAMP",
  "controls_passed": $CONTROLS_PASSED,
  "controls_failed": $CONTROLS_FAILED,
  "controls_warned": $CONTROLS_WARNED,
  "controls_executed": [$EVIDENCE_JSON],
  "overall_status": "$OVERALL_STATUS"
}
EOF

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo -e "${BLUE}[Gate 3] Summary - Task: $TASK_ID${NC}"
echo "  Passed:  $CONTROLS_PASSED"
echo "  Warned:  $CONTROLS_WARNED"
echo "  Failed:  $CONTROLS_FAILED"
echo "  Evidence: $AUDIT_FILE"
echo ""

if [ "$CONTROLS_FAILED" -gt 0 ]; then
    echo -e "${RED}[Gate 3] FAILED${NC}"
    echo "Fix the failing checks before marking task complete"
    exit 1
elif [ "$CONTROLS_WARNED" -gt 0 ]; then
    echo -e "${YELLOW}[Gate 3] PASSED WITH WARNINGS${NC}"
    exit 0
else
    echo -e "${GREEN}[Gate 3] PASSED${NC}"
    exit 0
fi
