# Scripts Directory

This directory contains utility scripts for deployment, maintenance, and development tasks.

## Available Scripts

### Deployment Scripts

#### `deploy_docker.sh`

**Purpose**: Full Docker deployment with SSL certificate setup

**Usage**:

```bash
./scripts/deploy_docker.sh
```

**What it does**:

- Validates environment configuration
- Builds Flutter web application
- Creates Docker image
- Initializes SSL certificates (Let's Encrypt)
- Starts all services via Docker Compose

**When to use**: First-time deployment or full redeployment with SSL setup

**Prerequisites**:

- `.env` file configured with DOMAIN and EMAIL
- Docker and Docker Compose installed
- Ports 80 and 443 accessible

---

#### `update_backend.sh`

**Purpose**: Quick backend update for existing deployments

**Usage**:

```bash
./scripts/update_backend.sh
```

**What it does**:

- Pulls latest code from Git repository
- Builds new Docker image
- Restarts containers with updated image
- Performs health checks

**When to use**: Regular updates when you have code changes to deploy

**Prerequisites**:

- Existing deployment already running
- Git repository initialized
- Docker running

**Time**: 3-5 minutes

---

### SSL/Certificate Scripts

#### `renew_ssl.sh`

**Purpose**: Renew Let's Encrypt SSL certificates

**Usage**:

```bash
./scripts/renew_ssl.sh
```

**What it does**:

- Attempts to renew SSL certificates
- Reloads nginx if certificates were renewed
- Logs renewal status

**When to use**:

- Manual certificate renewal
- Scheduled via cron job (recommended)

**Recommended cron schedule**:

```bash
# Runs daily at 3 AM
0 3 * * * /opt/otogapo/scripts/renew_ssl.sh
```

---

### Build Scripts

#### `build_production.sh`

**Purpose**: Build production APK and AAB for Android

**Usage**:

```bash
./scripts/build_production.sh
```

**What it does**:

- Builds Android release APK
- Builds Android App Bundle (AAB)
- Creates versioned output files

**When to use**: Building Android releases for Play Store

---

#### `bump_version.sh`

**Purpose**: Increment app version numbers

**Usage**:

```bash
./scripts/bump_version.sh [major|minor|patch]
```

**Examples**:

```bash
./scripts/bump_version.sh patch  # 1.0.0 → 1.0.1
./scripts/bump_version.sh minor  # 1.0.0 → 1.1.0
./scripts/bump_version.sh major  # 1.0.0 → 2.0.0
```

**What it does**:

- Updates version in `pubspec.yaml`
- Increments build number
- Updates changelog

---

### Release Scripts

#### `generate_release_notes.sh`

**Purpose**: Generate release notes from Git commits

**Usage**:

```bash
./scripts/generate_release_notes.sh [version]
```

**Example**:

```bash
./scripts/generate_release_notes.sh v1.2.3
```

**What it does**:

- Extracts commits since last release
- Formats release notes
- Updates `RELEASE_NOTES.md`

---

### Development Scripts

#### `fix_lints.sh` / `fix_lints.ps1`

**Purpose**: Automatically fix linting issues

**Usage**:

**Linux/Mac**:

```bash
./scripts/fix_lints.sh
```

**Windows**:

```powershell
.\scripts\fix_lints.ps1
```

**What it does**:

- Runs `dart fix --apply`
- Formats code with `dart format`
- Reports remaining issues

---

### GitHub Scripts

#### `setup_github_secrets.sh`

**Purpose**: Set up GitHub repository secrets for CI/CD

**Usage**:

```bash
./scripts/setup_github_secrets.sh
```

**What it does**:

- Guides through GitHub secrets setup
- Provides commands for adding secrets
- Validates required secrets

---

## Quick Reference

### For Backend Updates

```bash
# Standard update workflow
cd /opt/otogapo
./scripts/update_backend.sh
```

### For New Deployments

```bash
# First-time deployment with SSL
./scripts/deploy_docker.sh
```

### For Android Releases

```bash
# Bump version
./scripts/bump_version.sh patch

# Build release files
./scripts/build_production.sh

# Generate release notes
./scripts/generate_release_notes.sh v1.2.3
```

### For SSL Renewal

```bash
# Manual renewal
./scripts/renew_ssl.sh

# Or set up automatic renewal
crontab -e
# Add: 0 3 * * * /opt/otogapo/scripts/renew_ssl.sh
```

## Script Permissions

Make scripts executable after cloning:

```bash
chmod +x scripts/*.sh
```

Or individually:

```bash
chmod +x scripts/deploy_docker.sh
chmod +x scripts/update_backend.sh
chmod +x scripts/renew_ssl.sh
chmod +x scripts/build_production.sh
chmod +x scripts/bump_version.sh
chmod +x scripts/generate_release_notes.sh
chmod +x scripts/fix_lints.sh
chmod +x scripts/setup_github_secrets.sh
```

## Environment Variables

Some scripts require environment variables. Create a `.env` file in project root:

```bash
# Copy template
cp env.template .env

# Edit with your values
nano .env
```

**Required variables**:

- `DOMAIN`: Your domain name (e.g., otogapo.lexserver.org)
- `EMAIL`: Email for Let's Encrypt notifications
- `LETSENCRYPT_STAGING`: 0 for production, 1 for testing

## Troubleshooting

### Script Won't Execute

**Problem**: Permission denied

**Solution**:

```bash
chmod +x scripts/script_name.sh
```

### Script Fails with "No such file or directory"

**Problem**: Line endings or path issues

**Solution**:

```bash
# Fix line endings (if using Windows)
dos2unix scripts/script_name.sh

# Ensure you're in the project root
cd /opt/otogapo
```

### Docker Commands Fail

**Problem**: Docker not running or permission issues

**Solution**:

```bash
# Check Docker status
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

## Related Documentation

- [Backend Update Guide](../docs/BACKEND_UPDATE_GUIDE.md) - Detailed update instructions
- [Docker Deployment Guide](../docs/DOCKER_DEPLOYMENT.md) - Full Docker setup
- [Deployment Guide](../docs/DEPLOYMENT.md) - General deployment info
- [Release Checklist](../docs/RELEASE_CHECKLIST.md) - Pre-release checklist

## Contributing

When adding new scripts:

1. Add executable permissions: `chmod +x scripts/new_script.sh`
2. Add script documentation to this README
3. Include error handling (`set -e`)
4. Add color-coded output for better UX
5. Include usage instructions in script header
6. Test on clean environment

## Script Template

Use this template for new scripts:

```bash
#!/bin/bash

# Script Name and Description
# Purpose: What this script does
# Usage: ./scripts/script_name.sh [arguments]

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}Script Title${NC}"
echo -e "${BLUE}====================================${NC}\n"

# Your script logic here

echo -e "\n${GREEN}✓ Script completed successfully${NC}"
```

