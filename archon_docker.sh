#!/bin/bash
# Archon Docker Startup Script
# Created: 2026-01-11
# Purpose: Start Archon services after system restart

set -e

echo "======================================"
echo "   Archon Docker Startup Script"
echo "======================================"
echo ""

# Navigate to Archon directory
cd ~/Projects/infrastructure/archon

# Check if Docker Desktop is running
echo "📋 Step 1: Checking Docker Desktop..."
if ! pgrep -f "Docker Desktop" > /dev/null; then
    echo "⚠️  Docker Desktop is not running!"
    echo "   Opening Docker Desktop..."
    open -a "Docker Desktop"
    echo "   Waiting for Docker to start (this may take 30-60 seconds)..."
    sleep 10
else
    echo "✅ Docker Desktop is running"
fi

# Wait for Docker daemon to be ready
echo ""
echo "📋 Step 2: Waiting for Docker daemon to be ready..."
MAX_WAIT=60
COUNTER=0
while ! docker info > /dev/null 2>&1; do
    if [ $COUNTER -ge $MAX_WAIT ]; then
        echo "❌ Docker daemon did not start within ${MAX_WAIT} seconds"
        echo "   Please check Docker Desktop manually and try again"
        exit 1
    fi
    echo "   Waiting... ($COUNTER/${MAX_WAIT}s)"
    sleep 2
    COUNTER=$((COUNTER + 2))
done
echo "✅ Docker daemon is ready"

# Verify environment
echo ""
echo "📋 Step 3: Verifying environment..."
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "   Please create .env from .env.example"
    exit 1
fi
node check-env.js || exit 1

# Stop any existing Archon containers
echo ""
echo "📋 Step 4: Stopping any existing Archon containers..."
docker compose down --remove-orphans 2>/dev/null || true
echo "✅ Cleaned up existing containers"

# Start Archon services
echo ""
echo "📋 Step 5: Starting Archon services (full Docker mode)..."
echo "   This will build images if needed (may take 2-5 minutes first time)"
docker compose --profile full up -d --build

# Wait for services to be healthy
echo ""
echo "📋 Step 6: Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "📋 Step 7: Checking service status..."
docker compose ps

# Get running services
RUNNING_SERVICES=$(docker compose ps --filter "status=running" --format "{{.Service}}" 2>/dev/null | wc -l | tr -d ' ')

echo ""
if [ "$RUNNING_SERVICES" -ge 3 ]; then
    echo "======================================"
    echo "   ✅ Archon is running!"
    echo "======================================"
    echo ""
    echo "Services:"
    echo "  🌐 Frontend UI:  http://localhost:3737"
    echo "  🔧 API Server:   http://localhost:8181"
    echo "  🔌 MCP Server:   http://localhost:8051"
    echo ""
    echo "Quick commands:"
    echo "  View logs:       docker compose logs -f"
    echo "  Stop services:   docker compose down"
    echo "  Restart:         docker compose restart"
    echo ""
    echo "Database: Already migrated and ready ✅"
    echo ""
else
    echo "======================================"
    echo "   ⚠️  Some services failed to start"
    echo "======================================"
    echo ""
    echo "Running services: $RUNNING_SERVICES / 3"
    echo ""
    echo "Check logs with:"
    echo "  docker compose logs archon-server"
    echo "  docker compose logs archon-mcp"
    echo "  docker compose logs archon-ui"
    echo ""
fi

# Open browser to UI
read -p "Open Archon UI in browser? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open http://localhost:3737
fi

echo ""
echo "Script complete!"
