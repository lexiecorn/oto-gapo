# Codemagic CI/CD Setup Guide for OtoGapo

**Last Updated:** October 17, 2025  
**Status:** ✅ CONFIGURED

## Overview

This guide walks you through setting up Codemagic for automated CI/CD for the OtoGapo Flutter application. Codemagic provides a Flutter-native CI/CD platform with simplified Play Store deployment and Mac builds for iOS.

## Table of Contents

- [Why Codemagic?](#why-codemagic)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Configure Android Code Signing](#configure-android-code-signing)
- [Configure Google Play Publishing](#configure-google-play-publishing)
- [Configure Firebase (Optional)](#configure-firebase-optional)
- [Workflows Explained](#workflows-explained)
- [Testing Your Setup](#testing-your-setup)
- [Usage Guide](#usage-guide)
- [Troubleshooting](#troubleshooting)
- [Cost and Limits](#cost-and-limits)

---

## Why Codemagic?

### Advantages over GitHub Actions

- ✅ **Flutter-native platform** - Pre-configured Flutter environment
- ✅ **GUI-based setup** - No YAML wrestling for credentials
- ✅ **One-click Play Store publishing** - No Fastlane configuration needed
- ✅ **Mac builds included** - iOS builds without owning a Mac
- ✅ **Better caching** - Faster Flutter builds with intelligent caching
- ✅ **Visual build logs** - Easier to debug build issues
- ✅ **Integrated code signing** - Upload keystore once in UI

### When to Use Codemagic

- ✅ You want simpler Play Store deployment
- ✅ You need iOS builds without a Mac
- ✅ You prefer GUI configuration over YAML
- ✅ You want Flutter-specific optimizations
- ✅ Build speed is important

---

## Prerequisites

### Required

1. **GitHub Account** - Your code repository
2. **Google Play Developer Account** ($25 one-time fee)
3. **Android Keystore** - For signing releases
   - Location: `android/keystore/otogapo-release.jks`
   - Properties: `android/key.properties`
4. **Google Play Service Account JSON** - For automated publishing
   - See [Play Store Setup Guide](./PLAY_STORE_SETUP.md)

### Optional

5. **Firebase Account** - For web hosting (optional)
6. **Firebase Token** - For automated Firebase deployments (optional)

---

## Initial Setup

### Step 1: Sign Up for Codemagic

1. Go to [codemagic.io](https://codemagic.io)
2. Click **"Sign in with GitHub"**
3. Authorize Codemagic to access your repositories

### Step 2: Add Your Application

1. Click **"Add application"** in Codemagic dashboard
2. Select **GitHub** as your repository source
3. Find and select **oto-gapo** repository
4. Choose **"Flutter App"** as the project type
5. Click **"Finish: Add application"**

### Step 3: Verify Configuration File

Codemagic will automatically detect the `codemagic.yaml` file in your repository root. The file includes:

- ✅ **android-ci** - Continuous integration on every push
- ✅ **android-production** - Release builds on version tags
- ✅ **web-production** - Web builds on version tags
- ✅ **web-firebase-deploy** - Auto-deploy to Firebase
- ✅ **manual-build** - On-demand builds for testing

No additional configuration needed in the UI for basic builds!

---

## Configure Android Code Signing

### Step 1: Navigate to Code Signing

1. Open your app in Codemagic dashboard
2. Go to **Settings** → **Code signing identities**
3. Select **Android** tab

### Step 2: Upload Keystore

1. Click **"Add keystore"**
2. Fill in the details:

   **Keystore file:**
   - Click **"Choose file"**
   - Upload `android/keystore/otogapo-release.jks`

   **Keystore password:**
   - From `android/key.properties`: `storePassword` value
   
   **Key alias:**
   - From `android/key.properties`: `keyAlias` value
   
   **Key password:**
   - From `android/key.properties`: `keyPassword` value

3. Give it a **reference name**: `otogapo_release`
4. Click **"Save"**

### Step 3: Verify Configuration

The keystore is now automatically used when the `codemagic.yaml` specifies:

```yaml
android_signing:
  - otogapo_release
```

✅ **Done!** No need to manage base64 encoding or GitHub Secrets.

---

## Configure Google Play Publishing

### Step 1: Get Service Account JSON

If you haven't already created a Google Play service account, follow these steps:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable **Google Play Android Developer API**
4. Create a **Service Account**:
   - Go to **IAM & Admin** → **Service Accounts**
   - Click **"Create Service Account"**
   - Name: `codemagic-publisher`
   - Click **"Create and Continue"**
5. Create a **JSON key**:
   - Click on the service account
   - Go to **Keys** tab
   - Click **"Add Key"** → **"Create new key"**
   - Choose **JSON** format
   - Download the JSON file

6. Link to Google Play Console:
   - Go to [Google Play Console](https://play.google.com/console/)
   - Navigate to **Setup** → **API access**
   - Click **"Link"** next to your service account
   - Grant permissions: **Release Manager** or **Admin**

For detailed instructions, see [Play Store Setup Guide](./PLAY_STORE_SETUP.md).

### Step 2: Add to Codemagic

1. In Codemagic dashboard, go to **Teams**
2. Select your team (usually your username)
3. Go to **Integrations** tab
4. Find **Google Play** section
5. Click **"Connect"**
6. Upload your service account JSON file
7. Give it a name: `google-play-otogapo`

### Step 3: Create Environment Variable Group

1. Go to **Environment variables** (in Teams section)
2. Click **"Add variable group"**
3. Name it: `google_play`
4. Add variable:
   - **Variable name**: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - **Value**: Will be auto-populated from Google Play integration
   - **Group**: `google_play`
   - **Secure**: ✅ Enabled

5. Click **"Add"**

### Step 4: Create Keystore Credentials Group

1. Still in **Environment variables**
2. Click **"Add variable group"**
3. Name it: `keystore_credentials`
4. Add your email for notifications:
   - **Variable name**: `CM_EMAIL`
   - **Value**: `your-email@example.com`
   - **Group**: `keystore_credentials`
   - **Secure**: ❌ (not sensitive)

5. Click **"Add"**

✅ **Done!** Your workflows will now automatically publish to Google Play.

---

## Configure Firebase (Optional)

If you want to auto-deploy web builds to Firebase Hosting:

### Step 1: Get Firebase Token

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and get token
firebase login:ci
```

Copy the token displayed.

### Step 2: Add to Codemagic

1. In Codemagic, go to **Teams** → **Environment variables**
2. Click **"Add variable group"**
3. Name it: `firebase_credentials`
4. Add variables:
   
   **Firebase Token:**
   - **Variable name**: `FIREBASE_TOKEN`
   - **Value**: (paste the token from step 1)
   - **Group**: `firebase_credentials`
   - **Secure**: ✅ Enabled
   
   **Firebase Project ID:**
   - **Variable name**: `FIREBASE_PROJECT_ID`
   - **Value**: `otogapo-prod` (or your Firebase project ID)
   - **Group**: `firebase_credentials`
   - **Secure**: ❌ (not sensitive)

5. Click **"Add"**

✅ **Done!** Web deployment to Firebase is now automated.

---

## Workflows Explained

### 1. android-ci (Continuous Integration)

**Triggers:**
- Push to any branch
- Pull requests

**What it does:**
- ✅ Verifies code formatting
- ✅ Runs static analysis
- ✅ Generates code with build_runner
- ✅ Runs tests with coverage
- ✅ Builds development and staging APKs

**Artifacts:**
- Development and staging APKs
- Code coverage report

**Notification:** Only on failure

---

### 2. android-production (Production Release)

**Triggers:**
- Git tags matching `v*.*.*` (e.g., `v1.0.0`)

**What it does:**
- ✅ Runs tests
- ✅ Builds signed Android App Bundle (AAB)
- ✅ Builds signed Android APK
- ✅ Uploads AAB to Google Play Store (internal track)
- ✅ Creates GitHub-like release artifacts

**Artifacts:**
- Android App Bundle (.aab)
- Android APK (.apk)
- ProGuard mapping file

**Publishing:**
- Google Play Console (internal track)
- 10% rollout initially
- Email notification on success/failure

**Configuration:**
- Track: `internal` (can be changed to alpha/beta/production)
- Rollout: 10% (can be adjusted in `codemagic.yaml`)

---

### 3. web-production (Web Build)

**Triggers:**
- Git tags matching `v*.*.*` (e.g., `v1.0.0`)

**What it does:**
- ✅ Builds production web application
- ✅ Creates web archive (ZIP)
- ✅ Generates deployment metadata

**Artifacts:**
- Web build files
- ZIP archive
- deployment-info.json

**Notification:** On success and failure

---

### 4. web-firebase-deploy (Firebase Auto-Deploy)

**Triggers:**
- Push to `main` branch

**What it does:**
- ✅ Builds production web application
- ✅ Automatically deploys to Firebase Hosting
- ✅ Updates live website

**Artifacts:**
- Web build files

**Notification:** On success and failure

**Note:** Requires Firebase configuration (see above)

---

### 5. manual-build (On-Demand Builds)

**Triggers:**
- Manual trigger via Codemagic UI

**What it does:**
- ✅ Builds APK and AAB for selected flavor
- ✅ Useful for testing before release

**Parameters:**
- `BUILD_FLAVOR`: development, staging, or production
- `BUILD_TARGET`: corresponding main file

**Usage:** Go to Codemagic → Start new build → Select workflow

---

## Testing Your Setup

### Test 1: CI Workflow (No credentials needed)

1. Make a small change to your code
2. Commit and push to a feature branch:
   ```bash
   git checkout -b test/codemagic
   echo "# Codemagic test" >> README.md
   git commit -am "test: codemagic CI"
   git push origin test/codemagic
   ```
3. Go to Codemagic dashboard
4. Watch the **android-ci** workflow run
5. Verify all steps complete successfully

**Expected result:** ✅ Build passes, APKs are available in artifacts

---

### Test 2: Manual Build (Requires keystore)

1. Go to Codemagic dashboard
2. Click **"Start new build"**
3. Select workflow: **manual-build**
4. Click **"Start new build"**
5. Monitor the build progress

**Expected result:** ✅ Build completes, signed APK and AAB available

---

### Test 3: Production Release (Requires all credentials)

1. Verify all credentials are configured:
   - ✅ Android keystore uploaded
   - ✅ Google Play service account configured
   - ✅ Environment variable groups created

2. Create a test release tag:
   ```bash
   # Make sure you're on main and up to date
   git checkout main
   git pull origin main
   
   # Create and push a tag
   git tag v1.0.1-codemagic-test
   git push origin v1.0.1-codemagic-test
   ```

3. Go to Codemagic dashboard
4. Watch both **android-production** and **web-production** workflows trigger
5. Monitor build progress

**Expected results:**
- ✅ Both workflows complete successfully
- ✅ AAB uploaded to Google Play Console (internal track)
- ✅ APK and Web ZIP available in artifacts
- ✅ Email notification received

---

### Test 4: Firebase Deployment (Optional)

If you configured Firebase:

1. Make a change to web UI
2. Commit and push to main:
   ```bash
   git checkout main
   git commit -am "feat: update web UI"
   git push origin main
   ```
3. Watch **web-firebase-deploy** workflow trigger
4. Verify deployment:
   - Check Codemagic build logs
   - Visit your Firebase hosting URL
   - Confirm changes are live

**Expected result:** ✅ Web app deployed to Firebase automatically

---

## Usage Guide

### Standard Release Process

1. **Develop and test locally**
   ```bash
   flutter test
   flutter build apk --debug --target lib/main_development.dart --flavor development
   ```

2. **Create PR and merge to main**
   - CI runs automatically on PR
   - Merge after approval and passing tests

3. **Bump version**
   ```bash
   ./scripts/bump_version.sh minor  # or major/patch
   ```

4. **Update CHANGELOG.md**
   - Document changes
   - Commit version bump and changelog

5. **Create release tag**
   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

6. **Automated deployment happens:**
   - ✅ Builds Android AAB and APK
   - ✅ Builds Web application
   - ✅ Uploads to Play Store internal track (10% rollout)
   - ✅ Email notification sent

7. **Test on internal track**
   - Install from Play Store internal track
   - Verify functionality
   - Monitor crash reports

8. **Promote to beta/production**
   - Go to Google Play Console
   - Navigate to **Release** → **Internal testing**
   - Click **"Promote release"** → **Beta** or **Production**
   - Or adjust track in `codemagic.yaml` and re-run

---

### Hotfix Process

1. **Create hotfix branch**
   ```bash
   git checkout -b hotfix/critical-bug main
   ```

2. **Make minimal fix**
   ```bash
   # Fix the bug
   git commit -am "fix: critical bug in payment flow"
   ```

3. **Bump patch version**
   ```bash
   ./scripts/bump_version.sh patch
   ```

4. **Push and tag**
   ```bash
   git push origin hotfix/critical-bug
   git tag v1.2.1
   git push origin v1.2.1
   ```

5. **Automated deployment to Play Store**

6. **Merge back to main**
   ```bash
   git checkout main
   git merge hotfix/critical-bug
   git push origin main
   ```

---

### Adjusting Rollout Percentage

To change the initial rollout percentage for production releases:

1. Edit `codemagic.yaml`
2. Find the `android-production` workflow
3. Update the `rollout_fraction`:
   ```yaml
   google_play:
     track: internal
     rollout_fraction: 0.5  # Change from 0.1 (10%) to 0.5 (50%)
   ```
4. Commit and push changes

---

### Changing Deployment Track

To deploy directly to beta or production:

1. Edit `codemagic.yaml`
2. Find the `android-production` workflow
3. Update the `GOOGLE_PLAY_TRACK` variable:
   ```yaml
   vars:
     GOOGLE_PLAY_TRACK: "beta"  # or "production"
   ```
4. Commit and push changes

**Warning:** Always test on internal or beta track before production!

---

## Troubleshooting

### Build Fails: "Keystore not found"

**Cause:** Android keystore not configured in Codemagic

**Solution:**
1. Go to Settings → Code signing identities → Android
2. Verify keystore is uploaded
3. Check reference name matches `codemagic.yaml`: `otogapo_release`

---

### Build Fails: "Google Play credentials not found"

**Cause:** Service account not configured

**Solution:**
1. Go to Teams → Integrations → Google Play
2. Verify service account JSON is uploaded
3. Check environment variable group `google_play` exists
4. Verify `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` is set

---

### Upload Fails: "Service account doesn't have access"

**Cause:** Service account lacks permissions in Play Console

**Solution:**
1. Go to [Google Play Console](https://play.google.com/console/)
2. Navigate to Setup → API access
3. Find your service account
4. Grant **Release Manager** or **Admin** role
5. Save changes

---

### Build Fails: "Version code already exists"

**Cause:** Version code in `pubspec.yaml` already uploaded

**Solution:**
1. Edit `pubspec.yaml`
2. Increment the build number:
   ```yaml
   version: 1.0.0+6  # Increment +5 to +6
   ```
3. Commit and push
4. Re-tag and push:
   ```bash
   git tag -d v1.0.0  # Delete old tag locally
   git push origin :refs/tags/v1.0.0  # Delete remote tag
   git tag v1.0.0
   git push origin v1.0.0
   ```

---

### Web Build Fails: "Flutter web not enabled"

**Cause:** Flutter web not configured

**Solution:** The workflow automatically runs `flutter config --enable-web`. If it still fails:
1. Check Codemagic logs for specific error
2. Verify `web/index.html` exists
3. Ensure Flutter version supports web (3.24.0 does)

---

### Firebase Deploy Fails: "Invalid token"

**Cause:** Firebase token expired or incorrect

**Solution:**
1. Generate new token:
   ```bash
   firebase login:ci
   ```
2. Update in Codemagic:
   - Teams → Environment variables
   - Find `firebase_credentials` group
   - Update `FIREBASE_TOKEN` value
3. Retry deployment

---

## Cost and Limits

### Free Tier

- ✅ **500 build minutes/month**
- ✅ **Personal and open-source projects**
- ✅ **All platforms** (Android, iOS, web, desktop)
- ✅ **Mac builds included**

### Typical Usage

| Activity | Duration | Frequency | Monthly Minutes |
|----------|----------|-----------|-----------------|
| CI builds | ~10 min | 20 pushes/month | 200 min |
| Release builds | ~15 min | 2 releases/month | 30 min |
| Manual builds | ~12 min | 5 tests/month | 60 min |
| **Total** | | | **~290 min/month** |

✅ **Well within free tier!**

### Paid Plans

If you exceed free tier:

- **Pay-as-you-go**: $0.095/minute (~$5.70/hour)
- **Team plan**: $99/month (unlimited builds)
- **Enterprise**: Custom pricing

### Optimization Tips

1. **Use CI workflow for quick checks** - Faster than full release
2. **Cache dependencies** - Already configured in `codemagic.yaml`
3. **Combine builds** - Release Android and Web together
4. **Test locally first** - Avoid unnecessary CI builds

---

## Next Steps

### Immediate Actions

1. ✅ Sign up for Codemagic
2. ✅ Add your repository
3. ✅ Upload Android keystore
4. ✅ Configure Google Play credentials
5. ✅ Test with a CI build
6. ✅ Test with a manual build
7. ✅ Test with a production release tag

### Optional Enhancements

1. ⚠️ Set up iOS code signing (when ready for iOS)
2. ⚠️ Configure Firebase auto-deployment
3. ⚠️ Add Slack notifications
4. ⚠️ Set up build badges
5. ⚠️ Configure custom build triggers

### Monitoring and Maintenance

1. **Monitor build minutes** - Check usage in Codemagic dashboard
2. **Review build logs** - Check for warnings or performance issues
3. **Update Flutter version** - Keep `codemagic.yaml` in sync with `pubspec.yaml`
4. **Rotate credentials** - Update keystore and service accounts annually

---

## Additional Resources

- **Codemagic Documentation**: [docs.codemagic.io](https://docs.codemagic.io/)
- **Flutter CI/CD Guide**: [docs.codemagic.io/flutter-configuration/flutter-projects/](https://docs.codemagic.io/flutter-configuration/flutter-projects/)
- **Sample Projects**: [github.com/codemagic-ci-cd/codemagic-sample-projects](https://github.com/codemagic-ci-cd/codemagic-sample-projects)
- **Play Store Setup**: [Play Store Setup Guide](./PLAY_STORE_SETUP.md)
- **Firebase Setup**: [Web Deployment Guide](./WEB_DEPLOYMENT.md)

---

## Support

For issues or questions:

1. **Codemagic Support**: support@codemagic.io
2. **Community Slack**: [Join Codemagic Slack](https://codemagic.io/slack)
3. **Project Documentation**: See other guides in `docs/`

---

**Happy Building! 🚀**

