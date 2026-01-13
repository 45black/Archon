#!/bin/bash
# Gate 1: PRD Quality Validation
# ISO Controls: QMS-001, QMS-002, QMS-003, QMS-004, AIM-001
#
# This gate validates that the PRD/feature setup meets quality requirements
# before allowing Ralph to proceed with execution.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
PRD_FILE="${1:-$RALPH_DIR/progress.txt}"
CONFIG_FILE="$RALPH_DIR/feature-config.txt"
AUDIT_DIR="$RALPH_DIR/audit"
AUDIT_FILE="$AUDIT_DIR/gate-1-prd.json"
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

echo -e "${BLUE}[Gate 1] PRD Quality Validation${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Ensure audit directory exists
mkdir -p "$AUDIT_DIR"

# ============================================================
# QMS-001: Requirements Documentation
# ============================================================
echo -e "${BLUE}[QMS-001]${NC} Checking requirements documentation..."

QMS001_STATUS="fail"
QMS001_EVIDENCE=""

if [ -f "$PRD_FILE" ]; then
    # Check for required sections (clean output to ensure integer)
    HAS_DOMAIN=$(grep -c "## Domain Classification" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_ISO=$(grep -c "## ISO Controls Applied" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_PATTERNS=$(grep -c "## Codebase Patterns" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_ITERATIONS=$(grep -c "## Iterations" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_DOMAIN=${HAS_DOMAIN:-0}; HAS_ISO=${HAS_ISO:-0}; HAS_PATTERNS=${HAS_PATTERNS:-0}; HAS_ITERATIONS=${HAS_ITERATIONS:-0}

    if [ "$HAS_PATTERNS" -gt 0 ] && [ "$HAS_ITERATIONS" -gt 0 ]; then
        if [ "$HAS_DOMAIN" -gt 0 ] && [ "$HAS_ISO" -gt 0 ]; then
            QMS001_STATUS="pass"
            QMS001_EVIDENCE="PRD has all v2.0 sections (Domain, ISO Controls, Patterns, Iterations)"
            ((CONTROLS_PASSED++))
        else
            QMS001_STATUS="warn"
            QMS001_EVIDENCE="PRD has basic sections but missing ISO v2.0 sections (Domain Classification, ISO Controls)"
            ((CONTROLS_WARNED++))
        fi
    else
        QMS001_STATUS="fail"
        QMS001_EVIDENCE="PRD missing required sections (Codebase Patterns, Iterations)"
        ((CONTROLS_FAILED++))
    fi
else
    QMS001_EVIDENCE="progress.txt not found at $PRD_FILE"
    ((CONTROLS_FAILED++))
fi

if [ "$QMS001_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS001_EVIDENCE"
elif [ "$QMS001_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS001_EVIDENCE"
else
    echo -e "  ${RED}FAIL${NC}: $QMS001_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-001\", \"status\": \"$QMS001_STATUS\", \"evidence\": \"$QMS001_EVIDENCE\"}")

# ============================================================
# QMS-003: Ambiguity Detection
# ============================================================
echo -e "${BLUE}[QMS-003]${NC} Checking for ambiguous language..."

QMS003_STATUS="pass"
QMS003_EVIDENCE=""

if [ -f "$PRD_FILE" ]; then
    # Count ambiguous terms (case insensitive, clean output)
    AMBIGUOUS_COUNT=$(grep -ciE "\bshould\b|\bproperly\b|\bhandles\b|\bappropriate\b|\breasonable\b|\bsufficient\b" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    AMBIGUOUS_COUNT=${AMBIGUOUS_COUNT:-0}

    if [ "$AMBIGUOUS_COUNT" -eq 0 ]; then
        QMS003_STATUS="pass"
        QMS003_EVIDENCE="Zero ambiguous terms detected"
        ((CONTROLS_PASSED++))
    elif [ "$AMBIGUOUS_COUNT" -lt 3 ]; then
        QMS003_STATUS="warn"
        QMS003_EVIDENCE="$AMBIGUOUS_COUNT ambiguous terms found (should, properly, handles, appropriate, reasonable, sufficient)"
        ((CONTROLS_WARNED++))
    else
        QMS003_STATUS="fail"
        QMS003_EVIDENCE="$AMBIGUOUS_COUNT ambiguous terms found - rewrite with specific language (must, shall, returns, equals)"
        ((CONTROLS_FAILED++))
    fi
else
    QMS003_STATUS="skip"
    QMS003_EVIDENCE="Cannot check - progress.txt not found"
fi

if [ "$QMS003_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS003_EVIDENCE"
elif [ "$QMS003_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS003_EVIDENCE"
elif [ "$QMS003_STATUS" = "fail" ]; then
    echo -e "  ${RED}FAIL${NC}: $QMS003_EVIDENCE"
else
    echo -e "  SKIP: $QMS003_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-003\", \"status\": \"$QMS003_STATUS\", \"evidence\": \"$QMS003_EVIDENCE\"}")

# ============================================================
# QMS-004: Resource Planning
# ============================================================
echo -e "${BLUE}[QMS-004]${NC} Checking resource estimates..."

QMS004_STATUS="pass"
QMS004_EVIDENCE=""

if [ -f "$CONFIG_FILE" ]; then
    TASK_COUNT=$(grep "task_count=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "0")

    if [ -n "$TASK_COUNT" ] && [ "$TASK_COUNT" -gt 0 ]; then
        if [ "$TASK_COUNT" -ge 10 ] && [ "$TASK_COUNT" -le 25 ]; then
            QMS004_STATUS="pass"
            QMS004_EVIDENCE="Task count ($TASK_COUNT) within optimal range (10-25)"
            ((CONTROLS_PASSED++))
        elif [ "$TASK_COUNT" -lt 10 ]; then
            QMS004_STATUS="warn"
            QMS004_EVIDENCE="Task count ($TASK_COUNT) below typical range - ensure tasks aren't too large"
            ((CONTROLS_WARNED++))
        else
            QMS004_STATUS="warn"
            QMS004_EVIDENCE="Task count ($TASK_COUNT) above typical range (10-25) - consider splitting feature"
            ((CONTROLS_WARNED++))
        fi
    else
        QMS004_STATUS="info"
        QMS004_EVIDENCE="Task count not specified in feature-config.txt"
    fi
else
    QMS004_STATUS="info"
    QMS004_EVIDENCE="feature-config.txt not found - resource estimates not available"
fi

if [ "$QMS004_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS004_EVIDENCE"
elif [ "$QMS004_STATUS" = "warn" ]; then
    echo -e "  ${YELLOW}WARN${NC}: $QMS004_EVIDENCE"
else
    echo -e "  INFO: $QMS004_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-004\", \"status\": \"$QMS004_STATUS\", \"evidence\": \"$QMS004_EVIDENCE\"}")

# ============================================================
# AIM-001: AI Impact Assessment / Domain Classification
# ============================================================
echo -e "${BLUE}[AIM-001]${NC} Checking domain classification..."

AIM001_STATUS="pass"
AIM001_EVIDENCE=""
DOMAIN="standard"
ADVERSARIAL_REQUIRED="optional"

if [ -f "$CONFIG_FILE" ]; then
    DOMAIN=$(grep "domain=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "standard")
    ADVERSARIAL_REQUIRED=$(grep "adversarial_review=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "optional")

    if [ -n "$DOMAIN" ]; then
        AIM001_STATUS="pass"
        AIM001_EVIDENCE="Domain: $DOMAIN, Adversarial Review: $ADVERSARIAL_REQUIRED"
        ((CONTROLS_PASSED++))

        # Check if regulated domain has appropriate adversarial setting
        if [[ "$DOMAIN" =~ ^(Pensions|Legal|Security)$ ]] && [ "$ADVERSARIAL_REQUIRED" != "mandatory" ]; then
            AIM001_STATUS="warn"
            AIM001_EVIDENCE="Regulated domain ($DOMAIN) should have adversarial_review=mandatory"
            ((CONTROLS_WARNED++))
        fi
    else
        AIM001_STATUS="warn"
        AIM001_EVIDENCE="Domain not classified - defaulting to 'standard'"
        ((CONTROLS_WARNED++))
    fi
elif [ -f "$PRD_FILE" ]; then
    # Try to detect domain from progress.txt
    HAS_PENSIONS=$(grep -ciE "pension|LGPS|trustee|scheme|TPR" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_LEGAL=$(grep -ciE "legal|legislation|act|regulation|compliance" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    HAS_SECURITY=$(grep -ciE "auth|credential|permission|encrypt|security" "$PRD_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    # Ensure values are integers
    HAS_PENSIONS=${HAS_PENSIONS:-0}
    HAS_LEGAL=${HAS_LEGAL:-0}
    HAS_SECURITY=${HAS_SECURITY:-0}

    if [ "$HAS_PENSIONS" -gt 2 ]; then
        DOMAIN="Pensions"
        ADVERSARIAL_REQUIRED="mandatory"
        AIM001_STATUS="warn"
        AIM001_EVIDENCE="Auto-detected domain: Pensions (adversarial review MANDATORY) - please create feature-config.txt"
    elif [ "$HAS_LEGAL" -gt 2 ]; then
        DOMAIN="Legal"
        ADVERSARIAL_REQUIRED="mandatory"
        AIM001_STATUS="warn"
        AIM001_EVIDENCE="Auto-detected domain: Legal (adversarial review MANDATORY) - please create feature-config.txt"
    elif [ "$HAS_SECURITY" -gt 2 ]; then
        DOMAIN="Security"
        ADVERSARIAL_REQUIRED="mandatory"
        AIM001_STATUS="warn"
        AIM001_EVIDENCE="Auto-detected domain: Security (adversarial review MANDATORY) - please create feature-config.txt"
    else
        AIM001_STATUS="pass"
        AIM001_EVIDENCE="Domain: Standard (auto-detected, no regulated keywords found)"
        ((CONTROLS_PASSED++))
    fi

    if [ "$AIM001_STATUS" = "warn" ]; then
        ((CONTROLS_WARNED++))
    fi
else
    AIM001_STATUS="warn"
    AIM001_EVIDENCE="Cannot determine domain - no config or progress file found"
    ((CONTROLS_WARNED++))
fi

if [ "$AIM001_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $AIM001_EVIDENCE"
else
    echo -e "  ${YELLOW}WARN${NC}: $AIM001_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"AIM-001\", \"status\": \"$AIM001_STATUS\", \"evidence\": \"$AIM001_EVIDENCE\"}")

# Export for use by other scripts
export RALPH_DOMAIN="$DOMAIN"
export RALPH_ADVERSARIAL_REVIEW="$ADVERSARIAL_REQUIRED"

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
  "gate": "1",
  "name": "PRD Quality",
  "timestamp": "$TIMESTAMP",
  "controls_passed": $CONTROLS_PASSED,
  "controls_failed": $CONTROLS_FAILED,
  "controls_warned": $CONTROLS_WARNED,
  "domain": "$DOMAIN",
  "adversarial_review": "$ADVERSARIAL_REQUIRED",
  "controls_executed": [$EVIDENCE_JSON],
  "overall_status": "$OVERALL_STATUS"
}
EOF

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo -e "${BLUE}[Gate 1] Summary${NC}"
echo "  Passed:  $CONTROLS_PASSED"
echo "  Warned:  $CONTROLS_WARNED"
echo "  Failed:  $CONTROLS_FAILED"
echo "  Domain:  $DOMAIN"
echo "  Adversarial: $ADVERSARIAL_REQUIRED"
echo "  Evidence: $AUDIT_FILE"
echo ""

if [ "$CONTROLS_FAILED" -gt 0 ]; then
    echo -e "${RED}[Gate 1] FAILED - Cannot proceed${NC}"
    echo "Fix the issues above and re-run"
    exit 1
elif [ "$CONTROLS_WARNED" -gt 0 ]; then
    echo -e "${YELLOW}[Gate 1] PASSED WITH WARNINGS${NC}"
    echo "Consider addressing warnings for full ISO compliance"
    exit 0
else
    echo -e "${GREEN}[Gate 1] PASSED${NC}"
    exit 0
fi
