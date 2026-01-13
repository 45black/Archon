#!/bin/bash
# Gate 2: Task Plan Validation
# ISO Controls: QMS-005, QMS-006, QMS-007, QMS-008, AIM-003
#
# This gate validates task quality, especially QMS-008 (Anti-Rubber-Stamp)
# which ensures acceptance criteria actually EXECUTE verification.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
PRD_FILE="${1:-$RALPH_DIR/progress.txt}"
CONFIG_FILE="$RALPH_DIR/feature-config.txt"
AUDIT_DIR="$RALPH_DIR/audit"
AUDIT_FILE="$AUDIT_DIR/gate-2-plan.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialize results
CONTROLS_PASSED=0
CONTROLS_FAILED=0
CONTROLS_WARNED=0
declare -a EVIDENCE

echo -e "${BLUE}[Gate 2] Task Plan Validation${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Ensure audit directory exists
mkdir -p "$AUDIT_DIR"

# ============================================================
# QMS-005: Work Breakdown Verification
# ============================================================
echo -e "${BLUE}[QMS-005]${NC} Checking work breakdown structure..."

QMS005_STATUS="pass"
QMS005_EVIDENCE=""

if [ -f "$CONFIG_FILE" ]; then
    TASK_COUNT=$(grep "task_count=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "0")

    if [ -n "$TASK_COUNT" ] && [ "$TASK_COUNT" -gt 0 ]; then
        QMS005_STATUS="pass"
        QMS005_EVIDENCE="Work breakdown complete: $TASK_COUNT tasks defined"
        ((CONTROLS_PASSED++))
    else
        QMS005_STATUS="info"
        QMS005_EVIDENCE="Task count not specified - cannot validate breakdown"
    fi
else
    QMS005_STATUS="info"
    QMS005_EVIDENCE="feature-config.txt not found - work breakdown validation skipped"
fi

if [ "$QMS005_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS005_EVIDENCE"
else
    echo -e "  INFO: $QMS005_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-005\", \"status\": \"$QMS005_STATUS\", \"evidence\": \"$QMS005_EVIDENCE\"}")

# ============================================================
# QMS-006: Context Window Fit
# ============================================================
echo -e "${BLUE}[QMS-006]${NC} Checking context window constraints..."

QMS006_STATUS="pass"
QMS006_EVIDENCE=""

if [ -f "$PRD_FILE" ]; then
    # Check file size as proxy for context fit
    FILE_SIZE=$(wc -c < "$PRD_FILE")

    if [ "$FILE_SIZE" -lt 50000 ]; then
        QMS006_STATUS="pass"
        QMS006_EVIDENCE="Progress file size (${FILE_SIZE} bytes) within context limits"
        ((CONTROLS_PASSED++))
    else
        QMS006_STATUS="warn"
        QMS006_EVIDENCE="Progress file large (${FILE_SIZE} bytes) - may impact context window"
        ((CONTROLS_WARNED++))
    fi
else
    QMS006_STATUS="info"
    QMS006_EVIDENCE="Progress file not found - cannot assess context usage"
fi

if [ "$QMS006_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS006_EVIDENCE"
elif [ "$QMS006_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS006_EVIDENCE"
else
    echo -e "  INFO: $QMS006_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-006\", \"status\": \"$QMS006_STATUS\", \"evidence\": \"$QMS006_EVIDENCE\"}")

# ============================================================
# QMS-007: Acceptance Criteria Verifiability
# ============================================================
echo -e "${BLUE}[QMS-007]${NC} Checking acceptance criteria verifiability..."

QMS007_STATUS="pass"
QMS007_EVIDENCE=""

# Look for verification-style patterns in acceptance criteria
if [ -f "$PRD_FILE" ]; then
    # Count patterns that indicate executable verification (clean output to ensure integer)
    EXEC_PATTERNS=$(grep -ciE "npm (run |test)|passes|returns|equals|outputs|shows|matches|HTTP [0-9]" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    EXEC_PATTERNS=${EXEC_PATTERNS:-0}

    if [ "$EXEC_PATTERNS" -gt 0 ]; then
        QMS007_STATUS="pass"
        QMS007_EVIDENCE="Found $EXEC_PATTERNS executable verification patterns"
        ((CONTROLS_PASSED++))
    else
        QMS007_STATUS="warn"
        QMS007_EVIDENCE="No executable verification patterns detected - check acceptance criteria"
        ((CONTROLS_WARNED++))
    fi
else
    QMS007_STATUS="info"
    QMS007_EVIDENCE="Cannot verify - progress file not found"
fi

if [ "$QMS007_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS007_EVIDENCE"
elif [ "$QMS007_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS007_EVIDENCE"
else
    echo -e "  INFO: $QMS007_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-007\", \"status\": \"$QMS007_STATUS\", \"evidence\": \"$QMS007_EVIDENCE\"}")

# ============================================================
# QMS-008: Anti-Rubber-Stamp Validation (CRITICAL)
# ============================================================
echo -e "${CYAN}[QMS-008]${NC} ${CYAN}CRITICAL: Anti-Rubber-Stamp Validation${NC}"

QMS008_STATUS="pass"
QMS008_EVIDENCE=""
RUBBER_STAMP_COUNT=0
VERIFICATION_COUNT=0

# Rubber-stamp patterns (BAD - just check existence)
RUBBER_STAMP_PATTERNS="exists|is available|was created|is defined|renders|file created|function defined|component renders|endpoint exists|table exists|database available"

# Verification patterns (GOOD - actually execute and compare)
VERIFICATION_PATTERNS="returns|outputs|equals|matches|passes|shows [0-9]|HTTP [0-9]|status [0-9]|count.*[0-9]|npm (run|test)|npx|curl.*returns|query.*returns"

if [ -f "$PRD_FILE" ]; then
    # Count rubber-stamp patterns (clean output to ensure integer)
    RUBBER_STAMP_COUNT=$(grep -ciE "$RUBBER_STAMP_PATTERNS" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    RUBBER_STAMP_COUNT=${RUBBER_STAMP_COUNT:-0}

    # Count verification patterns (clean output to ensure integer)
    VERIFICATION_COUNT=$(grep -ciE "$VERIFICATION_PATTERNS" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    VERIFICATION_COUNT=${VERIFICATION_COUNT:-0}

    echo "  Rubber-stamp patterns found: $RUBBER_STAMP_COUNT"
    echo "  Verification patterns found: $VERIFICATION_COUNT"

    if [ "$RUBBER_STAMP_COUNT" -eq 0 ]; then
        QMS008_STATUS="pass"
        QMS008_EVIDENCE="No rubber-stamp patterns detected. $VERIFICATION_COUNT verification patterns found."
        ((CONTROLS_PASSED++))
    elif [ "$VERIFICATION_COUNT" -gt "$RUBBER_STAMP_COUNT" ]; then
        QMS008_STATUS="warn"
        QMS008_EVIDENCE="$RUBBER_STAMP_COUNT rubber-stamp patterns found but $VERIFICATION_COUNT verifications - acceptable but review recommended"
        ((CONTROLS_WARNED++))
    else
        QMS008_STATUS="fail"
        QMS008_EVIDENCE="$RUBBER_STAMP_COUNT rubber-stamp patterns exceed $VERIFICATION_COUNT verifications - REWRITE acceptance criteria to EXECUTE tests"
        ((CONTROLS_FAILED++))

        # Show examples of what to fix
        echo ""
        echo -e "  ${RED}Rubber-stamp patterns detected (examples):${NC}"
        grep -iE "$RUBBER_STAMP_PATTERNS" "$PRD_FILE" 2>/dev/null | head -3 | while read line; do
            echo "    - $line"
        done
        echo ""
        echo -e "  ${GREEN}Expected patterns (use these instead):${NC}"
        echo "    - npm run typecheck passes with 0 errors"
        echo "    - npm test -- [test-name] shows all tests passing"
        echo "    - Function foo(x) returns expected_value"
        echo "    - API call returns HTTP 200 with {expected: data}"
    fi
else
    QMS008_STATUS="info"
    QMS008_EVIDENCE="Cannot validate - progress file not found"
fi

if [ "$QMS008_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS008_EVIDENCE"
elif [ "$QMS008_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS008_EVIDENCE"
elif [ "$QMS008_STATUS" = "fail" ]; then
    echo -e "  ${RED}FAIL${NC}: $QMS008_EVIDENCE"
else
    echo -e "  INFO: $QMS008_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-008\", \"status\": \"$QMS008_STATUS\", \"evidence\": \"$QMS008_EVIDENCE\", \"rubber_stamp_count\": $RUBBER_STAMP_COUNT, \"verification_count\": $VERIFICATION_COUNT}")

# ============================================================
# AIM-003: Adversarial Review Trigger
# ============================================================
echo -e "${BLUE}[AIM-003]${NC} Checking adversarial review configuration..."

AIM003_STATUS="pass"
AIM003_EVIDENCE=""

# Get settings from Gate 1 or config file
if [ -f "$CONFIG_FILE" ]; then
    ADVERSARIAL_SETTING=$(grep "adversarial_review=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "optional")
    DOMAIN=$(grep "domain=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "standard")

    if [ -n "$ADVERSARIAL_SETTING" ]; then
        AIM003_STATUS="pass"
        AIM003_EVIDENCE="Adversarial review configured: $ADVERSARIAL_SETTING (domain: $DOMAIN)"
        ((CONTROLS_PASSED++))

        # Export for use in iteration loop
        export RALPH_ADVERSARIAL_REVIEW="$ADVERSARIAL_SETTING"
        export RALPH_DOMAIN="$DOMAIN"
    else
        AIM003_STATUS="warn"
        AIM003_EVIDENCE="Adversarial review not configured - defaulting to 'optional'"
        ((CONTROLS_WARNED++))
    fi
else
    AIM003_STATUS="warn"
    AIM003_EVIDENCE="feature-config.txt not found - adversarial review setting unknown"
    ((CONTROLS_WARNED++))
fi

if [ "$AIM003_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $AIM003_EVIDENCE"
else
    echo -e "  ${YELLOW}WARN${NC}: $AIM003_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"AIM-003\", \"status\": \"$AIM003_STATUS\", \"evidence\": \"$AIM003_EVIDENCE\"}")

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
  "gate": "2",
  "name": "Task Plan",
  "timestamp": "$TIMESTAMP",
  "controls_passed": $CONTROLS_PASSED,
  "controls_failed": $CONTROLS_FAILED,
  "controls_warned": $CONTROLS_WARNED,
  "qms008_rubber_stamps": $RUBBER_STAMP_COUNT,
  "qms008_verifications": $VERIFICATION_COUNT,
  "controls_executed": [$EVIDENCE_JSON],
  "overall_status": "$OVERALL_STATUS"
}
EOF

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo -e "${BLUE}[Gate 2] Summary${NC}"
echo "  Passed:  $CONTROLS_PASSED"
echo "  Warned:  $CONTROLS_WARNED"
echo "  Failed:  $CONTROLS_FAILED"
echo "  QMS-008: $RUBBER_STAMP_COUNT rubber-stamps, $VERIFICATION_COUNT verifications"
echo "  Evidence: $AUDIT_FILE"
echo ""

if [ "$CONTROLS_FAILED" -gt 0 ]; then
    echo -e "${RED}[Gate 2] FAILED - Cannot proceed${NC}"
    echo ""
    echo "To fix QMS-008 violations:"
    echo "1. Review task acceptance criteria in Archon"
    echo "2. Replace 'exists/available/created' with 'returns/passes/equals'"
    echo "3. Add specific expected values to each criterion"
    echo "4. Re-run this gate"
    exit 1
elif [ "$CONTROLS_WARNED" -gt 0 ]; then
    echo -e "${YELLOW}[Gate 2] PASSED WITH WARNINGS${NC}"
    echo "Consider addressing warnings for full ISO compliance"
    exit 0
else
    echo -e "${GREEN}[Gate 2] PASSED${NC}"
    exit 0
fi
