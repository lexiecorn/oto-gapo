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

### Updating Your Locally Built Docker App (Portainer Workflow)

This workflow is designed for updating the application when you build the Docker image locally on your server and manage containers via Portainer. This is the recommended approach when you have direct server access and want full control over the build process.

#### Prerequisites

- SSH access to your server
- Docker installed on the server
- Application code cloned to server (typically at `/opt/otogapo`)
- Portainer installed and accessible via web interface
- Existing stack deployed in Portainer named `otogapo`

#### Step 1: Get the Latest Code

**Location:** On your server (via SSH)

1. Navigate to your project directory:

   ```bash
   cd /opt/otogapo
   ```

2. Pull the latest changes from your Git repository (usually the main branch):

   ```bash
   git pull origin main
   ```

   This ensures your server has the newest code before building.

#### Step 2: Rebuild the Docker Image

**Location:** On your server (via SSH)

1. Make sure you are still in the `/opt/otogapo` directory.

2. Run the docker build command to create a new image tagged as `latest` using the updated code:

   ```bash
   docker build -t otogapo-web:latest .
   ```

3. Wait for the build process to complete successfully. You should see output indicating:
   - Flutter dependencies being installed
   - Web app being built
   - Nginx configuration being applied
   - Image being tagged successfully

**Note:** This builds the image locally on your server. The image is not pushed to a registry, so it's only available on this server.

#### Step 3: Redeploy Using Portainer

**Location:** Portainer Web Interface

1. Log in to Portainer at your configured URL (e.g., `https://lexserver.org:9443`).

2. Go to the **Stacks** menu from the left sidebar.

3. Click on your **otogapo** stack from the list.

4. Click the **Editor** tab at the top.

5. **You do not need to change any text in the editor.** The existing `docker-compose.yml` configuration is fine.

6. Scroll down and click the **Update the stack** button.

7. **CRITICAL STEP:** In the confirmation pop-up window, locate the **"Re-pull image"** toggle switch.

   - **Ensure this toggle is turned OFF** (disabled).
   - This tells Portainer to use the image you just built locally (`otogapo-web:latest`).
   - If this toggle is ON, Portainer will try to pull the image from a Docker registry, which will fail since your image is local-only.

8. Click the **Update** button to confirm.

9. Portainer will now:
   - Stop the old container(s)
   - Remove the old container(s)
   - Start new container(s) using the fresh `otogapo-web:latest` image
   - Deploy the latest version of your application

#### Step 4: Verify the Deployment

**Location:** Web browser or server

1. **Check Portainer Container Status:**

   - In Portainer, go to **Containers**
   - Verify the `otogapo-web` container shows as "running" with a green status
   - Check the creation time to confirm it's a newly created container

2. **Check Application Logs:**

   - Click on the `otogapo-web` container
   - Click **Logs** to view recent output
   - Look for any errors or warnings

3. **Test the Application:**

   - Open your application URL in a browser (e.g., `https://otogapo.lexserver.org`)
   - Verify the application loads correctly
   - Test key features to ensure everything works
   - Check that your recent changes are visible

4. **Server-Side Verification (Optional):**

   ```bash
   # Check running containers
   docker ps

   # View container logs
   docker logs otogapo-web

   # Check image was built recently
   docker images | grep otogapo-web
   ```

#### Quick Reference Command Summary

```bash
# Full update workflow (command-line version)
cd /opt/otogapo
git pull origin main
docker build -t otogapo-web:latest .

# Then update via Portainer UI with "Re-pull image" OFF
```

#### Troubleshooting

**Issue:** Portainer shows "Image not found" error

**Solution:** Make sure you built the image with the exact tag name used in your `docker-compose.yml`:

```bash
docker build -t otogapo-web:latest .
```

**Issue:** Changes not visible after deployment

**Solution:**

1. Clear your browser cache
2. Verify the container was actually recreated (check creation time in Portainer)
3. Check if you pulled the correct branch: `git branch` and `git log -1`

**Issue:** Application fails to start after update

**Solution:**

1. Check container logs in Portainer for error messages
2. Verify the build completed successfully without errors
3. Check if environment variables are still correct in the stack configuration
4. Roll back by deploying the previous image if needed

**Issue:** "Re-pull image" toggle not visible

**Solution:**

- Ensure you're on the **Editor** tab when clicking "Update the stack"
- The toggle appears in the confirmation dialog, not in the main editor
- Update Portainer if you're using a very old version

#### Benefits of This Workflow

- **Full Control:** Build exactly what's on your server, no surprise registry pulls
- **Faster Deployment:** No need to push/pull from Docker registries
- **No Registry Required:** Works without Docker Hub or other registry services
- **Easy Testing:** Test builds locally before deploying
- **Cost Effective:** No bandwidth costs for image transfers
- **Transparent:** You see exactly what's being built

#### Alternative: One-Command Update Script

For even faster updates, you can create a script that combines steps 1 and 2:

```bash
# Create the script
cat > /opt/otogapo/update_local.sh << 'EOF'
#!/bin/bash
set -e

echo "========================================="
echo "Updating Oto Gapo Local Build"
echo "========================================="

cd /opt/otogapo

echo "📥 Pulling latest code..."
git pull origin main

echo "🔨 Building Docker image..."
docker build -t otogapo-web:latest .

echo "✅ Build complete!"
echo ""
echo "Next steps:"
echo "1. Open Portainer web interface"
echo "2. Go to Stacks → otogapo → Editor"
echo "3. Click 'Update the stack'"
echo "4. Ensure 'Re-pull image' is OFF"
echo "5. Click 'Update'"
echo ""
EOF

chmod +x /opt/otogapo/update_local.sh
```

Then run it whenever you need to update:

```bash
/opt/otogapo/update_local.sh
```

This script automates steps 1 and 2, then reminds you to complete step 3 in Portainer.

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
