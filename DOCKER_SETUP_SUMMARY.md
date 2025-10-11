# Docker Deployment Setup Summary

This document summarizes the Docker deployment files created for deploying the Oto Gapo Flutter web application to your Ubuntu server (lexserver.org).

## Files Created

### Core Docker Files

1. **`Dockerfile`** - Multi-stage Docker build file

   - Stage 1: Builds Flutter web app using Flutter SDK
   - Stage 2: Serves static files using Nginx Alpine
   - Includes health checks and proper MIME type configuration

2. **`docker-compose.yml`** - Docker Compose orchestration

   - Defines three services: otogapo-web, nginx-proxy, certbot
   - Manages networks and volumes
   - Handles automatic SSL renewal

3. **`.dockerignore`** - Excludes unnecessary files from Docker context
   - Reduces build time and image size
   - Excludes platform-specific builds and sensitive files

### Nginx Configuration

4. **`nginx/app.conf`** - Nginx config for serving Flutter app

   - SPA routing support (redirects all routes to index.html)
   - Proper MIME types for .wasm, .js, .json files
   - Gzip compression enabled
   - Static asset caching (1 year for assets, no cache for HTML)
   - Service worker handling

5. **`nginx/proxy.conf`** - Reverse proxy with SSL

   - HTTP to HTTPS redirect
   - SSL certificate configuration for Let's Encrypt
   - Security headers (HSTS, X-Frame-Options, etc.)
   - Proxy settings for WebSocket support
   - Server name: otogapo.lexserver.org

6. **`nginx/ssl-params.conf`** - SSL security parameters
   - TLS 1.2 and 1.3 support
   - Strong cipher configuration
   - OCSP stapling
   - SSL session optimization

### Deployment Scripts

7. **`scripts/deploy_docker.sh`** - Main deployment automation script

   - Validates environment configuration
   - Builds Flutter production web app
   - Creates Docker image
   - Initializes SSL certificates (first run)
   - Starts all services
   - Performs health checks

8. **`scripts/renew_ssl.sh`** - SSL certificate renewal script
   - Automatically renews Let's Encrypt certificates
   - Reloads Nginx after renewal
   - Logs renewal attempts
   - Designed to run via cron job

### Configuration Templates

9. **`env.template`** - Environment variables template
   - Domain configuration (otogapo.lexserver.org)
   - Email for Let's Encrypt notifications
   - Optional staging mode for testing
   - Docker image tags

### Documentation

10. **`DOCKER_DEPLOYMENT.md`** - Comprehensive deployment guide

    - Server prerequisites and setup
    - Step-by-step deployment instructions
    - Portainer integration guide
    - Troubleshooting common issues
    - Maintenance and backup procedures
    - Security best practices

11. **`docs/WEB_DEPLOYMENT.md`** - Updated with Docker deployment section

    - Added Docker deployment quick start
    - Docker architecture overview
    - Management commands
    - SSL certificate management
    - Portainer integration
    - Troubleshooting guide

12. **`README.md`** - Updated main README
    - Added Docker deployment section
    - Quick command reference
    - Link to detailed Docker documentation

### Git Configuration

13. **`.gitignore`** - Updated to exclude Docker artifacts
    - `.env` file (contains secrets)
    - `certbot/` directory (SSL certificates)
    - `certbot-renew.log` (renewal logs)

## Quick Start Guide

### On Your Ubuntu Server

1. **Clone the repository:**

   ```bash
   git clone <repository-url> /opt/otogapo
   cd /opt/otogapo
   ```

2. **Create .env file:**

   ```bash
   cp env.template .env
   nano .env
   ```

   Update with:

   ```bash
   DOMAIN=otogapo.lexserver.org
   EMAIL=your-actual-email@example.com
   LETSENCRYPT_STAGING=0
   ```

3. **Make scripts executable:**

   ```bash
   chmod +x scripts/deploy_docker.sh
   chmod +x scripts/renew_ssl.sh
   ```

4. **Deploy:**

   ```bash
   ./scripts/deploy_docker.sh
   ```

5. **Set up SSL auto-renewal:**

   ```bash
   crontab -e
   # Add this line:
   0 3 * * * /opt/otogapo/scripts/renew_ssl.sh
   ```

6. **Access your app:**
   ```
   https://otogapo.lexserver.org
   ```

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│         Internet (Port 80/443)              │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────┐
│    nginx-proxy (Reverse Proxy + SSL)     │
│  - SSL Termination (Let's Encrypt)       │
│  - HTTP → HTTPS redirect                 │
│  - Security headers                      │
└─────────────┬─────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│     otogapo-web (Flutter + Nginx)       │
│  - Static file serving                  │
│  - SPA routing                          │
│  - Gzip compression                     │
│  - Asset caching                        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│     certbot (Certificate Manager)        │
│  - Automatic certificate renewal        │
│  - Runs every 12 hours                  │
└─────────────────────────────────────────┘
```

## Key Features

### Security

- ✅ HTTPS with Let's Encrypt SSL
- ✅ Automatic certificate renewal
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ Strong TLS configuration (TLS 1.2+)

### Performance

- ✅ Gzip compression
- ✅ Static asset caching (1 year)
- ✅ HTML no-cache for updates
- ✅ Optimized Nginx configuration

### Deployment

- ✅ Automated deployment script
- ✅ Health checks
- ✅ Multi-stage Docker build
- ✅ Portainer compatible
- ✅ Easy rollback capability

### Maintenance

- ✅ Automatic SSL renewal via cron
- ✅ Comprehensive logging
- ✅ Docker Compose management
- ✅ Backup and restore procedures

## Environment Configuration

The `.env` file contains sensitive configuration:

- **DOMAIN**: Your domain name (otogapo.lexserver.org)
- **EMAIL**: Email for Let's Encrypt notifications
- **LETSENCRYPT_STAGING**: Use staging server for testing (0=production, 1=staging)

**Important:** Never commit the `.env` file to git!

## Managing the Deployment

### View logs

```bash
docker-compose logs -f
docker-compose logs -f otogapo-web
docker-compose logs -f nginx-proxy
```

### Restart services

```bash
docker-compose restart
```

### Update application

```bash
git pull origin main
./scripts/deploy_docker.sh
```

### Stop services

```bash
docker-compose down
```

### Complete cleanup (including volumes)

```bash
docker-compose down -v
```

## Portainer Management

If you're using Portainer:

1. Log in to Portainer (usually at https://lexserver.org:9443)
2. Navigate to **Stacks** → **Add Stack**
3. Choose **Git Repository** or **Upload**
4. Point to your repository or upload `docker-compose.yml`
5. Set environment variables (DOMAIN, EMAIL)
6. Click **Deploy the stack**

Benefits:

- Visual monitoring of containers
- Real-time log viewing
- Easy restarts and updates
- Resource usage graphs
- Webhook support for CI/CD

## Troubleshooting

### SSL Certificate Issues

If certificate generation fails:

```bash
# Check DNS
nslookup otogapo.lexserver.org

# Check port accessibility
curl -I http://otogapo.lexserver.org

# Use staging mode for testing
# Edit .env: LETSENCRYPT_STAGING=1
./scripts/deploy_docker.sh
```

### Container Not Starting

```bash
# Check logs
docker-compose logs otogapo-web

# Test nginx config
docker-compose exec nginx-proxy nginx -t

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port Conflicts

```bash
# Check what's using ports 80/443
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services
sudo systemctl stop apache2
sudo systemctl disable apache2
```

## Next Steps

1. **Deploy to your server** following the Quick Start Guide
2. **Test the deployment** at https://otogapo.lexserver.org
3. **Set up SSL auto-renewal** cron job
4. **Configure Portainer** for easier management (optional)
5. **Set up monitoring** for production (optional)

## Documentation

For more details, see:

- **DOCKER_DEPLOYMENT.md** - Comprehensive deployment guide
- **docs/WEB_DEPLOYMENT.md** - Web deployment options including Docker
- **README.md** - Project overview and setup

## Support

If you encounter issues:

1. Check the troubleshooting section in DOCKER_DEPLOYMENT.md
2. Review container logs: `docker-compose logs -f`
3. Verify DNS configuration
4. Ensure ports 80 and 443 are accessible
5. Check firewall settings on the server

## Files Summary

- **Configuration**: 3 files (Dockerfile, docker-compose.yml, .dockerignore)
- **Nginx Configs**: 3 files (app.conf, proxy.conf, ssl-params.conf)
- **Scripts**: 2 files (deploy_docker.sh, renew_ssl.sh)
- **Templates**: 1 file (env.template)
- **Documentation**: 3 files updated (DOCKER_DEPLOYMENT.md, docs/WEB_DEPLOYMENT.md, README.md)
- **Git Config**: 1 file updated (.gitignore)

**Total: 13 new/updated files**

---

**Ready to deploy!** Follow the Quick Start Guide above to get your Flutter web app running on your Ubuntu server with Docker, Nginx, and Let's Encrypt SSL.
