# Web Deployment Guide

This guide covers deploying the Oto Gapo web application to various hosting providers.

## Table of Contents

- [Overview](#overview)
- [Local Web Build](#local-web-build)
- [CI/CD Workflows](#cicd-workflows)
- [Firebase Hosting](#firebase-hosting)
- [GitHub Pages](#github-pages)
- [Manual Deployment](#manual-deployment)
- [Troubleshooting](#troubleshooting)

## Overview

The Oto Gapo app supports web deployment through Flutter's web platform. The app can be deployed to multiple hosting providers including:

- **Firebase Hosting** (recommended for production)
- **GitHub Pages** (good for staging/preview)
- **Custom hosting** (any static file server)

## Local Web Build

### Development Server

Run the app locally in development mode:

```bash
# Using web-server (accessible from any browser)
flutter run -d web-server --target lib/main_development.dart --web-port 8080

# Using Chrome (requires Chrome installed)
flutter run -d chrome --target lib/main_development.dart
```

Access the app at: http://localhost:8080

### Production Build

Build the production web app:

```bash
# Production build
flutter build web --release --target lib/main_production.dart --base-href /

# Staging build
flutter build web --release --target lib/main_staging.dart --base-href /

# Development build
flutter build web --release --target lib/main_development.dart --base-href /
```

The built files will be in `build/web/`.

### Testing Production Build Locally

Serve the production build locally:

```bash
# Using Python 3
cd build/web
python -m http.server 8000

# Using Node.js (http-server package)
npx http-server build/web -p 8000

# Using PHP
cd build/web
php -S localhost:8000
```

Access at: http://localhost:8000

## CI/CD Workflows

### Automated Web Deployment

The project includes automated web deployment workflows:

#### 1. Web Deploy Workflow (`web-deploy.yml`)

Manually triggered or automatic on push to main:

```bash
# Trigger manually via GitHub Actions UI
# Go to: Actions → Deploy Web → Run workflow
```

**Options:**

- **Environment**: `development`, `staging`, or `production`
- **Hosting Provider**: `firebase`, `github-pages`, or `artifacts-only`

#### 2. Release Workflow (`release.yml`)

Automatically builds and attaches web build to GitHub releases:

```bash
# Create a release tag
git tag v1.0.0
git push origin v1.0.0
```

This will:

- Build Android APK and AAB
- Build Web application
- Create GitHub release with all artifacts
- Optionally deploy to Google Play Store

### CI Testing

The `ci.yml` workflow automatically tests web builds on every push:

- Runs on all branches
- Builds production web app
- Verifies compilation succeeds

## Firebase Hosting

### Prerequisites

1. **Firebase Project**: Create a project at [Firebase Console](https://console.firebase.google.com)

2. **Firebase CLI**: Install locally for testing

   ```bash
   npm install -g firebase-tools
   firebase login
   ```

3. **Initialize Firebase Hosting**:

   ```bash
   firebase init hosting
   ```

   Configuration (`firebase.json`):

   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

### GitHub Secrets Setup

Configure these secrets in GitHub repository settings:

- `FIREBASE_TOKEN`: Firebase CI token

  ```bash
  firebase login:ci
  ```

- `FIREBASE_SERVICE_ACCOUNT`: Service account JSON (recommended)

  - Go to Firebase Console → Project Settings → Service Accounts
  - Generate new private key
  - Copy entire JSON content

- `FIREBASE_PROJECT_ID`: Your Firebase project ID

### Manual Firebase Deploy

```bash
# Build the web app
flutter build web --release --target lib/main_production.dart

# Deploy to Firebase
firebase deploy --only hosting

# Deploy to specific channel
firebase hosting:channel:deploy staging
```

### Automatic Firebase Deploy

1. Push to `main` branch:

   ```bash
   git push origin main
   ```

2. Or manually trigger:
   - Go to GitHub Actions
   - Select "Deploy Web" workflow
   - Choose "firebase" as hosting provider
   - Run workflow

## GitHub Pages

### Prerequisites

1. **Enable GitHub Pages**:

   - Go to Repository Settings → Pages
   - Set source to "GitHub Actions"

2. **Configure Base HREF**:
   If deploying to a repository page (e.g., `username.github.io/oto-gapo`):
   ```bash
   flutter build web --release --base-href /oto-gapo/
   ```

### Manual GitHub Pages Deploy

```bash
# Build with correct base href
flutter build web --release --target lib/main_production.dart --base-href /oto-gapo/

# Deploy using gh-pages branch (alternative method)
git subtree push --prefix build/web origin gh-pages
```

### Automatic GitHub Pages Deploy

1. Trigger via GitHub Actions:

   - Go to GitHub Actions
   - Select "Deploy Web" workflow
   - Choose "github-pages" as hosting provider
   - Run workflow

2. Access your deployed app at:
   - Organization page: `https://username.github.io/`
   - Repository page: `https://username.github.io/oto-gapo/`

## Manual Deployment

### Build and Package

```bash
# Build production web app
flutter build web --release --target lib/main_production.dart

# Create archive
cd build/web
zip -r ../../otogapo-web-v1.0.0.zip .
cd ../..
```

### Deploy to Custom Server

1. **Upload files**: Transfer all files from `build/web/` to your web server

2. **Server Configuration**:

   **Apache** (`.htaccess`):

   ```apache
   <IfModule mod_rewrite.c>
     RewriteEngine On
     RewriteBase /
     RewriteRule ^index\.html$ - [L]
     RewriteCond %{REQUEST_FILENAME} !-f
     RewriteCond %{REQUEST_FILENAME} !-d
     RewriteRule . /index.html [L]
   </IfModule>
   ```

   **Nginx**:

   ```nginx
   location / {
     try_files $uri $uri/ /index.html;
   }
   ```

3. **Set proper MIME types**: Ensure server serves `.wasm` files with correct content type:
   ```
   application/wasm
   ```

### Deploy to Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
flutter build web --release --target lib/main_production.dart
netlify deploy --dir=build/web --prod
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
flutter build web --release --target lib/main_production.dart
vercel --prod
```

## Docker Deployment

Deploy using Docker containers with Nginx reverse proxy and Let's Encrypt SSL certificates.

### Prerequisites

- Ubuntu 20.04 or later server
- Docker and Docker Compose installed
- Domain name pointing to server IP
- Ports 80 and 443 accessible

### Quick Start

1. **Clone repository on server:**

   ```bash
   git clone <repository-url> /opt/otogapo
   cd /opt/otogapo
   ```

2. **Configure environment:**

   Create `.env` file with your settings:

   ```bash
   DOMAIN=otogapo.lexserver.org
   EMAIL=your-email@example.com
   LETSENCRYPT_STAGING=0
   ```

3. **Make scripts executable:**

   ```bash
   chmod +x scripts/deploy_docker.sh scripts/renew_ssl.sh
   ```

4. **Deploy:**

   ```bash
   ./scripts/deploy_docker.sh
   ```

   This will:

   - Build Flutter web app (production)
   - Create Docker image
   - Initialize SSL certificates via Let's Encrypt
   - Start all services

5. **Access application:**

   ```
   https://otogapo.lexserver.org
   ```

### Docker Architecture

The deployment uses three containers:

- **otogapo-web**: Flutter app served via Nginx
- **nginx-proxy**: Reverse proxy with SSL termination
- **certbot**: Automatic SSL certificate management

### Managing the Deployment

```bash
# View status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update application
git pull origin main
./scripts/deploy_docker.sh
```

### SSL Certificate Management

Certificates are automatically obtained on first deployment. Set up automatic renewal:

```bash
# Add to crontab
crontab -e

# Add this line (runs at 3 AM daily)
0 3 * * * /opt/otogapo/scripts/renew_ssl.sh
```

### Portainer Integration

If you have Portainer installed:

1. Navigate to **Stacks** → **Add Stack**
2. Upload `docker-compose.yml` or point to Git repository
3. Set environment variables
4. Deploy and manage via Portainer UI

Benefits:

- Visual container monitoring
- One-click restarts
- Real-time log viewing
- Resource usage graphs
- Webhook support for auto-deployment

### Configuration Files

Key files for Docker deployment:

- `Dockerfile`: Multi-stage build (Flutter + Nginx)
- `docker-compose.yml`: Service definitions
- `nginx/app.conf`: Flutter app Nginx config
- `nginx/proxy.conf`: Reverse proxy config with SSL
- `nginx/ssl-params.conf`: SSL security settings
- `scripts/deploy_docker.sh`: Automated deployment
- `scripts/renew_ssl.sh`: SSL renewal script

### Troubleshooting Docker Deployment

**SSL certificate fails:**

```bash
# Check DNS
nslookup otogapo.lexserver.org

# Check port 80 accessibility
curl -I http://otogapo.lexserver.org

# Test with staging (no rate limits)
# Edit .env: LETSENCRYPT_STAGING=1
./scripts/deploy_docker.sh
```

**Container not starting:**

```bash
# Check logs
docker-compose logs otogapo-web

# Check nginx config
docker-compose exec nginx-proxy nginx -t

# Rebuild without cache
docker-compose build --no-cache
```

**Port conflicts:**

```bash
# Check what's using ports
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services
sudo systemctl stop apache2
```

### Performance Optimization

The Docker deployment includes:

- Gzip compression enabled
- Static asset caching (1 year)
- Multi-stage builds (smaller images)
- Health checks
- Resource limits (configurable)

### Backup and Rollback

**Backup:**

```bash
# Backup certificates
tar -czf certbot-backup-$(date +%Y%m%d).tar.gz certbot/

# Save Docker image
docker save otogapo-web:latest | gzip > otogapo-backup.tar.gz
```

**Rollback:**

```bash
# Stop current deployment
docker-compose down

# Load previous image
docker load < otogapo-backup.tar.gz

# Start with previous version
docker-compose up -d
```

For detailed Docker deployment instructions, see `DOCKER_DEPLOYMENT.md`.

## Environment-Specific Builds

The app supports multiple environments:

```bash
# Development
flutter build web --release --target lib/main_development.dart

# Staging
flutter build web --release --target lib/main_staging.dart

# Production
flutter build web --release --target lib/main_production.dart
```

Each environment uses different Firebase configurations:

- Development: `firebase_options_dev.dart`
- Production: `firebase_options_prod.dart`

## Build Optimization

### Performance Tips

1. **Enable web renderers**:

   ```bash
   # Use CanvasKit for better performance (larger bundle)
   flutter build web --web-renderer canvaskit

   # Use HTML renderer for smaller bundle
   flutter build web --web-renderer html

   # Auto (default - chooses based on device)
   flutter build web --web-renderer auto
   ```

2. **Enable tree-shaking** (enabled by default in release):

   - Removes unused code
   - Reduces bundle size

3. **Asset optimization**:
   - Compress images before including
   - Use WebP format for web
   - Minimize asset sizes

### Build Flags

```bash
# Full optimization
flutter build web \
  --release \
  --target lib/main_production.dart \
  --web-renderer auto \
  --source-maps \
  --pwa-strategy offline-first
```

## Deployment Info

Each build includes a `deployment-info.json` file with:

```json
{
  "version": "1.0.0+1",
  "environment": "production",
  "build_date": "2024-10-11T12:00:00Z",
  "commit": "abc123...",
  "branch": "main"
}
```

Access at: `https://your-domain.com/deployment-info.json`

## Troubleshooting

### Build Issues

**Issue**: `No supported devices found with name or id matching 'chrome'`

**Solution**: Enable web support

```bash
flutter config --enable-web
flutter devices  # Verify web is listed
```

**Issue**: Service worker version warning

**Solution**: Already fixed in `web/index.html` using template token:

```javascript
var serviceWorkerVersion = "{{flutter_service_worker_version}}";
```

### Deployment Issues

**Issue**: Blank page after deployment

**Solutions**:

1. Check base href matches deployment path
2. Verify server configuration for SPA routing
3. Check browser console for errors
4. Ensure MIME types are correct

**Issue**: Assets not loading

**Solutions**:

1. Verify `--base-href` flag is correct
2. Check asset paths in `pubspec.yaml`
3. Ensure server serves all files from `build/web/`

**Issue**: Firebase deployment fails

**Solutions**:

1. Verify Firebase project is initialized
2. Check Firebase credentials in GitHub secrets
3. Ensure `firebase.json` points to correct directory
4. Run `firebase login` and test locally first

### Performance Issues

**Issue**: Slow initial load

**Solutions**:

1. Use `--web-renderer auto` or `html` for smaller bundle
2. Enable CDN for hosting
3. Implement lazy loading for routes
4. Optimize images and assets

**Issue**: Large bundle size

**Solutions**:

1. Use HTML renderer: `--web-renderer html`
2. Remove unused dependencies
3. Split code by routes
4. Compress assets

## Monitoring and Analytics

### Firebase Analytics

Web analytics is automatically enabled when using Firebase:

```dart
// Already configured in bootstrap.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Custom Metrics

Add deployment info endpoint for monitoring:

```bash
curl https://your-domain.com/deployment-info.json
```

## Rollback Strategy

### GitHub Pages

```bash
# Revert to previous deployment
git revert <commit-hash>
git push origin main
```

### Firebase Hosting

```bash
# List recent deployments
firebase hosting:channel:list

# Rollback to specific version
firebase hosting:rollback
```

### Manual Hosting

Keep previous builds archived:

```bash
# Create dated archives
flutter build web --release
cd build/web
zip -r ../../otogapo-web-$(date +%Y%m%d-%H%M%S).zip .
```

## Best Practices

1. **Always test locally** before deploying
2. **Use staging environment** for testing
3. **Monitor bundle size** with each release
4. **Enable analytics** to track usage
5. **Keep backups** of production builds
6. **Document custom configurations**
7. **Use environment-specific configs** for API endpoints
8. **Test on multiple browsers** (Chrome, Firefox, Safari, Edge)
9. **Implement progressive web app (PWA)** features
10. **Set up monitoring** and error tracking

## Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Flutter Web Performance](https://docs.flutter.dev/perf/web-performance)

## Support

For issues or questions:

1. Check the [troubleshooting section](#troubleshooting)
2. Review [GitHub Actions logs](../../actions)
3. Check deployment provider logs
4. Contact the development team
