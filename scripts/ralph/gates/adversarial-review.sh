#!/bin/bash
# Adversarial Review: External critique for regulated domains
# ISO Control: AIM-003
#
# This script triggers adversarial review for tasks in regulated domains
# (Pensions, Legal, Security). It uses Claude in "critic mode" to challenge
# the implementation.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RALPH_DIR="$(dirname "$SCRIPT_DIR")"
TASK_ID="${1:-unknown}"
DOMAIN="${2:-standard}"
OUTPUT_DIR="$RALPH_DIR/adversarial"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
OUTPUT_FILE="$OUTPUT_DIR/review-task-$TASK_ID.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[Adversarial Review] Task: $TASK_ID | Domain: $DOMAIN${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# ============================================================
# Check if adversarial review is required
# ============================================================
CONFIG_FILE="$RALPH_DIR/feature-config.txt"
ADV_SETTING="${RALPH_ADVERSARIAL_REVIEW:-optional}"

if [ -f "$CONFIG_FILE" ]; then
    ADV_SETTING=$(grep "adversarial_review=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "optional")
    DOMAIN=$(grep "domain=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 || echo "$DOMAIN")
fi

echo "Adversarial setting: $ADV_SETTING"
echo "Domain: $DOMAIN"

# Skip if optional and not forced
if [ "$ADV_SETTING" = "optional" ] && [ "$RALPH_FORCE_ADVERSARIAL" != "true" ]; then
    echo ""
    echo -e "${GREEN}[Adversarial Review] SKIPPED${NC}"
    echo "Reason: Optional for standard domain (set RALPH_FORCE_ADVERSARIAL=true to force)"
    exit 0
fi

# ============================================================
# Gather code diff for review
# ============================================================
echo ""
echo "Gathering code changes..."

CODE_DIFF=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get staged changes or last commit diff
    CODE_DIFF=$(git diff --cached 2>/dev/null || git diff HEAD~1 2>/dev/null || echo "No diff available")

    if [ -z "$CODE_DIFF" ] || [ "$CODE_DIFF" = "No diff available" ]; then
        # Try to get recent changes
        CODE_DIFF=$(git diff HEAD~1 2>/dev/null || echo "No changes detected")
    fi

    LINES_CHANGED=$(echo "$CODE_DIFF" | wc -l)
    echo "Lines of diff: $LINES_CHANGED"
else
    CODE_DIFF="Not in git repository - manual review required"
fi

# ============================================================
# Build adversarial review prompt
# ============================================================
DOMAIN_SPECIFIC=""
case "$DOMAIN" in
    Pensions|pensions)
        DOMAIN_SPECIFIC="
### Pensions-Specific Checks
- Are regulatory references (LGPS, TPR, Scheme Rules) correct and current?
- Is actuarial or benefit calculation logic accurate?
- Are data protection requirements (GDPR) for member data met?
- Would TPR guidance require different handling?
- Are pension scheme administrative requirements satisfied?"
        ;;
    Legal|legal)
        DOMAIN_SPECIFIC="
### Legal-Specific Checks
- Are legislative citations accurate and current?
- Is contract/obligation logic correctly implemented?
- Are compliance requirements properly enforced?
- Could edge cases create legal liability?
- Are audit trail requirements met?"
        ;;
    Security|security)
        DOMAIN_SPECIFIC="
### Security-Specific Checks
- Are there any OWASP Top 10 vulnerabilities?
- Is authentication/authorization properly implemented?
- Are secrets properly handled (no hardcoding)?
- Is input validation sufficient?
- Could this be exploited for privilege escalation?"
        ;;
    Financial|financial)
        DOMAIN_SPECIFIC="
### Financial-Specific Checks
- Are calculations accurate (rounding, precision)?
- Is audit trail sufficient for financial compliance?
- Are transactions atomic and reversible where needed?
- Are reconciliation requirements met?"
        ;;
    *)
        DOMAIN_SPECIFIC=""
        ;;
esac

REVIEW_PROMPT="# Adversarial Code Review

**Task ID:** $TASK_ID
**Domain:** $DOMAIN
**Timestamp:** $TIMESTAMP

## Role

You are an adversarial code reviewer. Your job is to find issues that the original developer may have missed. Be thorough and critical - this code affects a regulated domain ($DOMAIN).

## Code Changes to Review

\`\`\`diff
$CODE_DIFF
\`\`\`

## Review Criteria

### 1. Logic Errors
- Are there any bugs, off-by-one errors, or incorrect assumptions?
- Are edge cases handled correctly?
- Is error handling sufficient?

### 2. Security Issues
- Any potential vulnerabilities (injection, XSS, auth bypass)?
- Are secrets or credentials exposed?
- Is input validation present?

### 3. Domain Correctness
$DOMAIN_SPECIFIC

### 4. QMS-008 Compliance
- Do the acceptance criteria actually EXECUTE tests?
- Or do they just check that \"something exists\"?
- Example BAD: \"API endpoint exists\"
- Example GOOD: \"API call returns HTTP 200 with expected data\"

### 5. Edge Cases
- What inputs or scenarios might break this code?
- Are boundary conditions tested?
- What happens with null/empty/malformed input?

## Output Format

Provide your critique as follows:

---

### Critical Issues (MUST FIX before merge)
[List any issues that absolutely must be addressed]

### Recommendations (SHOULD consider)
[List suggestions that would improve the code]

### Questions (NEED clarification)
[List anything unclear that needs human input]

### Approval Status
- [ ] **APPROVE**: No critical issues found
- [ ] **REQUEST CHANGES**: Critical issues must be addressed
- [ ] **NEEDS DISCUSSION**: Requires human clarification

---"

# ============================================================
# Execute adversarial review
# ============================================================
echo ""
echo "Executing adversarial review..."

# Check if Claude CLI is available
if command -v claude &> /dev/null; then
    echo "Using Claude CLI for adversarial review..."

    # Save prompt to temp file
    PROMPT_FILE="/tmp/adversarial-prompt-$TASK_ID.txt"
    echo "$REVIEW_PROMPT" > "$PROMPT_FILE"

    # Run Claude in print mode (non-interactive)
    REVIEW_OUTPUT=$(claude --print "You are an adversarial code reviewer. Be critical and thorough. Review this code:

$REVIEW_PROMPT" 2>&1) || true

    # Save output
    cat > "$OUTPUT_FILE" <<EOF
# Adversarial Review: Task $TASK_ID

**Domain:** $DOMAIN
**Generated:** $TIMESTAMP
**Reviewer:** Claude (Adversarial Mode)

---

$REVIEW_OUTPUT

---

## Audit Information

- Task ID: $TASK_ID
- Domain: $DOMAIN
- Adversarial Setting: $ADV_SETTING
- Lines Changed: $(echo "$CODE_DIFF" | wc -l)
EOF

    echo "Review saved to: $OUTPUT_FILE"

    # Check result
    if echo "$REVIEW_OUTPUT" | grep -q "APPROVE"; then
        echo ""
        echo -e "${GREEN}[Adversarial Review] APPROVED${NC}"
        exit 0
    elif echo "$REVIEW_OUTPUT" | grep -q "REQUEST CHANGES"; then
        echo ""
        echo -e "${RED}[Adversarial Review] CHANGES REQUESTED${NC}"
        echo "Review critical issues in: $OUTPUT_FILE"
        exit 1
    else
        echo ""
        echo -e "${YELLOW}[Adversarial Review] NEEDS DISCUSSION${NC}"
        echo "Review output in: $OUTPUT_FILE"
        exit 0  # Don't block, but flag
    fi
else
    # Claude CLI not available - create prompt file for manual review
    echo -e "${YELLOW}Claude CLI not available - creating prompt for manual review${NC}"

    cat > "$OUTPUT_FILE" <<EOF
# Manual Adversarial Review Required

**Task ID:** $TASK_ID
**Domain:** $DOMAIN
**Generated:** $TIMESTAMP

---

## Instructions

Claude CLI is not available. Please manually review the code changes below using the criteria provided.

$REVIEW_PROMPT

---

## Status

- [ ] **APPROVE**: After manual review
- [ ] **REQUEST CHANGES**: Critical issues found
- [ ] **NEEDS DISCUSSION**: Unclear requirements
EOF

    echo ""
    echo -e "${YELLOW}[Adversarial Review] MANUAL REVIEW REQUIRED${NC}"
    echo "Review prompt saved to: $OUTPUT_FILE"
    echo "Please review manually and update the status checkboxes"
    exit 0  # Don't block - let human decide
fi
