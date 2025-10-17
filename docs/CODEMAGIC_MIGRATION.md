# Migration Guide: GitHub Actions to Codemagic

**Last Updated:** October 17, 2025  
**Status:** ✅ READY FOR MIGRATION

## Overview

This guide helps you transition from GitHub Actions to Codemagic for CI/CD in the OtoGapo project. Both platforms can coexist during the transition, allowing you to test Codemagic without disrupting your existing workflows.

## Table of Contents

- [Why Migrate?](#why-migrate)
- [Migration Strategy](#migration-strategy)
- [Step-by-Step Migration](#step-by-step-migration)
- [Workflow Mapping](#workflow-mapping)
- [Credential Migration](#credential-migration)
- [Testing Plan](#testing-plan)
- [Rollback Plan](#rollback-plan)
- [FAQ](#faq)

---

## Why Migrate?

### Benefits of Codemagic

| Feature                   | GitHub Actions                   | Codemagic                   |
| ------------------------- | -------------------------------- | --------------------------- |
| **Setup Complexity**      | Manual YAML + Secrets + Fastlane | GUI + YAML (simpler)        |
| **Play Store Publishing** | Requires Fastlane configuration  | Built-in, one-click         |
| **Keystore Management**   | Base64 encoding + Secrets        | Upload in UI                |
| **iOS Builds**            | Need Mac or paid runner          | Included (Mac M1)           |
| **Flutter Optimization**  | Generic CI                       | Flutter-specific            |
| **Build Speed**           | ~15-20 min                       | ~10-15 min (better caching) |
| **Debugging**             | GitHub logs                      | Visual logs with filters    |
| **Cost (private repo)**   | 2,000 min/month free             | 500 min/month free          |

### When to Migrate

✅ **Migrate if:**

- You want simpler Play Store deployment
- You need iOS builds without a Mac
- You prefer GUI over YAML for credentials
- Build speed is critical
- You're within 500 min/month usage

❌ **Stay with GitHub Actions if:**

- You're comfortable with current setup
- You need more than 500 min/month (free tier)
- You require custom deployment targets
- Infrastructure-as-code is critical for your team

---

## Migration Strategy

### Recommended Approach: Parallel Running

**Phase 1: Setup Codemagic (Week 1)**

- Set up Codemagic account
- Configure credentials
- Test CI builds

**Phase 2: Parallel Testing (Weeks 2-3)**

- Run both platforms simultaneously
- Compare build times and reliability
- Verify Play Store uploads work

**Phase 3: Gradual Transition (Week 4)**

- Use Codemagic for releases
- Keep GitHub Actions for CI
- Monitor for issues

**Phase 4: Full Migration (Week 5+)**

- Disable GitHub Actions release workflow
- Use Codemagic exclusively
- Archive GitHub Actions workflows (optional)

### Alternative Approach: Immediate Switch

**Only recommended if:**

- You're starting fresh (no active releases)
- You've tested Codemagic thoroughly
- You have rollback plan ready

---

## Step-by-Step Migration

### Prerequisites Checklist

Before starting migration, ensure you have:

- [ ] Codemagic account created
- [ ] GitHub repository connected to Codemagic
- [ ] `codemagic.yaml` committed to repository
- [ ] Android keystore file accessible
- [ ] Key properties from `android/key.properties`
- [ ] Google Play service account JSON
- [ ] Email for notifications

---

### Step 1: Initial Codemagic Setup (30 minutes)

#### 1.1 Create Account and Connect Repository

```bash
# No commands needed - done in browser:
# 1. Visit codemagic.io
# 2. Sign in with GitHub
# 3. Add application: oto-gapo
# 4. Select "Flutter App"
```

**Verification:**
✅ Repository appears in Codemagic dashboard

#### 1.2 Verify Configuration File

```bash
# Ensure codemagic.yaml exists
ls -la codemagic.yaml

# Verify it's committed
git log --oneline -- codemagic.yaml
```

**Verification:**
✅ Codemagic detects configuration automatically

---

### Step 2: Migrate Android Code Signing (15 minutes)

#### 2.1 Upload Keystore to Codemagic

**In Codemagic Dashboard:**

1. Settings → Code signing identities → Android
2. Click "Add keystore"
3. Upload: `android/keystore/otogapo-release.jks`

**From `android/key.properties`:**

```properties
# Copy these values to Codemagic:
storePassword=<your_password>
keyPassword=<your_key_password>
keyAlias=<your_alias>
storeFile=keystore/otogapo-release.jks
```

**Reference name in Codemagic:** `otogapo_release`

#### 2.2 Verify in codemagic.yaml

Ensure the workflow references it:

```yaml
android_signing:
  - otogapo_release
```

**Verification:**
✅ Manual build workflow can be triggered successfully

---

### Step 3: Migrate Google Play Credentials (20 minutes)

#### 3.1 Locate Existing Service Account

**If using GitHub Actions:**

```bash
# Your service account JSON is in GitHub Secrets:
# GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

# Download from Google Cloud Console:
# 1. Go to console.cloud.google.com
# 2. IAM & Admin → Service Accounts
# 3. Find: codemagic-publisher (or create new)
# 4. Keys → Add Key → Create new key → JSON
```

#### 3.2 Upload to Codemagic

**In Codemagic Dashboard:**

1. Teams → Integrations
2. Google Play → Connect
3. Upload service account JSON
4. Name: `google-play-otogapo`

#### 3.3 Create Environment Variable Group

**In Codemagic Dashboard:**

1. Teams → Environment variables
2. Add variable group: `google_play`
3. Add variable:
   - Name: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - Value: (auto-populated from integration)
   - Secure: ✅

**Verification:**
✅ Environment variable group appears in Codemagic

---

### Step 4: Test Codemagic Builds (2-3 hours)

#### 4.1 Test CI Workflow

```bash
# Create test branch
git checkout -b test/codemagic-ci

# Make small change
echo "# Codemagic CI test" >> README.md
git commit -am "test: codemagic CI"
git push origin test/codemagic-ci
```

**Watch in Codemagic:**

- Go to Builds
- Watch `android-ci` workflow
- Verify all steps pass
- Download artifacts

**Verification:**
✅ CI build completes successfully
✅ APKs downloadable from artifacts

#### 4.2 Test Manual Build

**In Codemagic Dashboard:**

1. Start new build
2. Select workflow: `manual-build`
3. Click "Start new build"

**Verification:**
✅ Signed APK and AAB created
✅ No keystore errors

#### 4.3 Test Production Release

```bash
# Create test tag
git checkout main
git pull origin main

git tag v1.0.1-codemagic-test
git push origin v1.0.1-codemagic-test
```

**Watch in Codemagic:**

- Both `android-production` and `web-production` trigger
- Monitor build logs
- Check Play Console for upload

**Verification:**
✅ Android AAB uploaded to Play Store internal track
✅ Web build completes
✅ Email notification received

#### 4.4 Clean Up Test Tag

```bash
# Delete test tag after successful test
git tag -d v1.0.1-codemagic-test
git push origin :refs/tags/v1.0.1-codemagic-test
```

---

### Step 5: Parallel Running (1-2 weeks)

#### 5.1 Configure Both Platforms

**Keep GitHub Actions active for:**

- CI on pull requests
- Code quality checks
- Backup builds

**Use Codemagic for:**

- All release builds
- Manual testing builds
- Play Store uploads

#### 5.2 Monitoring Checklist

During parallel running, monitor:

- [ ] Build success rates (both platforms)
- [ ] Build times comparison
- [ ] Play Store upload reliability
- [ ] Build minute usage (Codemagic)
- [ ] Any build failures or errors

#### 5.3 Compare Results

**Create comparison spreadsheet:**

| Metric             | GitHub Actions        | Codemagic         | Winner       |
| ------------------ | --------------------- | ----------------- | ------------ |
| CI build time      | 10-12 min             | 8-10 min          | ✅ Codemagic |
| Release build time | 15-18 min             | 12-15 min         | ✅ Codemagic |
| Setup complexity   | Manual YAML + Secrets | GUI + Simple YAML | ✅ Codemagic |
| Play Store upload  | Via Fastlane          | Built-in          | ✅ Codemagic |
| Build reliability  | 95%                   | ?                 | TBD          |
| Cost (monthly)     | $0 (public)           | $0 (<500 min)     | ✅ Tie       |

---

### Step 6: Disable GitHub Actions (30 minutes)

#### 6.1 Option A: Disable Release Workflow Only (Recommended)

```bash
# Rename release workflow to disable
mv .github/workflows/release.yml .github/workflows/release.yml.disabled
mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled
mv .github/workflows/manual_build.yml .github/workflows/manual_build.yml.disabled
mv .github/workflows/web-deploy.yml .github/workflows/web-deploy.yml.disabled

# Keep CI active
# Keep: .github/workflows/ci.yml

# Commit changes
git add .github/workflows/
git commit -m "chore: migrate release workflows to Codemagic, keep CI"
git push origin main
```

**Result:** GitHub Actions runs CI only, Codemagic handles releases

#### 6.2 Option B: Disable All GitHub Actions

```bash
# Disable all workflows
mv .github/workflows .github/workflows.disabled

# Commit changes
git add .github/
git commit -m "chore: migrate to Codemagic, disable GitHub Actions"
git push origin main
```

**Result:** Codemagic handles everything

#### 6.3 Option C: Keep Both Active (Zero-Change)

Leave everything as-is. Both platforms will build independently.

**Result:** Maximum redundancy, higher build minute usage

---

### Step 7: Update Documentation (15 minutes)

```bash
# Update deployment documentation
# See: docs/DEPLOYMENT.md
# Add reference to Codemagic setup

# Update README.md
# Add Codemagic badge
```

**Add to README.md:**

```markdown
[![Codemagic build status](https://api.codemagic.io/apps/<APP_ID>/status_badge.svg)](https://codemagic.io/apps/<APP_ID>/latest_build)
```

Replace `<APP_ID>` with your Codemagic app ID (found in Settings).

---

## Workflow Mapping

### CI Workflow

| GitHub Actions             | Codemagic                | Notes            |
| -------------------------- | ------------------------ | ---------------- |
| `.github/workflows/ci.yml` | `android-ci` workflow    | Nearly identical |
| Triggers: push, PR         | Triggers: push, PR       | Same             |
| Formats, analyzes, tests   | Formats, analyzes, tests | Same             |
| Builds dev/staging APKs    | Builds dev/staging APKs  | Same             |

### Release Workflow

| GitHub Actions                  | Codemagic                  | Notes      |
| ------------------------------- | -------------------------- | ---------- |
| `.github/workflows/release.yml` | `android-production`       | Simplified |
| Decodes keystore from secrets   | Uses uploaded keystore     | Easier     |
| Builds AAB/APK                  | Builds AAB/APK             | Same       |
| Uploads via Fastlane            | Built-in Play Store upload | Simpler    |
| Creates GitHub Release          | Artifacts in Codemagic     | Different  |

### Web Deploy Workflow

| GitHub Actions                     | Codemagic                               | Notes        |
| ---------------------------------- | --------------------------------------- | ------------ |
| `.github/workflows/web-deploy.yml` | `web-production`, `web-firebase-deploy` | Split into 2 |
| Manual or auto trigger             | Tag or push to main                     | Similar      |
| Builds web app                     | Builds web app                          | Same         |
| Deploys to Firebase                | Deploys to Firebase                     | Same         |

### Manual Build Workflow

| GitHub Actions                       | Codemagic                      | Notes        |
| ------------------------------------ | ------------------------------ | ------------ |
| `.github/workflows/manual_build.yml` | `manual-build`                 | Same concept |
| UI trigger with parameters           | UI trigger (can edit workflow) | Similar      |
| Builds selected flavor               | Builds selected flavor         | Same         |

---

## Credential Migration

### From GitHub Secrets to Codemagic

| GitHub Secret                      | Codemagic Location                 | Migration Method                    |
| ---------------------------------- | ---------------------------------- | ----------------------------------- |
| `ANDROID_KEYSTORE_BASE64`          | Settings → Code signing → Android  | Upload `.jks` file                  |
| `ANDROID_KEYSTORE_PASSWORD`        | Same location                      | Enter in form                       |
| `ANDROID_KEY_ALIAS`                | Same location                      | Enter in form                       |
| `ANDROID_KEY_PASSWORD`             | Same location                      | Enter in form                       |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Teams → Integrations → Google Play | Upload JSON file                    |
| `FIREBASE_TOKEN` (if used)         | Teams → Environment variables      | Create `firebase_credentials` group |

### Credentials You Can Keep in GitHub

If keeping GitHub Actions for CI:

- ✅ Keep `ANDROID_KEYSTORE_BASE64` (for CI builds if needed)
- ❌ Remove `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (security best practice: minimize exposure)

### Security Considerations

1. **Keystore Security:**

   - Codemagic stores keystores encrypted at rest
   - Access controlled via team permissions
   - Equivalent security to GitHub Secrets

2. **Service Account Security:**

   - Codemagic integrates directly with Google Play API
   - Credentials scoped per integration
   - Can revoke access easily

3. **Best Practice:**
   - Use separate service accounts for GitHub Actions and Codemagic
   - Rotate credentials quarterly
   - Audit access logs regularly

---

## Testing Plan

### Pre-Migration Testing

- [ ] CI builds pass on test branch
- [ ] Manual builds create signed artifacts
- [ ] Production release uploads to Play Store internal track
- [ ] Web builds complete successfully
- [ ] Email notifications working
- [ ] Build times acceptable

### During Migration Testing

- [ ] Monitor both platforms for 1-2 weeks
- [ ] Compare build success rates
- [ ] Verify Play Store uploads from Codemagic
- [ ] Test rollback to GitHub Actions
- [ ] Gather team feedback

### Post-Migration Testing

- [ ] First production release via Codemagic successful
- [ ] Play Store promotion working
- [ ] Web deployment functioning
- [ ] Documentation updated
- [ ] Team comfortable with new workflow

---

## Rollback Plan

### If Issues Arise

#### Option 1: Quick Rollback (5 minutes)

```bash
# Re-enable GitHub Actions workflows
mv .github/workflows/release.yml.disabled .github/workflows/release.yml
mv .github/workflows/deploy.yml.disabled .github/workflows/deploy.yml

git add .github/workflows/
git commit -m "rollback: re-enable GitHub Actions"
git push origin main
```

#### Option 2: Use GitHub Actions for One Release

```bash
# Create tag that triggers GitHub Actions
# (Ensure workflows are still in place)
git tag v1.0.2-github
git push origin v1.0.2-github
```

#### Option 3: Manual Build and Upload

```bash
# Build locally
./scripts/build_production.sh appbundle

# Upload to Play Console manually
# Go to console.play.google.com
# Upload: build/app/outputs/bundle/productionRelease/app-production-release.aab
```

### Keeping Both Active

**Safest approach during transition:**

- Keep GitHub Actions workflows active
- Add Codemagic in parallel
- Use GitHub Actions as backup
- Gradually shift to Codemagic

**Trade-off:** Uses build minutes on both platforms

---

## FAQ

### Q: Can I use both GitHub Actions and Codemagic permanently?

**A:** Yes! You can:

- Use GitHub Actions for CI (tests, formatting)
- Use Codemagic for releases and Play Store uploads
- Both read from the same repository

### Q: What happens to my existing GitHub Actions secrets?

**A:** Nothing. They remain in GitHub Secrets. You can:

- Keep them (for rollback)
- Delete them (if fully migrated)
- Keep them (if using GitHub Actions for CI)

### Q: Will old GitHub releases still work?

**A:** Yes, existing GitHub releases are unaffected. New releases will be:

- Artifacts in Codemagic (downloadable)
- Direct uploads to Play Store (via Codemagic)
- Can still create GitHub releases manually if desired

### Q: How do I create GitHub releases with Codemagic?

**A:** Two options:

1. **Manual:** Download artifacts from Codemagic, create GitHub release manually
2. **Automated:** Add script to Codemagic workflow using GitHub CLI

### Q: What if I exceed 500 build minutes on Codemagic?

**A:** Options:

1. Upgrade to paid plan ($99/month for teams)
2. Fall back to GitHub Actions temporarily
3. Optimize builds to use fewer minutes
4. Use pay-as-you-go ($0.095/min)

### Q: Can I trigger Codemagic builds from GitHub Actions?

**A:** Yes, using Codemagic API. Add script to GitHub Actions:

```yaml
- name: Trigger Codemagic build
  run: |
    curl -X POST \
      -H "x-auth-token: ${{ secrets.CODEMAGIC_API_TOKEN }}" \
      https://api.codemagic.io/builds
```

### Q: Do I need to change my git workflow?

**A:** No. Codemagic watches the same branches and tags as GitHub Actions.

### Q: What about iOS builds in the future?

**A:** Codemagic includes Mac M1 builders. iOS setup:

1. Add iOS code signing certificates
2. Add provisioning profiles
3. Uncomment/add iOS workflow in `codemagic.yaml`

### Q: Can I customize build environments?

**A:** Yes, via `codemagic.yaml`:

- Custom environment variables
- Pre-build and post-build scripts
- Dependency versions
- Build machine types

### Q: How do I handle different environments (dev/staging/prod)?

**A:** Already configured:

- `android-ci` builds dev and staging
- `android-production` builds production
- Can add more workflows for different environments

---

## Migration Checklist

### Pre-Migration

- [ ] Read this guide thoroughly
- [ ] Review Codemagic documentation
- [ ] Backup existing keystore and credentials
- [ ] Document current GitHub Actions workflow
- [ ] Get team buy-in

### Migration Steps

- [ ] Create Codemagic account
- [ ] Connect GitHub repository
- [ ] Upload Android keystore
- [ ] Configure Google Play credentials
- [ ] Configure environment variables
- [ ] Test CI workflow
- [ ] Test manual build
- [ ] Test production release (test tag)
- [ ] Monitor parallel running (1-2 weeks)
- [ ] Decide on migration strategy
- [ ] Disable GitHub Actions (if desired)
- [ ] Update documentation
- [ ] Train team on new workflow

### Post-Migration

- [ ] Monitor first production release
- [ ] Gather team feedback
- [ ] Document any issues
- [ ] Update runbooks
- [ ] Archive or delete old workflows
- [ ] Clean up GitHub Secrets (if not needed)
- [ ] Set up monitoring/alerts

---

## Additional Resources

- **Codemagic Setup Guide**: [CODEMAGIC_SETUP.md](./CODEMAGIC_SETUP.md)
- **Deployment Guide**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Play Store Setup**: [PLAY_STORE_SETUP.md](./PLAY_STORE_SETUP.md)
- **Codemagic Documentation**: [docs.codemagic.io](https://docs.codemagic.io/)
- **GitHub Actions Workflows**: [.github/workflows/](./.github/workflows/)

---

## Support

For migration issues:

1. **Check build logs** in Codemagic dashboard
2. **Review this guide** for troubleshooting tips
3. **Contact Codemagic Support**: support@codemagic.io
4. **Rollback if needed** using rollback plan above

---

**Good luck with your migration! 🚀**
