# Your Deployment Workflow (Corrected)

## ✅ Your Actual 3-Step Process

### Step 1: Push from Windows

```bash
# In f:\madmonkey2\oto-gapo
git add .
git commit -m "Your changes description"
git push origin main
```

---

### Step 2: Build on Server (SSH)

```bash
# 1. SSH to server
ssh your-user@your-server-ip

# 2. Navigate to project
cd /opt/otogapo

# 3. Pull latest code from GitHub
git pull origin main

# 4. Build Docker image with --no-cache
docker build --no-cache -t otogapo-web:latest .
```

---

### Step 3: Deploy via Portainer (Browser)

1. Open **Portainer dashboard**
2. Go to **otogapo stack**
3. Click **Editor** tab
4. Click **Update the stack** button
5. ⚠️ **Do NOT turn on "Re-pull image"** (leave it OFF)
6. Click **Update**

---

## 🎯 Complete Flow Diagram

```
Windows (f:\madmonkey2\oto-gapo)
    │
    │ git push origin main
    ▼
GitHub
    │
    │ git pull origin main
    ▼
Server (SSH - /opt/otogapo)
    │
    │ docker build --no-cache
    ▼
Portainer (Browser)
    │
    │ Update stack (Re-pull OFF)
    ▼
✅ DEPLOYED!
```

---

## ⚠️ Critical Points

1. **Always use `--no-cache`** when building to ensure fresh build
2. **Always turn OFF "Re-pull image"** in Portainer (you built locally)
3. **Always push from Windows BEFORE pulling on server**

---

## 📝 Quick Reference

| Step | Location          | Command                                           |
| ---- | ----------------- | ------------------------------------------------- |
| 1    | Windows           | `git push origin main`                            |
| 2    | Server SSH        | `git pull origin main`                            |
| 3    | Server SSH        | `docker build --no-cache -t otogapo-web:latest .` |
| 4    | Portainer Browser | Update stack (Re-pull OFF)                        |

---

## 🔄 Alternative: Automated Script

If you want to skip Portainer UI and use command-line only:

```bash
# On server (after cd /opt/otogapo)
./scripts/update_backend.sh
```

This script:

- Pulls latest code
- Builds with `--no-cache`
- Restarts via docker-compose (bypasses Portainer UI)
- Runs health checks

**Note**: This is an alternative to your normal Portainer workflow.

---

## 📂 All Documentation Files

1. **`YOUR_DEPLOYMENT_WORKFLOW.md`** ← **THIS FILE** - Your actual workflow
2. **`DEPLOY_NOW.md`** - Quick 3-step guide
3. **`DEPLOY_CHECKLIST.txt`** - Printable checklist
4. **`COMPLETE_DEPLOYMENT_WORKFLOW.md`** - Full detailed guide
5. **`BACKEND_UPDATE_QUICKSTART.md`** - Server command reference
6. **`docs/BACKEND_UPDATE_GUIDE.md`** - Comprehensive guide
7. **`scripts/README.md`** - Scripts documentation

---

## ✅ Verification After Deployment

**In Portainer:**

- Check **Containers** page
- Container `otogapo` should be green (running)
- Click container → **Logs** to view output

**In Browser:**

- Visit `https://otogapo.lexserver.org`
- Clear cache (Ctrl+Shift+R)
- Verify changes are visible

---

## 🆘 Common Issues

### Changes not visible?

```bash
# Make sure you pushed from Windows
git log origin/main..HEAD  # Should show nothing

# Make sure you pulled on server
cd /opt/otogapo && git log -1

# Clear browser cache
Ctrl+Shift+R (or Cmd+Shift+R)
```

### Build fails?

```bash
# Check disk space
df -h

# Clean Docker cache
docker system prune -a

# Try building again
docker build --no-cache -t otogapo-web:latest .
```

### Portainer shows old version?

- Make sure you clicked **Update the stack**
- Make sure **"Re-pull image" was OFF**
- Check container creation time in Portainer

---

**That's your actual workflow!**

Start here next time: `YOUR_DEPLOYMENT_WORKFLOW.md` or `DEPLOY_NOW.md`

