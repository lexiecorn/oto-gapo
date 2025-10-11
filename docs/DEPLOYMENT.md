# Deployment Guide - OtoGapo

## Overview

This guide covers the deployment process for the OtoGapo Flutter application across different platforms and environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Firebase Configuration](#firebase-configuration)
- [PocketBase Configuration](#pocketbase-configuration)
- [Android Deployment](#android-deployment)
- [iOS Deployment](#ios-deployment)
- [Web Deployment](#web-deployment)
- [Windows Deployment](#windows-deployment)
- [Environment Variables](#environment-variables)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Analytics](#monitoring-and-analytics)

## Prerequisites

### Development Environment

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.3.0)
- Android Studio / VS Code
- Xcode (for iOS development)
- Git

### Platform-specific Requirements

#### Android

- Android SDK
- Java Development Kit (JDK)
- Android signing keys

#### iOS

- Xcode
- iOS Developer Account
- Provisioning profiles
- Code signing certificates

#### Web

- Web server (Apache, Nginx, etc.)
- HTTPS certificate

#### Windows

- Visual Studio with C++ tools
- Windows 10 SDK

## Environment Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd oto-gapo
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configure Flavors

Update flavor-specific configurations in:

- `lib/main_development.dart`
- `lib/main_staging.dart`
- `lib/main_production.dart`

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Enable Authentication and Firestore

### 2. Configure Authentication

1. Enable Email/Password authentication
2. Enable Google Sign-In
3. Configure OAuth consent screen

### 3. Generate Configuration Files

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure project
firebase use --add

# Generate configuration files
flutterfire configure
```

### 4. Update Configuration Files

Ensure the following files are updated:

- `lib/firebase_options_dev.dart`
- `lib/firebase_options_prod.dart`

## PocketBase Configuration

### 1. Set Up PocketBase Instance

1. Deploy PocketBase server
2. Configure collections:
   - `users`
   - `monthly_dues`
   - `Announcements`
   - `app_data`

### 2. Configure Collections Schema

#### Users Collection

```json
{
  "name": "users",
  "type": "auth",
  "schema": [
    {
      "name": "firebaseUid",
      "type": "text",
      "required": true
    },
    {
      "name": "firstName",
      "type": "text",
      "required": true
    },
    {
      "name": "lastName",
      "type": "text",
      "required": true
    },
    {
      "name": "membership_type",
      "type": "number",
      "required": true
    }
  ]
}
```

#### Monthly Dues Collection

```json
{
  "name": "monthly_dues",
  "schema": [
    {
      "name": "user",
      "type": "relation",
      "collectionId": "users",
      "required": true
    },
    {
      "name": "due_for_month",
      "type": "date",
      "required": true
    },
    {
      "name": "amount",
      "type": "number",
      "required": true
    },
    {
      "name": "status",
      "type": "text",
      "required": true
    }
  ]
}
```

### 3. Update PocketBase URLs

Update the PocketBase URL in each flavor configuration:

```dart
FlavorConfig(
  name: 'PROD',
  variables: {
    'pocketbaseUrl': 'https://your-pocketbase-instance.com',
  },
);
```

## Android Deployment

### 1. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore/otogapo-release.jks
```

### 2. Build Release APK

```bash
# Development
flutter build apk --debug --target lib/main_development.dart --flavor development

# Staging
flutter build apk --release --target lib/main_staging.dart --flavor staging

# Production
flutter build apk --release --target lib/main_production.dart --flavor production
```

### 3. Build App Bundle (Recommended)

```bash
# Production
flutter build appbundle --release --target lib/main_production.dart --flavor production
```

### 4. Deploy to Google Play Store

1. Upload AAB file to Google Play Console
2. Fill in store listing information
3. Configure app content and pricing
4. Submit for review

## iOS Deployment

### 1. Configure Signing

1. Open project in Xcode
2. Select development team
3. Configure bundle identifier
4. Set up provisioning profiles

### 2. Build for Release

```bash
# Production
flutter build ios --release --target lib/main_production.dart --flavor production
```

### 3. Archive in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect

### 4. Deploy to App Store

1. Submit for App Store review
2. Configure app information
3. Set up pricing and availability
4. Release to App Store

## Web Deployment

For comprehensive web deployment instructions, including Firebase Hosting, GitHub Pages, and custom hosting options, see the **[Web Deployment Guide](./WEB_DEPLOYMENT.md)**.

### Quick Start

#### Local Development

```bash
# Run web version locally
flutter run -d web-server --target lib/main_development.dart --web-port 8080

# Access at: http://localhost:8080
```

#### Production Build

```bash
# Build production web app
flutter build web --release --target lib/main_production.dart --base-href /

# Output: build/web/
```

#### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase hosting (one-time)
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### Automated Deployment

Web deployment is automated through GitHub Actions:

1. **Automatic on push to main**: Deploys to Firebase Hosting
2. **Manual trigger**: Choose environment and hosting provider
3. **Release tags**: Web build included in GitHub releases

See [Web Deployment Guide](./WEB_DEPLOYMENT.md) for detailed instructions.

## Windows Deployment

### 1. Build for Windows

```bash
# Production
flutter build windows --release --target lib/main_production.dart --flavor production
```

### 2. Create Installer

Use tools like:

- Inno Setup
- NSIS
- MSI installer

### 3. Distribute

- Microsoft Store
- Direct download
- Enterprise distribution

## Environment Variables

### Development Environment

```bash
export FLUTTER_ENV=development
export POCKETBASE_URL=https://dev.pocketbase.com
export FIREBASE_PROJECT_ID=otogapo-dev
```

### Staging Environment

```bash
export FLUTTER_ENV=staging
export POCKETBASE_URL=https://staging.pocketbase.com
export FIREBASE_PROJECT_ID=otogapo-staging
```

### Production Environment

```bash
export FLUTTER_ENV=production
export POCKETBASE_URL=https://prod.pocketbase.com
export FIREBASE_PROJECT_ID=otogapo-prod
```

## CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.3.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release --target lib/main_production.dart --flavor production

      - name: Build Web
        run: flutter build web --release --target lib/main_production.dart --flavor production

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          channelId: live
          projectId: otogapo-prod
```

### Build Scripts

```bash
#!/bin/bash
# build.sh

set -e

FLAVOR=${1:-production}
TARGET=${2:-all}

echo "Building for $FLAVOR flavor..."

case $TARGET in
  android)
    flutter build apk --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    ;;
  ios)
    flutter build ios --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    ;;
  web)
    flutter build web --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    ;;
  windows)
    flutter build windows --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    ;;
  all)
    flutter build apk --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    flutter build web --release --target lib/main_$FLAVOR.dart --flavor $FLAVOR
    ;;
esac

echo "Build completed successfully!"
```

## Monitoring and Analytics

### 1. Firebase Analytics

```dart
// Initialize Firebase Analytics
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Track custom events
await FirebaseAnalytics.instance.logEvent(
  name: 'user_signup',
  parameters: {
    'method': 'email',
    'membership_type': '3',
  },
);
```

### 2. Crash Reporting

```dart
// Initialize Crashlytics
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Report errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'User authentication failed',
);
```

### 3. Performance Monitoring

```dart
// Initialize Performance Monitoring
final perf = FirebasePerformance.instance;
final trace = perf.newTrace('user_login');
await trace.start();

// Your login logic here

await trace.stop();
```

### 4. Custom Monitoring

```dart
class AppMonitoring {
  static Future<void> logUserAction(String action, Map<String, dynamic> data) async {
    // Send to custom analytics service
    await _sendToAnalytics(action, data);
  }

  static Future<void> logError(String error, StackTrace stackTrace) async {
    // Log to custom error tracking
    await _sendToErrorTracking(error, stackTrace);
  }
}
```

## Security Considerations

### 1. API Keys and Secrets

- Never commit API keys to version control
- Use environment variables for sensitive data
- Implement key rotation policies

### 2. Data Encryption

- Encrypt sensitive data in transit and at rest
- Use secure communication protocols (HTTPS)
- Implement proper authentication and authorization

### 3. Code Signing

- Use strong code signing certificates
- Protect signing keys securely
- Implement certificate expiration monitoring

### 4. App Store Security

- Follow platform security guidelines
- Implement proper permission handling
- Regular security audits and updates

## Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### Signing Issues (Android)

```bash
# Verify keystore
keytool -list -v -keystore android/keystore/otogapo-release.jks
```

#### iOS Code Signing

1. Check provisioning profiles in Xcode
2. Verify bundle identifier matches
3. Ensure certificates are valid

#### Web Deployment Issues

```bash
# Check base href in index.html
# Verify web server configuration
# Check console for JavaScript errors
```

### Debug Commands

```bash
# Check Flutter installation
flutter doctor -v

# Verify dependencies
flutter pub deps

# Analyze code
flutter analyze

# Run tests
flutter test --coverage
```

## Maintenance

### 1. Regular Updates

- Update Flutter SDK regularly
- Keep dependencies up to date
- Monitor for security vulnerabilities

### 2. Performance Monitoring

- Monitor app performance metrics
- Track user engagement
- Analyze crash reports

### 3. Backup Strategy

- Regular database backups
- Version control for all code
- Document deployment procedures

### 4. Rollback Plan

- Maintain previous app versions
- Database migration rollback procedures
- Emergency contact information

This deployment guide provides comprehensive instructions for deploying the OtoGapo application across all supported platforms while maintaining security, performance, and reliability standards.

---

## Automated CI/CD Pipeline

### Overview

The Otogapo project uses GitHub Actions for continuous integration and automated deployments to the Google Play Store via Fastlane.

### GitHub Actions Workflows

#### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:** Push to main/develop/feature branches, pull requests

**Jobs:**

- Code formatting verification
- Static analysis with Flutter Analyzer
- Code generation
- Unit and widget tests with coverage
- Build verification for all flavors (development, staging)
- Production build matrix (Android APK & Web)

**Artifacts:** Production APK files (7-day retention)

**Platforms Tested:** Android and Web builds are verified on every push

#### 2. Release Workflow (`.github/workflows/release.yml`)

**Triggers:** Git tags matching `v*.*.*` (e.g., `v1.0.0`)

**Jobs:**

- Run full test suite
- Decode signing keystore from GitHub Secrets
- Build signed Android AAB and APK
- Build production web application
- Create web archive (ZIP)
- Generate changelog from commits
- Create GitHub Release with all artifacts (AAB, APK, Web ZIP)
- Upload Android AAB to Play Store (internal track)

**Artifacts Included:**

- `app-production-release.aab` - Android App Bundle
- `app-production-release.apk` - Android APK
- `otogapo-web-v*.*.*.zip` - Web application archive

**Usage:**

```bash
# Create and push a release tag
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# 1. Build Android and Web releases
# 2. Create GitHub Release with all artifacts
# 3. Upload Android AAB to Play Store internal track
# 4. Attach web build to GitHub release for manual deployment
```

#### 3. Manual Deploy Workflow (`.github/workflows/deploy.yml`)

**Triggers:** Manual trigger via GitHub Actions UI

**Parameters:**

- `track`: internal, alpha, beta, or production
- `version_bump`: major, minor, patch, or none

**Jobs:**

- Optional version bump
- Run tests
- Build signed AAB
- Deploy to specified Play Store track
- Commit version changes

**Usage:**

1. Go to GitHub Actions tab
2. Select "Manual Deploy" workflow
3. Click "Run workflow"
4. Choose track and version bump type
5. Click "Run workflow"

#### 4. Manual Build Workflow (`.github/workflows/manual_build.yml`)

**Triggers:** Manual trigger via GitHub Actions UI

**Parameters:**

- `flavor`: development, staging, or production
- `build_type`: apk, appbundle, or both

**Jobs:**

- Build specified flavor and type
- Upload artifacts (14-day retention)

**Usage:** On-demand builds for testing or distribution

#### 5. Web Deploy Workflow (`.github/workflows/web-deploy.yml`)

**Triggers:**

- Manual trigger via GitHub Actions UI
- Automatic on push to main (when web/lib files change)

**Parameters:**

- `environment`: development, staging, or production
- `hosting_provider`: firebase, github-pages, or artifacts-only

**Jobs:**

- Build web application for specified environment
- Create deployment info JSON
- Upload build artifacts (30-day retention)
- Deploy to Firebase Hosting (if selected)
- Deploy to GitHub Pages (if selected)
- Notify deployment status

**Usage:**

1. Manual deployment via GitHub Actions UI:
   - Go to Actions → Deploy Web → Run workflow
   - Choose environment and hosting provider
2. Automatic deployment:
   - Push changes to main branch
   - Automatically deploys to Firebase (if configured)

**Artifacts:**

- `web-build-{environment}-{commit-sha}` - Web build files
- `deployment-info.json` - Build metadata (version, date, commit)

**See:** [Web Deployment Guide](./WEB_DEPLOYMENT.md) for detailed setup

### Fastlane Integration

#### Installation

```bash
cd android
bundle install
```

#### Available Lanes

**Deploy to Internal Track:**

```bash
bundle exec fastlane internal
```

**Deploy to Alpha Track:**

```bash
bundle exec fastlane alpha
```

**Deploy to Beta Track:**

```bash
bundle exec fastlane beta
```

**Deploy to Production:**

```bash
bundle exec fastlane production
```

**Deploy to Specific Track:**

```bash
bundle exec fastlane deploy track:beta
```

**Promote Between Tracks:**

```bash
bundle exec fastlane promote from:beta to:production
```

**Upload Metadata Only:**

```bash
bundle exec fastlane metadata
```

#### Metadata Management

Store listing metadata is version-controlled in:

```
android/fastlane/metadata/android/
├── en-US/
│   ├── title.txt
│   ├── short_description.txt
│   ├── full_description.txt
│   ├── changelogs/
│   │   └── 1.txt
│   ├── images/
│   │   ├── featureGraphic.png
│   │   ├── icon.png
│   │   └── phoneScreenshots/
│   └── video.txt
```

### GitHub Secrets Configuration

Required secrets for CI/CD:

1. **ANDROID_KEYSTORE_BASE64**

   - Base64-encoded keystore file
   - Generate with: `base64 -w 0 android/keystore/otogapo-release.jks`

2. **ANDROID_KEYSTORE_PASSWORD**

   - Store password from `key.properties`

3. **ANDROID_KEY_ALIAS**

   - Key alias from `key.properties`

4. **ANDROID_KEY_PASSWORD**

   - Key password from `key.properties`

5. **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON**
   - Service account JSON key from Google Cloud Console
   - See [Play Store Setup Guide](./PLAY_STORE_SETUP.md) for details

**Setup Helper Script:**

```bash
./scripts/setup_github_secrets.sh
```

This script will display the values needed for GitHub Secrets.

### Version Management

#### Automated Version Bumping

**Script:** `scripts/bump_version.sh`

**Usage:**

```bash
# Bump patch version (1.0.0 -> 1.0.1)
./scripts/bump_version.sh patch

# Bump minor version (1.0.1 -> 1.1.0)
./scripts/bump_version.sh minor

# Bump major version (1.1.0 -> 2.0.0)
./scripts/bump_version.sh major
```

**What it does:**

- Updates version in `pubspec.yaml`
- Increments build number automatically
- Validates the change
- Colorized output

#### Manual Version Update

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        │ │ │  └─ Build number (increment each build)
#        │ │ └──── Patch version
#        │ └────── Minor version
#        └──────── Major version
```

### Production Build Script

**Script:** `scripts/build_production.sh`

**Usage:**

```bash
# Build both AAB and APK
./scripts/build_production.sh both

# Build only AAB
./scripts/build_production.sh appbundle

# Build only APK
./scripts/build_production.sh apk
```

**Features:**

- Verifies keystore and configuration
- Cleans previous builds
- Installs dependencies
- Generates code
- Runs tests before building
- Colorized output with progress
- Build artifact locations displayed

### Deployment Workflow

#### Standard Release Process

1. **Development & Testing**

   ```bash
   # Make changes, commit to feature branch
   git checkout -b feature/new-feature
   git commit -am "feat: add new feature"
   git push origin feature/new-feature

   # CI runs automatically on push
   # Create PR, CI runs on PR
   ```

2. **Merge to Main**

   ```bash
   # After PR approval and CI passes
   git checkout main
   git merge feature/new-feature
   git push origin main
   ```

3. **Create Release**

   ```bash
   # Bump version
   ./scripts/bump_version.sh minor

   # Update CHANGELOG.md
   # Commit version bump
   git commit -am "chore: bump version to 1.1.0"
   git push origin main

   # Create and push tag
   git tag v1.1.0
   git push origin v1.1.0

   # Release workflow triggers automatically:
   # - Builds Android AAB/APK
   # - Builds Web application
   # - Creates GitHub Release with all artifacts
   # - Uploads Android to Play Store internal track
   # - Attaches Web ZIP for manual deployment
   ```

4. **Testing & Promotion**

   ```bash
   # Test on internal track
   # When ready, promote to beta:
   cd android
   bundle exec fastlane promote from:internal to:beta

   # Test on beta track
   # When ready, promote to production:
   bundle exec fastlane promote from:beta to:production
   ```

#### Hotfix Process

1. **Create Hotfix Branch**

   ```bash
   git checkout -b hotfix/critical-fix main
   # Make minimal fix
   git commit -am "fix: critical bug"
   ```

2. **Test & Deploy**

   ```bash
   # Bump patch version
   ./scripts/bump_version.sh patch

   # Push and tag
   git push origin hotfix/critical-fix
   git tag v1.0.1
   git push origin v1.0.1

   # Release workflow deploys automatically
   ```

3. **Merge Back**
   ```bash
   git checkout main
   git merge hotfix/critical-fix
   git push origin main
   ```

### Monitoring and Rollback

#### Monitoring

**GitHub Actions:**

- Monitor workflow runs in Actions tab
- Check build logs for errors
- Review test results

**Play Store Console:**

- Monitor crash rates
- Check user reviews
- Review performance metrics
- Track rollout percentage

**Firebase (if configured):**

- Crashlytics for crash reports
- Analytics for user metrics
- Performance monitoring

#### Rollback Procedure

**Option 1: Play Store Console (Immediate)**

1. Open Play Console
2. Navigate to Release → Production
3. Click "Halt rollout" to pause
4. Promote previous version if needed

**Option 2: New Release**

```bash
# Revert to previous version
git revert <bad-commit>
./scripts/bump_version.sh patch
git tag v1.0.2
git push origin v1.0.2
```

### Best Practices

#### Android Deployment

1. **Always test on internal track first**
2. **Use staged rollouts for production** (5% → 20% → 50% → 100%)
3. **Monitor crash rates after each rollout increase**
4. **Test rollback procedures periodically**

#### Web Deployment

1. **Test on staging environment before production**
2. **Use Firebase Hosting channels** for preview deployments
3. **Test on multiple browsers** (Chrome, Firefox, Safari, Edge)
4. **Monitor bundle size** with each release
5. **Keep previous builds archived** for rollback

#### General Best Practices

1. **Keep CHANGELOG.md updated** with all changes
2. **Tag releases consistently** using v1.0.0 format
3. **Never commit keystore or passwords** (use GitHub Secrets)
4. **Review generated changelog before releases**
5. **Build and test both platforms** (Android and Web) before release
6. **Document configuration changes** in deployment docs
7. **Set up monitoring and analytics** for all platforms
8. **Maintain separate environments** (dev, staging, production)

### Troubleshooting CI/CD

#### Build Fails with Keystore Error

**Cause:** GitHub Secrets not configured or incorrect

**Solution:**

1. Run `./scripts/setup_github_secrets.sh`
2. Update GitHub Secrets with correct values
3. Verify secret names match workflow files

#### Fastlane Upload Fails

**Cause:** Service account permissions issue

**Solution:**

1. Verify Google Play Console API is enabled
2. Check service account has correct permissions
3. Regenerate JSON key if needed
4. Update `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret

#### Version Conflict on Upload

**Cause:** Version code already exists on Play Store

**Solution:**

1. Increment version in `pubspec.yaml`
2. Build number must be higher than any previous upload
3. Commit and re-deploy

#### Workflow Doesn't Trigger

**Cause:** Tag format incorrect or workflow file error

**Solution:**

1. Verify tag matches pattern `v*.*.*`
2. Check workflow YAML syntax
3. Ensure workflows are enabled in repository settings

### Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Play Console API Guide](https://developers.google.com/android-publisher)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Web Deployment Guide](./WEB_DEPLOYMENT.md)
- [Release Checklist](./RELEASE_CHECKLIST.md)
- [Play Store Setup Guide](./PLAY_STORE_SETUP.md)
