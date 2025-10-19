# Complete Deployment Workflow

**From Development to Production**

## 🔄 Full Workflow: Windows → GitHub → Server

### Step 1: On Your Windows Machine (Local Development)

After making code changes:

```bash
# 1. Check what changed
git status

# 2. Stage your changes
git add .

# 3. Commit with a clear message
git commit -m "Description of your changes"

# 4. Push to GitHub
git push origin main
```

**✅ Your code is now on GitHub!**

---

### Step 2: On Your Backend Server (Build via SSH)

SSH to your server and build the image:

```bash
# 1. SSH into your server
ssh your-user@your-server-ip

# 2. Navigate to deployment directory
cd /opt/otogapo

# 3. Pull the latest code from GitHub
git pull origin main

# 4. Build Docker image (with --no-cache for fresh build)
docker build --no-cache -t otogapo-web:latest .
```

**✅ Image is now built!**

### Step 3: Deploy in Portainer (via Browser)

Now deploy the built image using Portainer:

1. Open Portainer dashboard in your browser
2. Go to **Stacks**
3. Click on **otogapo** stack
4. Click **Editor** tab
5. Click **Update the stack** button
6. ⚠️ **IMPORTANT**: Do NOT turn on "Re-pull image" (leave it OFF)
7. Click **Update**

**✅ Your app is now deployed on the server!**

---

**Alternative**: Use the automated script to bypass Portainer UI:

```bash
# After SSH and cd /opt/otogapo
./scripts/update_backend.sh
```

This does steps 3-4 and uses docker-compose directly instead of Portainer UI.

---

## 📋 Detailed Workflow

### Phase 1: Local Development (Windows)

```powershell
# In your project directory (f:\madmonkey2\oto-gapo)

# Check current branch
git branch

# Check status of changes
git status

# Add all changes
git add .

# Commit changes
git commit -m "feat: Add new feature description"

# Push to GitHub
git push origin main

# Verify push succeeded
git log -1
```

**Common Commit Message Prefixes:**

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Formatting, styling
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

---

### Phase 2: Server Deployment (Linux Server)

#### Option A: Portainer Workflow (Your Standard Method)

**Part 1: Build via SSH**

```bash
# SSH to server
ssh your-user@your-server-ip

# Navigate to project
cd /opt/otogapo

# Pull latest code
git pull origin main

# Build Docker image with no cache
docker build --no-cache -t otogapo-web:latest .
```

**Part 2: Deploy via Portainer Browser UI**

1. Open Portainer dashboard
2. Go to **Stacks**
3. Click on **otogapo** stack
4. Click **Editor** tab
5. Click **Update the stack** button
6. ⚠️ **CRITICAL**: Do NOT turn on "Re-pull image" (leave it OFF)
7. Click **Update**

This workflow gives you visual control over the deployment via Portainer.

---

#### Option B: Automated Script (Bypasses Portainer UI)

```bash
# SSH to server
ssh your-user@your-server-ip

# Navigate to project
cd /opt/otogapo

# Run update script
./scripts/update_backend.sh
```

The script automatically:

1. ✅ Pulls latest code (`git pull origin main`)
2. ✅ Builds Docker image (with `--no-cache`)
3. ✅ Restarts containers via docker-compose (not Portainer)
4. ✅ Runs health checks

---

#### Option C: Manual Steps (No Portainer, No Script)

```bash
# SSH to server
ssh your-user@your-server-ip

# Navigate to project
cd /opt/otogapo

# Pull latest from GitHub
git pull origin main

# Check what was updated
git log -1

# Build new Docker image
docker build --no-cache -t otogapo-web:latest .

# Stop current containers
docker-compose down

# Start with new image
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f otogapo
```

---

## 🎯 Quick Reference

### Complete Update Command Chain

**On Windows:**

```bash
git add .
git commit -m "Your message"
git push origin main
```

**On Server (SSH):**

```bash
ssh user@server
cd /opt/otogapo
git pull origin main
docker build --no-cache -t otogapo-web:latest .
```

**In Portainer (Browser):**

```
Stacks → otogapo → Editor → Update the stack (Re-pull OFF) → Update
```

**Alternative (bypass Portainer UI):**

```bash
# On server, after cd /opt/otogapo
./scripts/update_backend.sh
```

---

## ⚠️ Important Notes

### Before Pushing to GitHub

1. **Test Locally First:**

   ```bash
   flutter run -d web-server --target lib/main_production.dart
   ```

2. **Check for Errors:**

   ```bash
   flutter analyze
   dart format .
   ```

3. **Run Tests:**
   ```bash
   flutter test
   ```

### After Deploying to Server

1. **Verify in Browser:**

   - Visit: `https://otogapo.lexserver.org`
   - Clear cache if needed (Ctrl+Shift+R)
   - Check console for errors (F12)

2. **Check Server Logs:**

   ```bash
   docker-compose logs -f otogapo
   ```

3. **Monitor Performance:**
   ```bash
   docker stats otogapo
   ```

---

## 🔧 Troubleshooting

### Problem: "Already up to date" but no changes on server

**Cause**: Forgot to push from Windows first

**Solution:**

```bash
# On Windows - check if commits are pushed
git log origin/main..HEAD

# If there are unpushed commits, push them
git push origin main
```

---

### Problem: Merge conflicts on server

**Cause**: Server has local changes or different branch

**Solution:**

```bash
# On server
cd /opt/otogapo

# Check status
git status

# If there are local changes, stash them
git stash

# Pull latest
git pull origin main

# If needed, reapply stashed changes
git stash pop
```

---

### Problem: Changes not visible after deployment

**Solutions:**

1. **Clear browser cache** (Ctrl+Shift+R)
2. **Verify container was rebuilt:**
   ```bash
   docker images | grep otogapo-web
   # Check "Created" timestamp
   ```
3. **Check if correct commit is deployed:**
   ```bash
   cd /opt/otogapo
   git log -1
   ```

---

## 📝 Example: Complete Update Session

### Scenario: You fixed a bug and want to deploy

**On Windows (f:\madmonkey2\oto-gapo):**

```bash
# After fixing the bug

git status
# See: modified:   lib/app/view/home_page.dart

git add lib/app/view/home_page.dart
git commit -m "fix: Resolve navigation issue on home page"
git push origin main
```

**On Server:**

```bash
ssh myuser@myserver.com
cd /opt/otogapo
./scripts/update_backend.sh
```

**Output you'll see:**

```
===================================
Updating Oto Gapo Web App
===================================

📥 Pulling latest code from repository...
From github.com:youruser/oto-gapo
   abc1234..def5678  main -> origin/main
✓ Code updated successfully

🔨 Building Docker image...
[+] Building 145.3s (18/18) FINISHED
✓ Docker image built successfully

🔄 Restarting containers...
✓ Containers restarted successfully

✓ Application is healthy

===================================
✅ Update Complete!
===================================
```

**Verify in browser:**

- Visit `https://otogapo.lexserver.org`
- Test the fix works
- ✅ Done!

---

## 🚀 Pro Tips

### 1. Use SSH Keys for Easier Login

On Windows, generate SSH key:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Copy to server:

```bash
ssh-copy-id your-user@your-server-ip
```

Now you can SSH without password!

---

### 2. Create Git Alias for Quick Push

On Windows:

```bash
git config --global alias.quickpush '!git add . && git commit -m "Quick update" && git push origin main'
```

Then just run:

```bash
git quickpush
```

---

### 3. Create Server Alias

On Windows, edit `~/.ssh/config`:

```
Host otogapo
    HostName your-server-ip
    User your-username
    IdentityFile ~/.ssh/id_ed25519
```

Now you can SSH with:

```bash
ssh otogapo
```

---

### 4. One-Command Deploy from Windows

Create `deploy.bat` in your project root:

```batch
@echo off
echo Pushing to GitHub...
git add .
git commit -m "%1"
git push origin main

echo Deploying to server...
ssh your-user@your-server "cd /opt/otogapo && ./scripts/update_backend.sh"

echo Done!
```

Usage:

```bash
deploy.bat "Your commit message"
```

---

## 📊 Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Development Workflow                      │
└─────────────────────────────────────────────────────────────┘

Windows Machine (f:\madmonkey2\oto-gapo)
    │
    │ 1. Make code changes
    │ 2. Test locally
    │ 3. git add .
    │ 4. git commit -m "message"
    │ 5. git push origin main
    ▼
GitHub Repository (origin/main)
    │
    │ Code is now stored in GitHub
    ▼
Linux Server via SSH (/opt/otogapo)
    │
    │ 6. git pull origin main
    │ 7. docker build --no-cache -t otogapo-web:latest .
    ▼
Portainer Web UI (Browser)
    │
    │ 8. Stacks → otogapo
    │ 9. Editor → Update the stack
    │ 10. Re-pull image: OFF
    │ 11. Click Update
    ▼
Production (https://otogapo.lexserver.org)
    │
    │ Users see updated app
    └─── ✅ DEPLOYED!

Alternative: Skip Portainer UI, use ./scripts/update_backend.sh
```

---

## 📚 Related Documentation

- **Backend Update Guide**: `docs/BACKEND_UPDATE_GUIDE.md`
- **Docker Deployment**: `docs/DOCKER_DEPLOYMENT.md`
- **Scripts Reference**: `scripts/README.md`
- **Quick Start**: `BACKEND_UPDATE_QUICKSTART.md`

---

## ✅ Deployment Checklist

Before deploying, ensure:

- [ ] Code compiles without errors
- [ ] Tests pass locally
- [ ] Changes committed to Git
- [ ] Changes pushed to GitHub (`git push origin main`)
- [ ] SSH access to server available
- [ ] Server has enough disk space (`df -h`)
- [ ] No one is actively using the app (or plan for downtime)

After deploying:

- [ ] Container is running (`docker-compose ps`)
- [ ] No errors in logs (`docker-compose logs`)
- [ ] App loads in browser
- [ ] Recent changes are visible
- [ ] All features work as expected
- [ ] Mobile view works (if applicable)

---

**Remember**: The flow is always:

1. **Windows**: Code → Commit → Push
2. **Server**: Pull → Build → Deploy
