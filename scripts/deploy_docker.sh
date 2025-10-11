#!/bin/bash

# Docker Deployment Script for Oto Gapo Web App
# This script builds and deploys the Flutter web app using Docker

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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Oto Gapo Web App - Docker Deployment${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if .env file exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${YELLOW}Warning: .env file not found!${NC}"
    echo -e "${YELLOW}Creating from env.template...${NC}\n"
    
    if [ -f "$PROJECT_ROOT/env.template" ]; then
        cp "$PROJECT_ROOT/env.template" "$PROJECT_ROOT/.env"
        echo -e "${RED}Please edit .env file with your actual values before continuing!${NC}"
        echo -e "${RED}Update DOMAIN and EMAIL variables.${NC}"
        exit 1
    else
        echo -e "${RED}Error: env.template not found!${NC}"
        echo -e "${RED}Please create .env file manually with:${NC}"
        echo -e "${RED}  DOMAIN=otogapo.lexserver.org${NC}"
        echo -e "${RED}  EMAIL=your-email@example.com${NC}"
        exit 1
    fi
fi

# Load environment variables
source "$PROJECT_ROOT/.env"

# Validate required variables
if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "otogapo.lexserver.org" ]; then
    echo -e "${YELLOW}Warning: Using default domain. Make sure this is correct.${NC}"
fi

if [ -z "$EMAIL" ] || [ "$EMAIL" = "your-email@example.com" ]; then
    echo -e "${RED}Error: Please set a valid EMAIL in .env file!${NC}"
    exit 1
fi

echo -e "${GREEN}Configuration:${NC}"
echo -e "  Domain: ${BLUE}$DOMAIN${NC}"
echo -e "  Email:  ${BLUE}$EMAIL${NC}\n"

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if this is first run (no certificates)
FIRST_RUN=false
if [ ! -d "$PROJECT_ROOT/certbot/conf/live/$DOMAIN" ]; then
    FIRST_RUN=true
    echo -e "${YELLOW}First run detected - will initialize SSL certificates${NC}\n"
fi

# Create necessary directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p certbot/conf
mkdir -p certbot/www
mkdir -p nginx

# Build Docker image
echo -e "\n${BLUE}Building Docker image...${NC}"
docker build -t otogapo-web:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully${NC}\n"
else
    echo -e "${RED}✗ Docker build failed${NC}"
    exit 1
fi

# First run: Initialize SSL certificates
if [ "$FIRST_RUN" = true ]; then
    echo -e "${BLUE}Initializing SSL certificates...${NC}\n"
    
    # Start nginx in HTTP-only mode for ACME challenge
    echo -e "${YELLOW}Starting temporary nginx for ACME challenge...${NC}"
    
    # Create temporary nginx config for HTTP only
    cat > "$PROJECT_ROOT/nginx/proxy-temp.conf" << 'EOF'
server {
    listen 80;
    server_name otogapo.lexserver.org;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 200 "Initializing SSL...";
        add_header Content-Type text/plain;
    }
}
EOF
    
    # Start temporary nginx
    docker run -d --name otogapo-nginx-temp \
        -p 80:80 \
        -v "$PROJECT_ROOT/nginx/proxy-temp.conf:/etc/nginx/conf.d/default.conf:ro" \
        -v "$PROJECT_ROOT/certbot/www:/var/www/certbot:ro" \
        nginx:alpine
    
    sleep 5
    
    # Request certificate
    echo -e "${YELLOW}Requesting Let's Encrypt certificate...${NC}"
    
    STAGING_ARG=""
    if [ "${LETSENCRYPT_STAGING:-0}" = "1" ]; then
        echo -e "${YELLOW}Using Let's Encrypt staging server (for testing)${NC}"
        STAGING_ARG="--staging"
    fi
    
    docker run --rm \
        -v "$PROJECT_ROOT/certbot/conf:/etc/letsencrypt" \
        -v "$PROJECT_ROOT/certbot/www:/var/www/certbot" \
        certbot/certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        $STAGING_ARG \
        -d "$DOMAIN"
    
    CERT_RESULT=$?
    
    # Stop temporary nginx
    docker stop otogapo-nginx-temp
    docker rm otogapo-nginx-temp
    rm "$PROJECT_ROOT/nginx/proxy-temp.conf"
    
    if [ $CERT_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ SSL certificate obtained successfully${NC}\n"
    else
        echo -e "${RED}✗ Failed to obtain SSL certificate${NC}"
        echo -e "${YELLOW}Please check:${NC}"
        echo -e "  1. DNS is correctly pointing $DOMAIN to this server"
        echo -e "  2. Port 80 is accessible from the internet"
        echo -e "  3. No firewall blocking the connection"
        exit 1
    fi
fi

# Start services with docker-compose
echo -e "${BLUE}Starting Docker Compose services...${NC}\n"
docker-compose down 2>/dev/null || true
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Services started successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to start services${NC}"
    exit 1
fi

# Wait for services to be healthy
echo -e "${BLUE}Waiting for services to be ready...${NC}"
sleep 10

# Health check
echo -e "\n${BLUE}Performing health check...${NC}"
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health || echo "000")

if [ "$HEALTH_CHECK" = "200" ]; then
    echo -e "${GREEN}✓ Application is healthy${NC}\n"
else
    echo -e "${YELLOW}⚠ Health check returned: $HEALTH_CHECK${NC}"
    echo -e "${YELLOW}Services may still be starting up...${NC}\n"
fi

# Show status
echo -e "${BLUE}Service Status:${NC}"
docker-compose ps

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"
echo -e "${GREEN}Your application is available at:${NC}"
echo -e "  ${BLUE}https://$DOMAIN${NC}\n"

if [ "$FIRST_RUN" = true ]; then
    echo -e "${YELLOW}Important:${NC}"
    echo -e "  - Add SSL renewal cron job: ${BLUE}./scripts/renew_ssl.sh${NC}"
    echo -e "  - Run: ${BLUE}crontab -e${NC}"
    echo -e "  - Add: ${BLUE}0 3 * * * $PROJECT_ROOT/scripts/renew_ssl.sh${NC}\n"
fi

echo -e "${BLUE}Useful commands:${NC}"
echo -e "  View logs:        ${BLUE}docker-compose logs -f${NC}"
echo -e "  Restart services: ${BLUE}docker-compose restart${NC}"
echo -e "  Stop services:    ${BLUE}docker-compose down${NC}"
echo -e "  Rebuild:          ${BLUE}docker-compose up -d --build${NC}\n"

