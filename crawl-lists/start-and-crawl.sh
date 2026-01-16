#!/bin/bash
# start-and-crawl.sh - Quick start Archon and open crawl UI
# Created: 2026-01-15

set -e

# Colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Archon Quick Start - Pensions Governance Crawl${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Docker is not running. Starting Docker Desktop...${NC}"
    open -a "Docker Desktop"
    echo "Waiting for Docker to start (this may take 30-60 seconds)..."

    # Wait for Docker to be ready
    while ! docker info > /dev/null 2>&1; do
        sleep 2
        echo -n "."
    done
    echo ""
    echo -e "${GREEN}Docker is ready!${NC}"
fi

# Navigate to Archon directory
cd ~/Projects/infrastructure/archon

# Start Archon
echo ""
echo -e "${BLUE}Starting Archon services...${NC}"
docker compose up --build -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Check if UI is responding
if curl -s --connect-timeout 5 http://localhost:3737 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Archon UI is ready${NC}"
else
    echo -e "${YELLOW}⏳ Services still starting, please wait...${NC}"
    sleep 10
fi

# Open the UI
echo ""
echo -e "${GREEN}Opening Archon UI...${NC}"
open http://localhost:3737

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Recommended Crawl Order${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "1. https://finregont.com/"
echo "   → Financial Regulation Ontology (FIBO + LKIF template)"
echo ""
echo "2. https://law.stanford.edu/codex-the-stanford-center-for-legal-informatics/"
echo "   → Stanford CodeX computational law frameworks"
echo ""
echo "3. https://computationallaw.org/"
echo "   → AI Agents x Law workshop resources"
echo ""
echo "4. https://www.thepensionsregulator.gov.uk/en/document-library/corporate-information/ddat-strategy"
echo "   → TPR Digital Strategy (UK regulatory context)"
echo ""
echo -e "${GREEN}Go to Knowledge Base → Crawl Website to add these sources${NC}"
echo ""
