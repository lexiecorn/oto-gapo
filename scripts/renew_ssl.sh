#!/bin/bash

# SSL Certificate Renewal Script for Oto Gapo Web App
# This script should be run via cron to automatically renew Let's Encrypt certificates

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Log file
LOG_FILE="$PROJECT_ROOT/certbot-renew.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting SSL certificate renewal check..."

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if docker-compose is running
if ! docker-compose ps | grep -q "Up"; then
    log "ERROR: Docker Compose services are not running!"
    exit 1
fi

# Attempt certificate renewal
log "Running certbot renew..."
docker-compose run --rm certbot renew >> "$LOG_FILE" 2>&1

RENEW_RESULT=$?

if [ $RENEW_RESULT -eq 0 ]; then
    log "Certificate renewal check completed successfully"
    
    # Reload nginx to pick up new certificates
    log "Reloading nginx configuration..."
    docker-compose exec nginx-proxy nginx -s reload >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        log "Nginx reloaded successfully"
    else
        log "WARNING: Failed to reload nginx"
    fi
else
    log "WARNING: Certificate renewal returned non-zero exit code: $RENEW_RESULT"
fi

# Clean up old logs (keep last 30 days)
find "$PROJECT_ROOT" -name "certbot-renew.log" -type f -mtime +30 -delete

log "SSL renewal check completed"
log "---"

