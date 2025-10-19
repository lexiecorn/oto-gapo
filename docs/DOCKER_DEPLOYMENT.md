# Docker Deployment Guide

Quick start guide for deploying Oto Gapo web app to Ubuntu server using Docker.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Server Setup](#server-setup)
- [Initial Deployment](#initial-deployment)
- [Managing the Application](#managing-the-application)
- [Using Portainer](#using-portainer)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

## Prerequisites

### Server Requirements

- Ubuntu 20.04 or later
- Docker installed
- Docker Compose installed
- Portainer installed (optional but recommended)
- Minimum 2GB RAM, 2 CPU cores
- 10GB free disk space

### Domain Setup

1. **DNS Configuration**: Point your domain to the server IP

   ```bash
   # Check DNS propagation
   nslookup otogapo.lexserver.org
   ```

2. **Firewall Rules**: Ensure ports 80 and 443 are open

   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw status
   ```

### Docker Installation

If Docker is not installed:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

## Server Setup

### 1. Clone Repository

```bash
# Navigate to your preferred directory
cd /opt

# Clone the repository
git clone <repository-url> otogapo
cd otogapo
```

### 2. Configure Environment

```bash
# Copy environment template
cp env.template .env

# Edit with your values
nano .env
```

Update the following variables:

```bash
DOMAIN=otogapo.lexserver.org
EMAIL=your-email@example.com  # For Let's Encrypt notifications
LETSENCRYPT_STAGING=0         # Use 0 for production, 1 for testing
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/deploy_docker.sh
chmod +x scripts/renew_ssl.sh
```

## Initial Deployment

### Deploy the Application

Run the deployment script:

```bash
./scripts/deploy_docker.sh
```

This script will:

1. Validate environment configuration
2. Build the Flutter web application
3. Create Docker image
4. Initialize SSL certificates (Let's Encrypt)
5. Start all services via Docker Compose

**Expected output:**

```
========================================
Oto Gapo Web App - Docker Deployment
========================================

Configuration:
  Domain: otogapo.lexserver.org
  Email:  your-email@example.com

Building Docker image...
✓ Docker image built successfully

Initializing SSL certificates...
✓ SSL certificate obtained successfully

Starting Docker Compose services...
✓ Services started successfully

✓ Application is healthy

========================================
Deployment Complete!
========================================

Your application is available at:
  https://otogapo.lexserver.org
```

### Verify Deployment

1. **Check service status:**

   ```bash
   docker-compose ps
   ```

2. **View logs:**

   ```bash
   docker-compose logs -f
   ```

3. **Test the application:**
   ```bash
   curl -I https://otogapo.lexserver.org
   ```

Visit `https://otogapo.lexserver.org` in your browser.

## Managing the Application

### Common Commands

```bash
# View service status
docker-compose ps

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f otogapo-web
docker-compose logs -f nginx-proxy

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Start services
docker-compose up -d

# Rebuild and restart
docker-compose up -d --build

# Remove everything (including volumes)
docker-compose down -v
```

### Updating the Application

When you have new code changes:

```bash
# Pull latest changes
git pull origin main

# Rebuild and redeploy
./scripts/deploy_docker.sh
```

Or manually:

```bash
# Build new image
docker build -t otogapo-web:latest .

# Restart services
docker-compose down
docker-compose up -d
```

### Environment-Specific Builds

To deploy different environments, modify the Dockerfile build command:

```bash
# Development
flutter build web --release --target lib/main_development.dart

# Staging
flutter build web --release --target lib/main_staging.dart

# Production (default)
flutter build web --release --target lib/main_production.dart
```

## Using Portainer

### Access Portainer

If Portainer is installed on your server, access it via:

```
https://lexserver.org:9443
```

Or your configured Portainer URL.

### Import Stack in Portainer

1. **Login to Portainer**
2. **Navigate to Stacks** → **Add Stack**
3. **Choose one method:**

   **Option A: Upload docker-compose.yml**

   - Upload the `docker-compose.yml` file
   - Set environment variables
   - Deploy

   **Option B: Repository**

   - Point to your Git repository
   - Specify path to `docker-compose.yml`
   - Set automatic updates if desired

### Manage via Portainer

- **View Containers**: Monitor status, resource usage
- **View Logs**: Real-time log streaming
- **Console Access**: Execute commands in containers
- **Restart/Stop**: Control container lifecycle
- **Resource Stats**: CPU, memory, network usage

### Portainer Webhooks

Set up webhooks for automatic deployments:

1. Create webhook in Portainer for your stack
2. Configure CI/CD to trigger webhook on push
3. Automatic deployment on code changes

## Troubleshooting

### SSL Certificate Issues

**Problem**: Certificate generation fails

```bash
# Check DNS resolution
nslookup otogapo.lexserver.org

# Check port 80 accessibility
curl -I http://otogapo.lexserver.org/.well-known/acme-challenge/test

# Test with Let's Encrypt staging
# Edit .env: LETSENCRYPT_STAGING=1
./scripts/deploy_docker.sh
```

**Problem**: Certificate expired

```bash
# Manual renewal
docker-compose run --rm certbot renew

# Reload nginx
docker-compose exec nginx-proxy nginx -s reload
```

### Application Not Loading

**Check container status:**

```bash
docker-compose ps
```

**Check container logs:**

```bash
docker-compose logs otogapo-web
docker-compose logs nginx-proxy
```

**Check nginx configuration:**

```bash
docker-compose exec nginx-proxy nginx -t
```

**Restart services:**

```bash
docker-compose restart
```

### Build Failures

**Problem**: Flutter build fails

```bash
# Check Flutter installation in container
docker-compose run --rm otogapo-web flutter --version

# Clear Flutter cache and rebuild
docker-compose build --no-cache
```

**Problem**: Out of disk space

```bash
# Clean up Docker resources
docker system prune -a

# Remove old images
docker image prune -a
```

### Port Conflicts

**Problem**: Port 80 or 443 already in use

```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting service (e.g., Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### Network Issues

**Check Docker network:**

```bash
docker network ls
docker network inspect otogapo_otogapo-network
```

**Check connectivity:**

```bash
# From host to container
docker-compose exec otogapo-web wget -O- http://localhost/health

# Between containers
docker-compose exec nginx-proxy wget -O- http://otogapo-web/health
```

## Maintenance

### SSL Certificate Auto-Renewal

Set up automatic certificate renewal:

```bash
# Edit crontab
crontab -e

# Add this line (runs at 3 AM daily)
0 3 * * * /opt/otogapo/scripts/renew_ssl.sh
```

Check renewal logs:

```bash
cat /opt/otogapo/certbot-renew.log
```

### Backup Strategy

**Backup important files:**

```bash
# Configuration
cp .env .env.backup

# SSL certificates
tar -czf certbot-backup-$(date +%Y%m%d).tar.gz certbot/

# Docker images
docker save otogapo-web:latest | gzip > otogapo-web-backup.tar.gz
```

**Restore from backup:**

```bash
# Restore certificates
tar -xzf certbot-backup-20241011.tar.gz

# Load Docker image
docker load < otogapo-web-backup.tar.gz
```

### Monitoring

**Resource usage:**

```bash
# Container stats
docker stats

# Disk usage
docker system df
df -h
```

**Application health:**

```bash
# Health check endpoint
curl http://localhost/health

# Check response time
time curl -I https://otogapo.lexserver.org
```

### Log Management

**View and manage logs:**

```bash
# View logs
docker-compose logs -f --tail=100

# Log rotation (add to crontab)
0 0 * * 0 docker-compose logs --no-color > /opt/otogapo/logs/app-$(date +\%Y\%m\%d).log 2>&1
```

### Updates and Upgrades

**Update Docker images:**

```bash
# Pull latest base images
docker-compose pull

# Rebuild with new base images
docker-compose build --pull

# Restart with new images
docker-compose up -d
```

**Update application:**

```bash
# Pull latest code
git pull origin main

# Redeploy
./scripts/deploy_docker.sh
```

## Security Best Practices

1. **Keep Docker Updated**

   ```bash
   sudo apt update
   sudo apt upgrade docker-ce docker-ce-cli containerd.io
   ```

2. **Secure .env File**

   ```bash
   chmod 600 .env
   ```

3. **Regular Security Scans**

   ```bash
   docker scan otogapo-web:latest
   ```

4. **Monitor Logs**

   - Check for suspicious activity
   - Set up log aggregation (e.g., ELK stack)

5. **Firewall Configuration**
   ```bash
   sudo ufw enable
   sudo ufw allow 22/tcp   # SSH
   sudo ufw allow 80/tcp   # HTTP
   sudo ufw allow 443/tcp  # HTTPS
   ```

## Performance Optimization

### Docker Performance

```bash
# Limit container resources in docker-compose.yml
services:
  otogapo-web:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
```

### Nginx Caching

Already configured in `nginx/app.conf`:

- Static assets cached for 1 year
- HTML not cached
- Gzip compression enabled

### Monitor Performance

```bash
# Container resource usage
docker stats

# Application metrics
curl https://otogapo.lexserver.org/health
```

## Support and Documentation

- **Project Documentation**: See `docs/` directory
- **Web Deployment Guide**: `docs/WEB_DEPLOYMENT.md`
- **Architecture**: `docs/ARCHITECTURE.md`
- **API Documentation**: `docs/API_DOCUMENTATION.md`

## Quick Reference

```bash
# Deploy/Update application
./scripts/deploy_docker.sh

# Renew SSL certificates
./scripts/renew_ssl.sh

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop application
docker-compose down

# Complete cleanup
docker-compose down -v
docker system prune -a
```

---

**For detailed web deployment options and CI/CD workflows, see `docs/WEB_DEPLOYMENT.md`.**
