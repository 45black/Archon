#!/bin/bash
# ralph-setup.sh - Initialize Ralph for a new feature
#
# Usage: ./ralph-setup.sh <feature-slug> [project_id]
#
# This creates the local files needed for Ralph to run and
# guides you through creating tasks in Archon.

set -e

FEATURE_SLUG=${1:-""}
PROJECT_ID=${2:-""}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$FEATURE_SLUG" ]; then
    echo -e "${RED}Error: Feature slug required${NC}"
    echo ""
    echo "Usage: $0 <feature-slug> [project_id]"
    echo ""
    echo "Example: $0 expense-tracking proj-abc123"
    exit 1
fi

FEATURE="ralph-$FEATURE_SLUG"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
FEATURE_FILE="$SCRIPT_DIR/current-feature.txt"

echo -e "${BLUE}=== Ralph Setup: $FEATURE ===${NC}"

# Archive existing progress if present
if [ -f "$PROGRESS_FILE" ] && [ -s "$PROGRESS_FILE" ]; then
    PREV_FEATURE=$(cat "$FEATURE_FILE" 2>/dev/null || echo "unknown")
    if [ "$PREV_FEATURE" != "$FEATURE" ]; then
        echo -e "${YELLOW}Archiving previous feature: $PREV_FEATURE${NC}"
        ARCHIVE_DIR="$SCRIPT_DIR/archive/$(date +%Y-%m-%d)-$PREV_FEATURE"
        mkdir -p "$ARCHIVE_DIR"
        cp "$PROGRESS_FILE" "$ARCHIVE_DIR/"
        echo "Archived to: $ARCHIVE_DIR"
    fi
fi

# Create feature marker
echo "$FEATURE" > "$FEATURE_FILE"
echo -e "${GREEN}✓ Created: $FEATURE_FILE${NC}"

# Create progress file
cat > "$PROGRESS_FILE" << EOF
# Ralph Progress: $FEATURE_SLUG
Started: $(date)

## Codebase Patterns
[Add patterns discovered during implementation]

---

## Iterations
EOF
echo -e "${GREEN}✓ Created: $PROGRESS_FILE${NC}"

echo ""
echo -e "${BLUE}=== Next Steps ===${NC}"
echo ""
echo "1. Create parent task in Archon:"
echo ""
echo "   archon:manage_task"
echo "     action: 'create'"
echo "     project_id: '${PROJECT_ID:-YOUR_PROJECT_ID}'"
echo "     title: '[Feature Name]'"
echo "     description: 'Parent task for $FEATURE_SLUG'"
echo "     feature: '$FEATURE'"
echo "     assignee: 'Archon'"
echo ""
echo "2. Create subtasks with task_order:"
echo ""
echo "   Order 1-10:  Schema/setup tasks"
echo "   Order 11-30: Backend logic"
echo "   Order 31-50: UI components"
echo "   Order 51-70: Integration tests"
echo "   Order 71-90: Polish/docs"
echo ""
echo "3. Each task description must include:"
echo "   - **What to do:** bullet points"
echo "   - **Files:** paths to modify"
echo "   - **Acceptance criteria:** testable items"
echo ""
echo "4. Run Ralph:"
echo ""
echo "   ./ralph-archon.sh 15 ${PROJECT_ID:-YOUR_PROJECT_ID}"
echo ""
echo -e "${GREEN}Setup complete for: $FEATURE${NC}"
