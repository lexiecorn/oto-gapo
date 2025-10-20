# Backend Update Quick Start

**Last Updated**: October 19, 2025

Quick reference for updating your deployed web application on the backend server.

## 🚀 Quick Update (3 Steps)

### Step 1: SSH to Your Server

```bash
ssh your-user@your-server-ip
cd /opt/otogapo
```

### Step 2: Run Update Script

```bash
./scripts/update_backend.sh
```

### Step 3: Verify

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f otogapo

# Test in browser
# Visit: https://otogapo.lexserver.org
```

**Done!** ✅ Your backend is updated in 3-5 minutes.

---

## 📋 Manual Update (If You Prefer Step-by-Step)

```bash
# 1. Pull latest code
git pull origin main

# 2. Build Docker image
docker build -t otogapo-web:latest .

# 3. Restart containers
docker-compose down
docker-compose up -d

# 4. Check status
docker-compose ps
docker-compose logs -f
```

---

## 🔧 Using Portainer

If you have Portainer installed:

### On Server (via SSH):

```bash
cd /opt/otogapo
git pull origin main
docker build -t otogapo-web:latest .
```

### In Portainer Web UI:

1. Open Portainer → **Stacks** → **otogapo**
2. Click **Editor** tab
3. Click **Update the stack**
4. ⚠️ **Turn OFF "Re-pull image" toggle**
5. Click **Update**

---

## ✅ Verification Checklist

After updating, verify:

- [ ] Container is running: `docker-compose ps`
- [ ] No errors in logs: `docker-compose logs -f otogapo`
- [ ] Health check passes: `curl http://localhost:8089/health`
- [ ] App loads in browser: `https://otogapo.lexserver.org`
- [ ] Recent changes are visible

---

## 🆘 Troubleshooting

### Changes Not Visible?

```bash
# Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)
# Or check if container was recreated:
docker ps | grep otogapo
```

### Build Fails?

```bash
# Check disk space
df -h

# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t otogapo-web:latest .
```

### Container Won't Start?

```bash
# Check logs
docker-compose logs otogapo

# Restart
docker-compose restart otogapo

# Full restart
docker-compose down
docker-compose up -d
```

### Port Conflict?

```bash
# Check what's using port 8089
sudo lsof -i :8089

# Stop conflicting service
docker stop <container-name>
```

---

## 🔄 Rollback (If Something Goes Wrong)

```bash
# Revert to previous Git commit
git log --oneline -5
git checkout <previous-commit-hash>

# Rebuild and redeploy
docker build -t otogapo-web:latest .
docker-compose down
docker-compose up -d
```

---

## 📱 Useful Commands

```bash
# View logs (follow live)
docker-compose logs -f

# View logs (last 100 lines)
docker-compose logs --tail=100 otogapo

# Check container stats
docker stats otogapo

# Restart container
docker-compose restart otogapo

# Stop all containers
docker-compose down

# Start containers
docker-compose up -d

# Clean up unused images
docker system prune -a
```

---

## 📚 Full Documentation

For detailed information:

- **Backend Update Guide**: `docs/BACKEND_UPDATE_GUIDE.md`
- **Docker Deployment**: `docs/DOCKER_DEPLOYMENT.md`
- **Web Deployment**: `docs/WEB_DEPLOYMENT.md`
- **Scripts Reference**: `scripts/README.md`

---

## 🎯 Common Scenarios

### Scenario 1: Regular Code Update

```bash
cd /opt/otogapo
./scripts/update_backend.sh
```

**Time**: 3-5 minutes

### Scenario 2: Update with Environment Changes

```bash
# Update .env file first
nano .env

# Then update
./scripts/update_backend.sh
```

### Scenario 3: Emergency Rollback

```bash
git checkout <previous-commit>
docker build -t otogapo-web:latest .
docker-compose down && docker-compose up -d
```

**Time**: 2-3 minutes

---

## 📞 Support

Having issues? Check:

1. Container logs: `docker-compose logs -f otogapo`
2. System resources: `df -h` and `free -h`
3. Docker status: `docker ps` and `docker images`
4. Nginx config: `docker-compose exec otogapo nginx -t`

---

**Quick Help**:

- Scripts: `scripts/README.md`
- Docker: `docs/DOCKER_DEPLOYMENT.md`
- Full Guide: `docs/BACKEND_UPDATE_GUIDE.md`

