#!/bin/bash
# Post-Gate: Compound Review & Learning Capture
# ISO Controls: QMS-017, QMS-018, QMS-019, QMS-020, AIM-008, MLL-005
#
# This script runs after a feature completes to capture learnings,
# archive evidence, and update knowledge bases.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$RALPH_DIR/feature-config.txt"
PROGRESS_FILE="$RALPH_DIR/progress.txt"
AUDIT_DIR="$RALPH_DIR/audit"
AUDIT_FILE="$AUDIT_DIR/compound.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get feature slug
FEATURE_SLUG="unknown"
if [ -f "$CONFIG_FILE" ]; then
    FEATURE_SLUG=$(grep "feature_slug=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "unknown")
elif [ -f "$RALPH_DIR/current-feature.txt" ]; then
    FEATURE_SLUG=$(cat "$RALPH_DIR/current-feature.txt")
fi

echo -e "${CYAN}[Post-Gate] Compound Review: $FEATURE_SLUG${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Initialize results
CONTROLS_PASSED=0
CONTROLS_WARNED=0
declare -a EVIDENCE

# ============================================================
# QMS-017: Learning Capture
# ============================================================
echo -e "${BLUE}[QMS-017]${NC} Capturing learnings..."

QMS017_STATUS="pass"
QMS017_EVIDENCE=""
PATTERN_COUNT=0
ITERATION_COUNT=0

if [ -f "$PROGRESS_FILE" ]; then
    # Count patterns discovered (clean output)
    PATTERN_COUNT=$(grep -c "Pattern:\|pattern:\|- \*\*" "$PROGRESS_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    PATTERN_COUNT=${PATTERN_COUNT:-0}

    # Count iterations completed (clean output)
    ITERATION_COUNT=$(grep -c "^\d\+\.\|^[0-9]\+\." "$PROGRESS_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    ITERATION_COUNT=${ITERATION_COUNT:-0}

    if [ "$PATTERN_COUNT" -gt 0 ]; then
        QMS017_STATUS="pass"
        QMS017_EVIDENCE="$PATTERN_COUNT patterns captured across $ITERATION_COUNT iterations"
        ((CONTROLS_PASSED++))
    else
        QMS017_STATUS="warn"
        QMS017_EVIDENCE="No patterns explicitly captured - consider documenting learnings"
        ((CONTROLS_WARNED++))
    fi
else
    QMS017_STATUS="warn"
    QMS017_EVIDENCE="progress.txt not found - no learnings captured"
    ((CONTROLS_WARNED++))
fi

if [ "$QMS017_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS017_EVIDENCE"
else
    echo -e "  ${YELLOW}WARN${NC}: $QMS017_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-017\", \"status\": \"$QMS017_STATUS\", \"evidence\": \"$QMS017_EVIDENCE\", \"patterns\": $PATTERN_COUNT, \"iterations\": $ITERATION_COUNT}")

# ============================================================
# QMS-018: Nonconformity Documentation
# ============================================================
echo -e "${BLUE}[QMS-018]${NC} Documenting failures..."

QMS018_STATUS="pass"
QMS018_EVIDENCE=""
FAILURE_COUNT=0

if [ -f "$PROGRESS_FILE" ]; then
    FAILURE_COUNT=$(grep -c "FAIL\|ERROR\|failed\|error:" "$PROGRESS_FILE" 2>/dev/null | tr -d '\n ' || echo "0")
    FAILURE_COUNT=${FAILURE_COUNT:-0}

    if [ "$FAILURE_COUNT" -gt 0 ]; then
        QMS018_STATUS="pass"
        QMS018_EVIDENCE="$FAILURE_COUNT failures documented in progress.txt"
        ((CONTROLS_PASSED++))

        # Check if we should create/update ADVERSE-LOG.md
        if [ "$FAILURE_COUNT" -gt 2 ]; then
            echo "  Creating entry in ADVERSE-LOG.md..."
            ADVERSE_LOG="$RALPH_DIR/../../ADVERSE-LOG.md"

            if [ ! -f "$ADVERSE_LOG" ]; then
                echo "# Adverse Event Log" > "$ADVERSE_LOG"
                echo "" >> "$ADVERSE_LOG"
                echo "Log of significant failures and issues during Ralph execution." >> "$ADVERSE_LOG"
                echo "" >> "$ADVERSE_LOG"
            fi

            echo "## $FEATURE_SLUG - $(date +%Y-%m-%d)" >> "$ADVERSE_LOG"
            echo "" >> "$ADVERSE_LOG"
            echo "**Failures:** $FAILURE_COUNT" >> "$ADVERSE_LOG"
            echo "" >> "$ADVERSE_LOG"
            grep -E "FAIL|ERROR|failed" "$PROGRESS_FILE" 2>/dev/null | head -5 >> "$ADVERSE_LOG" || true
            echo "" >> "$ADVERSE_LOG"
            echo "---" >> "$ADVERSE_LOG"
            echo "" >> "$ADVERSE_LOG"
        fi
    else
        QMS018_STATUS="pass"
        QMS018_EVIDENCE="No failures to document - clean execution"
        ((CONTROLS_PASSED++))
    fi
else
    QMS018_STATUS="info"
    QMS018_EVIDENCE="No progress file to analyze"
fi

if [ "$QMS018_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS018_EVIDENCE"
else
    echo -e "  INFO: $QMS018_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-018\", \"status\": \"$QMS018_STATUS\", \"evidence\": \"$QMS018_EVIDENCE\", \"failures\": $FAILURE_COUNT}")

# ============================================================
# QMS-020: Handoff Documentation
# ============================================================
echo -e "${BLUE}[QMS-020]${NC} Preparing handoff documentation..."

QMS020_STATUS="pass"
QMS020_EVIDENCE=""

# Look for HANDOFF.md in common locations
HANDOFF_FILE=""
for path in "$RALPH_DIR/../../HANDOFF.md" "./HANDOFF.md" "../HANDOFF.md"; do
    if [ -f "$path" ]; then
        HANDOFF_FILE="$path"
        break
    fi
done

if [ -n "$HANDOFF_FILE" ]; then
    echo "  Updating $HANDOFF_FILE..."

    # Count completed tasks from audit files
    COMPLETED_TASKS=$(ls -1 "$AUDIT_DIR/gate-4/" 2>/dev/null | wc -l || echo "0")
    COMPLETED_TASKS=$(echo "$COMPLETED_TASKS" | tr -d ' ')

    # Add completion entry
    cat >> "$HANDOFF_FILE" <<EOF

## $FEATURE_SLUG - Completed $(date +%Y-%m-%d)

- **Tasks completed:** $COMPLETED_TASKS
- **Patterns captured:** $PATTERN_COUNT
- **Failures logged:** $FAILURE_COUNT
- **Audit trail:** scripts/ralph/audit/
- **Archive:** scripts/ralph/archive/$(date +%Y-%m-%d)-$FEATURE_SLUG/

EOF

    QMS020_STATUS="pass"
    QMS020_EVIDENCE="HANDOFF.md updated with completion summary"
    ((CONTROLS_PASSED++))
else
    QMS020_STATUS="warn"
    QMS020_EVIDENCE="HANDOFF.md not found - handoff documentation skipped"
    ((CONTROLS_WARNED++))
fi

if [ "$QMS020_STATUS" = "pass" ]; then
    echo -e "  ${GREEN}PASS${NC}: $QMS020_EVIDENCE"
else
    echo -e "  ${YELLOW}WARN${NC}: $QMS020_EVIDENCE"
fi

EVIDENCE+=("{\"control_id\": \"QMS-020\", \"status\": \"$QMS020_STATUS\", \"evidence\": \"$QMS020_EVIDENCE\"}")

# ============================================================
# MLL-005: Continuous Learning (Archive)
# ============================================================
echo -e "${BLUE}[MLL-005]${NC} Archiving session..."

MLL005_STATUS="pass"
MLL005_EVIDENCE=""

ARCHIVE_DIR="$RALPH_DIR/archive/$(date +%Y-%m-%d)-$FEATURE_SLUG"
mkdir -p "$ARCHIVE_DIR"

# Copy audit files
if [ -d "$AUDIT_DIR" ]; then
    cp -r "$AUDIT_DIR" "$ARCHIVE_DIR/" 2>/dev/null || true
fi

# Copy progress file
if [ -f "$PROGRESS_FILE" ]; then
    cp "$PROGRESS_FILE" "$ARCHIVE_DIR/" 2>/dev/null || true
fi

# Copy config file
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$ARCHIVE_DIR/" 2>/dev/null || true
fi

# Copy adversarial reviews
if [ -d "$RALPH_DIR/adversarial" ]; then
    cp -r "$RALPH_DIR/adversarial" "$ARCHIVE_DIR/" 2>/dev/null || true
fi

# Create archive manifest
cat > "$ARCHIVE_DIR/MANIFEST.md" <<EOF
# Archive Manifest: $FEATURE_SLUG

**Archived:** $(date)
**Feature:** $FEATURE_SLUG
**Iterations:** $ITERATION_COUNT
**Patterns:** $PATTERN_COUNT
**Failures:** $FAILURE_COUNT

## Contents

- audit/ - Gate verification evidence
- adversarial/ - Adversarial review outputs (if any)
- progress.txt - Execution log
- feature-config.txt - Feature configuration

## ISO Controls Executed

- QMS-017: Learning Capture - $PATTERN_COUNT patterns
- QMS-018: Nonconformity Documentation - $FAILURE_COUNT failures
- QMS-020: Handoff Documentation
- MLL-005: Continuous Learning (this archive)
EOF

MLL005_STATUS="pass"
MLL005_EVIDENCE="Session archived to $ARCHIVE_DIR"
((CONTROLS_PASSED++))

echo -e "  ${GREEN}PASS${NC}: $MLL005_EVIDENCE"

EVIDENCE+=("{\"control_id\": \"MLL-005\", \"status\": \"$MLL005_STATUS\", \"evidence\": \"$MLL005_EVIDENCE\", \"archive_path\": \"$ARCHIVE_DIR\"}")

# ============================================================
# AIM-008: Continuous Learning (Memory MCP)
# ============================================================
echo -e "${BLUE}[AIM-008]${NC} Checking Memory MCP integration..."

AIM008_STATUS="info"
AIM008_EVIDENCE=""

# Check if we should update Memory MCP
if [ "$PATTERN_COUNT" -gt 0 ]; then
    AIM008_STATUS="info"
    AIM008_EVIDENCE="$PATTERN_COUNT patterns ready for Memory MCP - run compound-review skill for full extraction"
else
    AIM008_STATUS="info"
    AIM008_EVIDENCE="No patterns to export to Memory MCP"
fi

echo -e "  INFO: $AIM008_EVIDENCE"

EVIDENCE+=("{\"control_id\": \"AIM-008\", \"status\": \"$AIM008_STATUS\", \"evidence\": \"$AIM008_EVIDENCE\"}")

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

cat > "$AUDIT_FILE" <<EOF
{
  "gate": "post",
  "name": "Compound Review",
  "feature": "$FEATURE_SLUG",
  "timestamp": "$TIMESTAMP",
  "controls_passed": $CONTROLS_PASSED,
  "controls_warned": $CONTROLS_WARNED,
  "patterns_captured": $PATTERN_COUNT,
  "iterations_completed": $ITERATION_COUNT,
  "failures_logged": $FAILURE_COUNT,
  "archive_location": "$ARCHIVE_DIR",
  "controls_executed": [$EVIDENCE_JSON],
  "overall_status": "pass"
}
EOF

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo -e "${CYAN}[Post-Gate] Compound Review Complete${NC}"
echo ""
echo "  Feature: $FEATURE_SLUG"
echo "  Iterations: $ITERATION_COUNT"
echo "  Patterns: $PATTERN_COUNT"
echo "  Failures: $FAILURE_COUNT"
echo "  Archive: $ARCHIVE_DIR"
echo ""
echo "  Controls Passed: $CONTROLS_PASSED"
echo "  Controls Warned: $CONTROLS_WARNED"
echo ""
echo -e "${GREEN}[Post-Gate] COMPLETE${NC}"
echo ""
echo "Next steps:"
echo "  1. Run /compound-review skill for full pattern extraction"
echo "  2. Update agents.md with stable patterns"
echo "  3. Create Memory MCP entities if significant learnings"

exit 0
