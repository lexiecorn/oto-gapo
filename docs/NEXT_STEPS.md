# Next Steps - Play Store Release Guide

Congratulations! The CI/CD infrastructure is now set up. Follow these steps to release Otogapo to the Google Play Store.

## Quick Navigation

- [Immediate Actions](#immediate-actions) - Do these first
- [Play Store Setup](#play-store-setup) - Create app listing
- [GitHub Configuration](#github-configuration) - Configure secrets
- [First Release](#first-release) - Deploy to internal track
- [Production Release](#production-release) - Go live

---

## Immediate Actions

### 1. Make Scripts Executable (Unix/macOS/Linux)

```bash
chmod +x scripts/bump_version.sh
chmod +x scripts/build_production.sh
chmod +x scripts/setup_github_secrets.sh
```

**Windows users:** Scripts work as-is with Git Bash or WSL.

### 2. Test Local Build

Verify everything works locally first:

```bash
# Run the build script
./scripts/build_production.sh both

# This will:
# - Clean previous builds
# - Install dependencies
# - Generate code
# - Run tests
# - Build AAB and APK
```

**Expected result:** Both AAB and APK files created in `build/app/outputs/`.

**If build fails:** See [Local Build Testing Guide](./LOCAL_BUILD_TESTING.md) for troubleshooting.

### 3. Verify Signing

```bash
# Check keystore validity
keytool -list -v -keystore android/keystore/otogapo-release.jks -storepass chachielex

# Verify AAB signature
jarsigner -verify -verbose -certs build/app/outputs/bundle/productionRelease/app-production-release.aab
```

**Expected result:** Certificate should show:

- Owner: CN=Otogapo Release, OU=Engineering, O=DigitApp Studio
- Valid until: 2125

---

## Play Store Setup

### 1. Create Google Play Developer Account

**Cost:** $25 one-time fee

**Steps:**

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign up for developer account
3. Pay registration fee
4. Complete developer profile

**Time required:** 24-48 hours for account approval

### 2. Create Privacy Policy

**Required for Play Store submission**

**Quick options:**

**Option A:** Use our template

1. Open `docs/PRIVACY_POLICY_TEMPLATE.md`
2. Replace all [placeholders]
3. Host on your website or GitHub Pages

**Option B:** Use a generator

1. Use [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
2. Fill in your app details
3. Download and host

**Result:** You need a publicly accessible URL (e.g., `https://yoursite.com/privacy`)

### 3. Create Play Store Assets

**Required assets:**

#### App Icon

- **Status:** ✓ Already configured
- Location: `android/app/src/main/res/mipmap-*/`

#### Feature Graphic (Required)

- **Size:** 1024 x 500 pixels
- **Format:** PNG or JPG (no transparency)
- **Content:** App name + key visual

**Create with:**

- Canva (easiest, templates available)
- Figma
- Photoshop/GIMP

#### Screenshots (Required - minimum 2)

- **Size:** 1080 x 1920 or 1440 x 2560 pixels
- **Quantity:** 2-8 screenshots
- **Recommended screens:**
  1. Login/Splash screen
  2. Main dashboard
  3. Profile page
  4. Payment tracking
  5. Admin dashboard
  6. Announcements

**How to capture:**

```bash
# Run app on device
flutter run --flavor production --target lib/main_production.dart

# Take screenshots using device
# Or use Android Studio's screenshot tool
```

**Tip:** Add device frames using [Device Frames](https://deviceframes.com/) or [Mockuphone](https://mockuphone.com/)

### 4. Create App in Play Console

Follow the detailed guide: [Play Store Setup Guide](./PLAY_STORE_SETUP.md)

**Quick steps:**

1. Click "Create app"
2. Fill in app name: "Otogapo"
3. Select "App" and "Free"
4. Accept declarations
5. Complete store listing
6. Upload assets
7. Complete content rating
8. Fill data safety section
9. Select countries

**Time required:** 1-2 hours for first-time setup

---

## GitHub Configuration

### 1. Prepare Secrets

Run the helper script:

```bash
./scripts/setup_github_secrets.sh
```

This will display all the values you need for GitHub Secrets.

### 2. Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each:

**Required secrets:**

| Secret Name                        | Value                   | Where to get it            |
| ---------------------------------- | ----------------------- | -------------------------- |
| `ANDROID_KEYSTORE_BASE64`          | Base64 encoded keystore | From script output         |
| `ANDROID_KEYSTORE_PASSWORD`        | chachielex              | From your `key.properties` |
| `ANDROID_KEY_ALIAS`                | otogapo                 | From your `key.properties` |
| `ANDROID_KEY_PASSWORD`             | chachielex              | From your `key.properties` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | JSON key                | See below                  |

### 3. Set Up Play Store API Access

**Required for automated uploads**

#### Enable API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select project: "Otogapo"
3. Enable **Google Play Developer API**

#### Create Service Account

1. Go to **IAM & Admin** → **Service Accounts**
2. Click **Create Service Account**
3. Name: `otogapo-fastlane-deploy`
4. Click **Create and Continue**
5. Skip role assignment
6. Click **Done**

#### Create JSON Key

1. Click on service account
2. Go to **Keys** tab
3. Click **Add Key** → **Create new key**
4. Select **JSON**
5. Click **Create** (downloads JSON file)

#### Grant Play Console Access

1. Go to [Play Console](https://play.google.com/console)
2. **Settings** → **Developer account** → **API access**
3. Link Google Cloud project
4. Find service account, click **Grant access**
5. Grant permissions:
   - View app information
   - Manage releases
   - Manage store presence
6. Click **Invite user**
7. Accept invitation (check email)

#### Add to GitHub

1. Open the downloaded JSON file
2. Copy entire contents
3. Go to GitHub → Settings → Secrets
4. Create `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
5. Paste JSON contents
6. Click **Add secret**

**Complete guide:** [Play Store Setup - API Section](./PLAY_STORE_SETUP.md#google-play-console-api-setup)

---

## First Release

### 1. Install Fastlane

```bash
cd android
bundle install
```

**If bundle not found:**

```bash
gem install bundler
bundle install
```

### 2. Test Local Upload (Optional)

Build and test Fastlane:

```bash
# Build AAB
./scripts/build_production.sh appbundle

# Test upload to internal track (dry run if possible)
cd android
bundle exec fastlane internal
```

**Note:** This will actually upload to Play Store internal track. Only do this if you're ready!

### 3. Create First Release via GitHub Actions

**Recommended approach:**

```bash
# Ensure you're on main branch with latest changes
git checkout main
git pull origin main

# Version is currently 1.0.0+1, so tag it
git tag v1.0.0

# Push tag (triggers release workflow)
git push origin v1.0.0
```

**What happens automatically:**

1. GitHub Actions builds AAB/APK
2. Runs all tests
3. Creates GitHub Release
4. Uploads to Play Store internal track

**Monitor progress:**

- Go to your GitHub repository
- Click **Actions** tab
- Watch the "Release" workflow

**Time required:** 10-15 minutes for workflow to complete

### 4. Test Internal Track

1. Go to [Play Console](https://play.google.com/console)
2. Select your app
3. Navigate to **Release** → **Testing** → **Internal testing**
4. Verify upload succeeded
5. Add internal testers (email list)
6. Share test link with testers
7. Test thoroughly on internal track

**Internal testing:**

- Up to 100 testers
- No Google review required
- Changes available instantly
- Perfect for team testing

---

## Production Release

### 1. Gather Feedback

After internal testing:

- Fix any bugs found
- Make necessary improvements
- Test again on internal track

### 2. Promote to Alpha/Beta (Recommended)

```bash
cd android
bundle exec fastlane promote from:internal to:beta
```

Or use GitHub Actions:

- Go to **Actions** tab
- Select **Manual Deploy**
- Click **Run workflow**
- Choose "beta" track
- Click **Run workflow**

**Test beta with more users:**

- Closed testing track
- Unlimited testers
- No review required
- Get broader feedback

### 3. Finalize Store Listing

Before production release:

- [ ] All screenshots uploaded
- [ ] Feature graphic uploaded
- [ ] Short description finalized
- [ ] Full description finalized
- [ ] Privacy policy URL added
- [ ] Content rating completed
- [ ] Data safety section completed
- [ ] App category set
- [ ] Countries selected

### 4. Submit for Review

**Option A: Via Play Console**

1. Go to **Production** track
2. Create new release
3. Upload AAB (or promote from beta)
4. Add release notes
5. Review and rollout
6. Submit for review

**Option B: Via GitHub Actions**

```bash
# Go to Actions → Manual Deploy
# Select "production" track
# Run workflow
```

**Google review time:** 24-48 hours (typically)

### 5. Staged Rollout

**Highly recommended for first production release:**

1. Start with 5% of users
2. Monitor for 24-48 hours:
   - Crash rates
   - User reviews
   - Performance metrics
3. If all good, increase to 20%
4. Monitor again
5. Increase to 50%
6. Finally 100%

**How to set up:**

- In Play Console production release
- Select "Staged rollout"
- Set percentage

---

## Post-Release

### 1. Monitor

**First 48 hours are critical:**

- [ ] Check crash reports (Play Console)
- [ ] Monitor user reviews
- [ ] Track installation rates
- [ ] Check performance metrics
- [ ] Review analytics

### 2. Respond to Reviews

- Respond to user feedback promptly
- Address concerns
- Thank positive reviews
- Fix reported issues

### 3. Plan Updates

- Regular updates keep users engaged
- Fix bugs promptly
- Add requested features
- Keep dependencies updated

---

## Future Releases

For subsequent releases, the process is simpler:

### Quick Release Process

```bash
# 1. Make changes on feature branch
git checkout -b feature/new-feature
# ... make changes ...
git commit -am "feat: add new feature"
git push origin feature/new-feature

# 2. Create PR, get reviewed, merge to main

# 3. Bump version
./scripts/bump_version.sh minor  # or patch/major

# 4. Update CHANGELOG.md

# 5. Commit and tag
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.1.0"
git push origin main
git tag v1.1.0
git push origin v1.1.0

# 6. GitHub Actions does the rest!
```

---

## Troubleshooting

### Build Fails

**Check:**

- Keystore exists and is valid
- `key.properties` is correct
- All dependencies installed
- No lint errors

**Solution:** See [Local Build Testing](./LOCAL_BUILD_TESTING.md)

### GitHub Actions Fails

**Check:**

- All GitHub Secrets configured correctly
- Secrets are not expired
- Workflow file syntax is correct

**Solution:** Check Actions logs for specific error

### Upload to Play Store Fails

**Common causes:**

- Service account permissions incorrect
- API not enabled
- Version code already exists
- JSON key expired

**Solution:** See [Play Store Setup](./PLAY_STORE_SETUP.md#troubleshooting)

### App Rejected by Google

**Common reasons:**

- Missing privacy policy
- Data safety info incomplete
- Content rating not done
- Policy violations

**Solution:** Read rejection email carefully, fix issues, resubmit

---

## Checklist Summary

### Before First Release

- [ ] Local build successful
- [ ] Signing verified
- [ ] Google Play Developer account created
- [ ] Privacy policy published
- [ ] Play Store assets created
- [ ] App created in Play Console
- [ ] GitHub Secrets configured
- [ ] Fastlane installed and tested
- [ ] Internal track tested

### Before Production

- [ ] Internal testing completed
- [ ] Beta testing completed (recommended)
- [ ] All store listing complete
- [ ] Reviews and feedback addressed
- [ ] Documentation updated
- [ ] Support resources ready

---

## Support and Resources

### Documentation

- [Deployment Guide](./DEPLOYMENT.md) - Complete CI/CD documentation
- [Release Checklist](./RELEASE_CHECKLIST.md) - Detailed checklist
- [Play Store Setup](./PLAY_STORE_SETUP.md) - Console configuration
- [Local Build Testing](./LOCAL_BUILD_TESTING.md) - Build verification
- [Developer Guide](./DEVELOPER_GUIDE.md) - Development workflows

### External Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions](https://docs.github.com/en/actions)

### Need Help?

- Check documentation first
- Review GitHub Actions logs
- Check Play Console help
- Create issue in repository

---

## Timeline Estimate

**Setup (First time):**

- Google Play account: 24-48 hours (approval)
- Create assets: 2-4 hours
- Play Store setup: 1-2 hours
- GitHub configuration: 30 minutes
- Total: ~2-3 days

**First Release:**

- Internal testing: 1-3 days
- Beta testing: 1-2 weeks (recommended)
- Google review: 1-2 days
- Total: ~2-3 weeks for safe rollout

**Future Releases:**

- Development: varies
- Release process: 15 minutes (automated)
- Review: 1-2 days
- Total: 1-3 days per update

---

**Congratulations!** You're ready to release Otogapo to the Google Play Store! 🎉

Start with the [Immediate Actions](#immediate-actions) section and work through each step methodically.

**Last Updated:** 2025-10-11  
**Version:** 1.0
