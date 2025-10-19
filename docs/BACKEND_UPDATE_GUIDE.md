# Backend Update Guide

Quick reference for updating the deployed web app on your backend server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Update (Automated)](#quick-update-automated)
- [Manual Update Steps](#manual-update-steps)
- [Using Portainer](#using-portainer)
- [Verification](#verification)
- [Rollback](#rollback)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- SSH access to your server
- Git repository cloned to `/opt/otogapo` (or your deployment directory)
- Docker and Docker Compose installed
- Existing deployment running

## Quick Update (Automated)

The fastest way to update your backend deployment:

```bash
# SSH into your server
ssh your-user@your-server-ip

# Navigate to project directory
cd /opt/otogapo

# Run the update script
./scripts/update_backend.sh
```

This script will:

1. ✅ Pull the latest code from Git
2. ✅ Build a new Docker image
3. ✅ Restart containers with the new image
4. ✅ Perform health checks
5. ✅ Show deployment status

**Expected Duration**: 3-5 minutes (depending on changes)

## Manual Update Steps

If you prefer to run commands individually:

### 1. Connect to Server

```bash
ssh your-user@your-server-ip
cd /opt/otogapo
```

### 2. Pull Latest Code

```bash
git pull origin main
```

**Check output**: Ensure no merge conflicts or errors.

### 3. Build Docker Image

```bash
docker build -t otogapo-web:latest .
```

**This builds**:

- Stage 1: Flutter web app (production target)
- Stage 2: Nginx server with the built app

**Expected time**: 3-4 minutes

### 4. Restart Containers

```bash
# Stop current containers
docker-compose down

# Start with new image
docker-compose up -d
```

### 5. Verify Deployment

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f otogapo

# Test health endpoint
curl http://localhost:8089/health
```

**Expected response**: `healthy`

### 6. Test Application

Open your browser and visit:

```
https://otogapo.lexserver.org
```

Or:

```
http://your-server-ip:8089
```

## Using Portainer

If you have Portainer installed, use this workflow for a visual deployment process:

### Step 1: Build Image on Server

```bash
# SSH to server
ssh your-user@your-server-ip

# Update code and build
cd /opt/otogapo
git pull origin main
docker build -t otogapo-web:latest .
```

### Step 2: Deploy via Portainer UI

1. **Open Portainer**: Navigate to `https://lexserver.org:9443` (or your Portainer URL)
2. **Go to Stacks**: Click "Stacks" in the left sidebar
3. **Select Stack**: Click on your `otogapo` stack
4. **Open Editor**: Click the "Editor" tab
5. **Update Stack**: Click "Update the stack" button
6. **CRITICAL**: Turn OFF the "Re-pull image" toggle
   - This ensures Portainer uses your locally built image
   - If ON, it will try to pull from a registry (which will fail)
7. **Confirm**: Click "Update" to deploy

### Step 3: Verify in Portainer

1. Go to **Containers** page
2. Check `otogapo` container is "running" (green status)
3. Click on container → **Logs** to view output
4. Verify recent creation time

**Benefits of Portainer**:

- Visual container monitoring
- Real-time log viewing
- Resource usage graphs
- Easy restarts and management

## Verification

After deployment, verify everything is working:

### 1. Container Status

```bash
docker-compose ps
```

**Expected**: All containers show `Up` status

### 2. Application Health

```bash
curl http://localhost:8089/health
```

**Expected**: `healthy`

### 3. Application Logs

```bash
docker-compose logs -f otogapo
```

**Look for**:

- No error messages
- Nginx started successfully
- Health checks passing

### 4. Browser Test

Open the application in multiple browsers:

- Chrome
- Firefox
- Safari (if available)
- Mobile browser

**Check**:

- Application loads without errors
- Recent changes are visible
- No console errors (F12 Developer Tools)

### 5. Performance Check

```bash
# Check response time
time curl -I https://otogapo.lexserver.org

# Check container resources
docker stats otogapo
```

## Rollback

If something goes wrong, you can quickly rollback:

### Option 1: Revert Git Changes

```bash
cd /opt/otogapo

# View recent commits
git log --oneline -5

# Revert to previous commit
git checkout <previous-commit-hash>

# Rebuild and redeploy
docker build -t otogapo-web:latest .
docker-compose down
docker-compose up -d
```

### Option 2: Use Previous Docker Image

```bash
# List available images
docker images | grep otogapo-web

# Tag previous image as latest
docker tag otogapo-web:<old-tag> otogapo-web:latest

# Restart containers
docker-compose down
docker-compose up -d
```

### Option 3: Restore from Backup

```bash
# Load backed up image
docker load < otogapo-web-backup.tar.gz

# Restart containers
docker-compose down
docker-compose up -d
```

## Troubleshooting

### Build Fails

**Problem**: Docker build fails with errors

**Solutions**:

```bash
# Clear Docker cache and rebuild
docker system prune -a
docker build --no-cache -t otogapo-web:latest .

# Check disk space
df -h

# Check Docker logs
docker logs <container-id>
```

### Application Not Starting

**Problem**: Container starts but app doesn't load

**Solutions**:

```bash
# Check container logs
docker-compose logs -f otogapo

# Check nginx configuration
docker-compose exec otogapo nginx -t

# Restart container
docker-compose restart otogapo
```

### Port Already in Use

**Problem**: Port 8089 is already in use

**Solutions**:

```bash
# Check what's using the port
sudo lsof -i :8089

# Stop conflicting service
docker stop <conflicting-container>

# Or change port in docker-compose.yml
# Edit ports: "8090:80" instead of "8089:80"
```

### Changes Not Visible

**Problem**: Deployed but changes don't appear

**Solutions**:

1. **Clear browser cache**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
2. **Verify image was rebuilt**:
   ```bash
   docker images | grep otogapo-web
   # Check "Created" timestamp
   ```
3. **Check container was recreated**:
   ```bash
   docker ps | grep otogapo
   # Check "Created" timestamp
   ```
4. **Verify correct code**:
   ```bash
   git log -1  # Check latest commit
   git status  # Check for uncommitted changes
   ```

### Health Check Fails

**Problem**: Health endpoint returns 503 or times out

**Solutions**:

```bash
# Check if nginx is running
docker-compose exec otogapo ps aux | grep nginx

# Check nginx error logs
docker-compose logs otogapo | grep error

# Restart container
docker-compose restart otogapo

# Check health manually
docker-compose exec otogapo curl http://localhost/health
```

## Environment-Specific Builds

By default, the Dockerfile builds the **production** target. To build for different environments:

### Development Build

Edit `Dockerfile` line 38:

```dockerfile
RUN flutter build web \
    --release \
    --target lib/main_development.dart \
    --base-href /
```

### Staging Build

Edit `Dockerfile` line 38:

```dockerfile
RUN flutter build web \
    --release \
    --target lib/main_staging.dart \
    --base-href /
```

### Production Build (Default)

```dockerfile
RUN flutter build web \
    --release \
    --target lib/main_production.dart \
    --base-href /
```

**After changing**: Rebuild the Docker image.

## Best Practices

1. **Always backup before updates**:

   ```bash
   docker save otogapo-web:latest | gzip > otogapo-backup-$(date +%Y%m%d).tar.gz
   ```

2. **Test locally first**:

   ```bash
   flutter run -d web-server --target lib/main_production.dart
   ```

3. **Use staging environment**: Test changes on staging before production

4. **Monitor logs during deployment**:

   ```bash
   docker-compose logs -f
   ```

5. **Keep old images** (at least 2-3 previous versions):

   ```bash
   docker tag otogapo-web:latest otogapo-web:v1.2.3
   ```

6. **Document breaking changes**: Update `CHANGELOG.md`

7. **Check resource usage**:
   ```bash
   docker stats
   df -h
   ```

## Useful Commands

```bash
# View all containers
docker ps -a

# View all images
docker images

# View logs (follow)
docker-compose logs -f

# View logs (last 100 lines)
docker-compose logs --tail=100

# Execute command in container
docker-compose exec otogapo sh

# Check nginx config
docker-compose exec otogapo nginx -t

# Reload nginx
docker-compose exec otogapo nginx -s reload

# View container stats
docker stats otogapo

# Clean up unused images/containers
docker system prune -a

# Export image
docker save otogapo-web:latest | gzip > backup.tar.gz

# Import image
docker load < backup.tar.gz
```

## Scheduled Updates

For automatic updates, you can set up a cron job:

```bash
# Edit crontab
crontab -e

# Add this line (updates every Sunday at 3 AM)
0 3 * * 0 /opt/otogapo/scripts/update_backend.sh > /opt/otogapo/update.log 2>&1
```

**Note**: Automatic updates are not recommended for production. Always test updates manually first.

## Related Documentation

- [Docker Deployment Guide](DOCKER_DEPLOYMENT.md) - Full Docker setup
- [Web Deployment Guide](WEB_DEPLOYMENT.md) - Complete web deployment options
- [Deployment Guide](DEPLOYMENT.md) - General deployment information
- [Architecture](ARCHITECTURE.md) - Application architecture

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review container logs: `docker-compose logs -f`
3. Check Docker documentation: https://docs.docker.com/
4. Review Flutter web docs: https://docs.flutter.dev/platform-integration/web

---

**Quick Command Reference**:

```bash
# Full update workflow
cd /opt/otogapo
git pull origin main
docker build -t otogapo-web:latest .
docker-compose down
docker-compose up -d
docker-compose logs -f
```
