#!/bin/bash

# Quick Backend Update Script for Oto Gapo Web App
# This script updates the deployed web app on the server

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}==================================="
echo -e "Updating Oto Gapo Web App"
echo -e "===================================${NC}\n"

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository!${NC}"
    exit 1
fi

# Pull latest code
echo -e "${BLUE}📥 Pulling latest code from repository...${NC}"
git pull origin main

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to pull latest code${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Code updated successfully${NC}\n"

# Build new Docker image
echo -e "${BLUE}🔨 Building Docker image (with --no-cache for fresh build)...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}\n"

docker build --no-cache -t otogapo-web:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker image built successfully${NC}\n"

# Restart containers
echo -e "${BLUE}🔄 Restarting containers...${NC}"

docker-compose down
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to restart containers${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Containers restarted successfully${NC}\n"

# Wait for services to be ready
echo -e "${BLUE}Waiting for services to be ready...${NC}"
sleep 5

# Health check
echo -e "\n${BLUE}Performing health check...${NC}"
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health || echo "000")

if [ "$HEALTH_CHECK" = "200" ]; then
    echo -e "${GREEN}✓ Application is healthy${NC}\n"
else
    echo -e "${YELLOW}⚠ Health check returned: $HEALTH_CHECK${NC}"
    echo -e "${YELLOW}Check logs with: docker-compose logs -f${NC}\n"
fi

# Show status
echo -e "${BLUE}Service Status:${NC}"
docker-compose ps

echo -e "\n${GREEN}==================================="
echo -e "✅ Update Complete!"
echo -e "===================================${NC}\n"

echo -e "${YELLOW}NOTE: If you're using Portainer, you can now go to:${NC}"
echo -e "  ${BLUE}Portainer → Stacks → otogapo → Editor → Update the stack${NC}"
echo -e "  ${BLUE}(Make sure 'Re-pull image' is OFF)${NC}\n"

echo -e "${BLUE}Useful commands:${NC}"
echo -e "  View logs:        ${BLUE}docker-compose logs -f${NC}"
echo -e "  Check status:     ${BLUE}docker-compose ps${NC}"
echo -e "  Restart:          ${BLUE}docker-compose restart${NC}"
echo -e "  Stop:             ${BLUE}docker-compose down${NC}\n"


