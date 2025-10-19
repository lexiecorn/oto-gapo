# 🚀 Deploy Now - Your Actual Workflow

## Step 1: Push from Windows

```bash
# In f:\madmonkey2\oto-gapo

git add .
git commit -m "Your changes description"
git push origin main
```

**✅ Code is now on GitHub**

---

## Step 2: Build on Server (via SSH)

```bash
# 1. SSH to your server
ssh your-user@your-server-ip

# 2. Navigate to project
cd /opt/otogapo

# 3. Pull latest code
git pull origin main

# 4. Build Docker image (with --no-cache)
docker build --no-cache -t otogapo-web:latest .
```

**✅ Image is now built!**

---

## Step 3: Deploy via Portainer (Browser)

1. Open **Portainer dashboard** in your browser
2. Go to **otogapo stack**
3. Click **Editor** tab
4. Click **Update the stack** button
5. ⚠️ **Do NOT turn on "Re-pull image"** (leave it OFF)
6. Click **Update**

**✅ App is now deployed!**

---

## ⚠️ Critical Reminders

1. **ALWAYS push from Windows first!** If you don't push, the server won't see your changes.

2. **Use `--no-cache` flag** when building to ensure fresh build with no cached layers.

3. **Turn OFF "Re-pull image"** in Portainer. You built the image locally, not from Docker Hub.

```
Windows → GitHub → Server (SSH) → Portainer (Browser)
 (push)            (pull+build)      (deploy)
```

---

## Quick Verify

After deployment, check in Portainer:

- Go to **Containers**
- Check that `otogapo` container is green (running)
- Click container → **Logs** to view output

In browser:

- Visit `https://otogapo.lexserver.org`
- Clear cache if needed (Ctrl+Shift+R)
- Verify your changes are visible

---

## Alternative: Automated Script (Bypasses Portainer UI)

If you want to skip Portainer UI and use command line only:

```bash
# On server (after ssh and cd /opt/otogapo)
./scripts/update_backend.sh
```

This script does Steps 2-3 automatically using docker-compose instead of Portainer.

---

**That's it!**

For more details: `COMPLETE_DEPLOYMENT_WORKFLOW.md`
