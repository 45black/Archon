#!/bin/bash
# Generate ISO Compliance Report
# Creates a markdown report summarizing all gate results for a feature.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$RALPH_DIR/feature-config.txt"
AUDIT_DIR="$RALPH_DIR/audit"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get feature slug
FEATURE_SLUG="${1:-unknown}"
if [ "$FEATURE_SLUG" = "unknown" ] && [ -f "$CONFIG_FILE" ]; then
    FEATURE_SLUG=$(grep "feature_slug=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "unknown")
fi
if [ "$FEATURE_SLUG" = "unknown" ] && [ -f "$RALPH_DIR/current-feature.txt" ]; then
    FEATURE_SLUG=$(cat "$RALPH_DIR/current-feature.txt")
fi

REPORT_FILE="$AUDIT_DIR/COMPLIANCE-REPORT-$FEATURE_SLUG.md"

echo -e "${BLUE}[Report Generator] Creating compliance report for: $FEATURE_SLUG${NC}"
echo ""

# Start report
cat > "$REPORT_FILE" <<EOF
# ISO Compliance Report

**Feature:** $FEATURE_SLUG
**Generated:** $TIMESTAMP
**Standards:** ISO 9001:2015, ISO/IEC 42001:2023, ISO/IEC 25010:2023

---

## Executive Summary

This report documents the ISO control compliance for the Ralph autonomous development session.

EOF

# ============================================================
# Gate Summary Table
# ============================================================
echo "## Gate Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Gate | Name | Status | Passed | Warned | Failed |" >> "$REPORT_FILE"
echo "|------|------|--------|--------|--------|--------|" >> "$REPORT_FILE"

TOTAL_PASSED=0
TOTAL_WARNED=0
TOTAL_FAILED=0

# Process each gate file
for gate_num in 1 2; do
    gate_file="$AUDIT_DIR/gate-$gate_num-*.json"
    for f in $gate_file; do
        if [ -f "$f" ]; then
            GATE_NAME=$(python3 -c "import json; print(json.load(open('$f'))['name'])" 2>/dev/null || echo "Gate $gate_num")
            GATE_STATUS=$(python3 -c "import json; print(json.load(open('$f'))['overall_status'])" 2>/dev/null || echo "unknown")
            GATE_PASSED=$(python3 -c "import json; print(json.load(open('$f')).get('controls_passed', 0))" 2>/dev/null || echo "0")
            GATE_WARNED=$(python3 -c "import json; print(json.load(open('$f')).get('controls_warned', 0))" 2>/dev/null || echo "0")
            GATE_FAILED=$(python3 -c "import json; print(json.load(open('$f')).get('controls_failed', 0))" 2>/dev/null || echo "0")

            STATUS_EMOJI=""
            case "$GATE_STATUS" in
                pass) STATUS_EMOJI="PASS" ;;
                warn) STATUS_EMOJI="WARN" ;;
                fail) STATUS_EMOJI="FAIL" ;;
                *) STATUS_EMOJI="?" ;;
            esac

            echo "| $gate_num | $GATE_NAME | $STATUS_EMOJI | $GATE_PASSED | $GATE_WARNED | $GATE_FAILED |" >> "$REPORT_FILE"

            TOTAL_PASSED=$((TOTAL_PASSED + GATE_PASSED))
            TOTAL_WARNED=$((TOTAL_WARNED + GATE_WARNED))
            TOTAL_FAILED=$((TOTAL_FAILED + GATE_FAILED))
        fi
    done
done

# Gate 3 (per-task)
GATE3_COUNT=$(ls -1 "$AUDIT_DIR/gate-3/" 2>/dev/null | wc -l || echo "0")
GATE3_COUNT=$(echo "$GATE3_COUNT" | tr -d ' ')
if [ "$GATE3_COUNT" -gt 0 ]; then
    GATE3_PASSED=0
    GATE3_FAILED=0
    for f in "$AUDIT_DIR/gate-3/"*.json; do
        if [ -f "$f" ]; then
            STATUS=$(python3 -c "import json; print(json.load(open('$f'))['overall_status'])" 2>/dev/null || echo "unknown")
            if [ "$STATUS" = "pass" ] || [ "$STATUS" = "warn" ]; then
                GATE3_PASSED=$((GATE3_PASSED + 1))
            else
                GATE3_FAILED=$((GATE3_FAILED + 1))
            fi
        fi
    done
    echo "| 3 | Pre-Commit | $GATE3_PASSED/$GATE3_COUNT | $GATE3_PASSED | - | $GATE3_FAILED |" >> "$REPORT_FILE"
fi

# Gate 4 (per-task)
GATE4_COUNT=$(ls -1 "$AUDIT_DIR/gate-4/" 2>/dev/null | wc -l || echo "0")
GATE4_COUNT=$(echo "$GATE4_COUNT" | tr -d ' ')
if [ "$GATE4_COUNT" -gt 0 ]; then
    GATE4_PASSED=0
    GATE4_FAILED=0
    for f in "$AUDIT_DIR/gate-4/"*.json; do
        if [ -f "$f" ]; then
            STATUS=$(python3 -c "import json; print(json.load(open('$f'))['overall_status'])" 2>/dev/null || echo "unknown")
            if [ "$STATUS" = "pass" ] || [ "$STATUS" = "warn" ]; then
                GATE4_PASSED=$((GATE4_PASSED + 1))
            else
                GATE4_FAILED=$((GATE4_FAILED + 1))
            fi
        fi
    done
    echo "| 4 | Acceptance | $GATE4_PASSED/$GATE4_COUNT | $GATE4_PASSED | - | $GATE4_FAILED |" >> "$REPORT_FILE"
fi

# Compound gate
if [ -f "$AUDIT_DIR/compound.json" ]; then
    COMPOUND_STATUS=$(python3 -c "import json; print(json.load(open('$AUDIT_DIR/compound.json'))['overall_status'])" 2>/dev/null || echo "unknown")
    echo "| Post | Compound | $COMPOUND_STATUS | - | - | - |" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# ============================================================
# Controls Detail
# ============================================================
echo "## Controls Executed" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Gate 1 & 2 details
for gate_file in "$AUDIT_DIR/gate-1-"*.json "$AUDIT_DIR/gate-2-"*.json; do
    if [ -f "$gate_file" ]; then
        GATE_NAME=$(python3 -c "import json; print(json.load(open('$gate_file'))['name'])" 2>/dev/null || echo "Unknown")
        echo "### Gate: $GATE_NAME" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        # Extract controls
        python3 -c "
import json
data = json.load(open('$gate_file'))
for ctrl in data.get('controls_executed', []):
    status_icon = {'pass': 'PASS', 'fail': 'FAIL', 'warn': 'WARN', 'info': 'INFO', 'skip': 'SKIP'}.get(ctrl['status'], '?')
    print(f\"- **{ctrl['control_id']}** [{status_icon}]: {ctrl['evidence']}\")
" 2>/dev/null >> "$REPORT_FILE" || echo "- Unable to parse controls" >> "$REPORT_FILE"

        echo "" >> "$REPORT_FILE"
    fi
done

# ============================================================
# QMS-008 Analysis
# ============================================================
echo "## QMS-008: Anti-Rubber-Stamp Analysis" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -f "$AUDIT_DIR/gate-2-plan.json" ]; then
    RUBBER_STAMPS=$(python3 -c "import json; print(json.load(open('$AUDIT_DIR/gate-2-plan.json')).get('qms008_rubber_stamps', 'N/A'))" 2>/dev/null || echo "N/A")
    VERIFICATIONS=$(python3 -c "import json; print(json.load(open('$AUDIT_DIR/gate-2-plan.json')).get('qms008_verifications', 'N/A'))" 2>/dev/null || echo "N/A")

    echo "| Metric | Count |" >> "$REPORT_FILE"
    echo "|--------|-------|" >> "$REPORT_FILE"
    echo "| Rubber-stamp patterns detected | $RUBBER_STAMPS |" >> "$REPORT_FILE"
    echo "| Verification patterns found | $VERIFICATIONS |" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    if [ "$RUBBER_STAMPS" != "N/A" ] && [ "$RUBBER_STAMPS" != "0" ]; then
        echo "> **Warning:** Rubber-stamp patterns were detected. These are acceptance criteria that check for existence rather than correctness." >> "$REPORT_FILE"
        echo ">" >> "$REPORT_FILE"
        echo "> **Example BAD:** \"API endpoint exists\"" >> "$REPORT_FILE"
        echo "> **Example GOOD:** \"API call returns HTTP 200 with expected data\"" >> "$REPORT_FILE"
    else
        echo "> **Good:** No rubber-stamp patterns detected. All acceptance criteria execute actual verification." >> "$REPORT_FILE"
    fi
else
    echo "QMS-008 data not available." >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# ============================================================
# Task Summary
# ============================================================
echo "## Task Execution Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "| Task ID | Gate 3 | Gate 4 | Status |" >> "$REPORT_FILE"
echo "|---------|--------|--------|--------|" >> "$REPORT_FILE"

# Use python3 to merge task results (avoids bash 3.2 associative array limitation)
export AUDIT_DIR
python3 <<'PYEOF' >> "$REPORT_FILE" 2>/dev/null || echo "| (error parsing tasks) | - | - | - |" >> "$REPORT_FILE"
import json
import os
import glob

audit_dir = os.environ.get('AUDIT_DIR', 'audit')
tasks = {}

# Collect gate 3 results
for f in glob.glob(f"{audit_dir}/gate-3/*.json"):
    try:
        data = json.load(open(f))
        task_id = data.get('task_id', 'unknown')
        if task_id not in tasks:
            tasks[task_id] = {'gate3': 'N/A', 'gate4': 'N/A'}
        tasks[task_id]['gate3'] = data.get('overall_status', 'N/A')
    except:
        pass

# Collect gate 4 results
for f in glob.glob(f"{audit_dir}/gate-4/*.json"):
    try:
        data = json.load(open(f))
        task_id = data.get('task_id', 'unknown')
        if task_id not in tasks:
            tasks[task_id] = {'gate3': 'N/A', 'gate4': 'N/A'}
        tasks[task_id]['gate4'] = data.get('overall_status', 'N/A')
    except:
        pass

# Output results
if not tasks:
    print("| (no tasks) | - | - | - |")
else:
    for task_id, status in tasks.items():
        g3 = status['gate3']
        g4 = status['gate4']
        final = 'COMPLETE'
        if g3 == 'fail' or g4 == 'fail':
            final = 'FAILED'
        elif g3 == 'warn' or g4 == 'warn':
            final = 'WARN'
        print(f"| {task_id} | {g3} | {g4} | {final} |")
PYEOF

echo "" >> "$REPORT_FILE"

# ============================================================
# Audit Trail
# ============================================================
echo "## Audit Trail" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "All evidence files are stored in: \`scripts/ralph/audit/\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### Files" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
ls -la "$AUDIT_DIR/" 2>/dev/null >> "$REPORT_FILE" || echo "(no files)" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# ============================================================
# Certification Statement
# ============================================================
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Certification" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "This feature was developed using the Ralph autonomous development loop with ISO-aligned quality gates." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**ISO Standards Applied:**" >> "$REPORT_FILE"
echo "- ISO 9001:2015 (Quality Management System)" >> "$REPORT_FILE"
echo "- ISO/IEC 42001:2023 (AI Management System)" >> "$REPORT_FILE"
echo "- ISO/IEC 25010:2023 (Software Quality)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Report Generated:** $TIMESTAMP" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "*This report was automatically generated by the Ralph Gate System.*" >> "$REPORT_FILE"

# ============================================================
# Done
# ============================================================
echo ""
echo -e "${GREEN}[Report Generator] Report created: $REPORT_FILE${NC}"
echo ""

exit 0
