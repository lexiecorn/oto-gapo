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
  - [Docker Deployment (Self-Hosted)](#docker-deployment-self-hosted)
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
3. Enable Authentication, Firestore, and Crashlytics

### 2. Configure Authentication

1. Enable Email/Password authentication
2. Enable Google Sign-In
3. Configure OAuth consent screen

### 3. Configure Crashlytics

1. Enable Crashlytics in Firebase Console
2. Configure data collection settings
3. Set up crash alerts and notifications

### 4. Generate Configuration Files

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure project
firebase use --add

# Generate configuration files for each flavor
flutterfire configure --project=otogapo-dev --platforms=android,ios,web --out=lib/firebase_options_dev.dart
flutterfire configure --project=otogapo-dev --platforms=android,ios,web --out=lib/firebase_options_staging.dart
flutterfire configure --project=otogapo-prod --platforms=android,ios,web --out=lib/firebase_options_prod.dart
```

### 5. Update Configuration Files

Ensure the following files are updated:

- `lib/firebase_options_dev.dart`
- `lib/firebase_options_staging.dart`
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

### 1. 16 KB Page Size Support (Android 15+ Requirement)

**Required for Google Play Store compliance as of November 1, 2025**

Starting with Android 15, Google Play requires all apps to support 16 KB memory page sizes. This project is already configured with the necessary settings:

#### Configuration Details

**Gradle Properties** (`android/gradle.properties`):

```properties
# Enable 16 KB page size support for Android 15+
android.bundle.enableUncompressedNativeLibs=false
```

**Build Configuration** (`android/app/build.gradle.kts`):

```kotlin
android {
    // Use NDK version 27.0.12077973 or higher
    ndkVersion = "27.0.12077973"

    // Native library packaging with 16 KB alignment
    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}
```

#### What This Does

- **Proper Alignment**: Ensures native libraries are aligned to 16 KB page boundaries
- **Modern Packaging**: Uses current Android packaging standards (`useLegacyPackaging = false`)
- **Native Library Support**: NDK 27+ includes built-in support for 16 KB page alignment
- **Automatic Compression**: Gradle handles library compression and alignment automatically

#### Verification

To verify your app supports 16 KB page sizes:

1. **Build your app bundle**:

   ```bash
   flutter build appbundle --release --target lib/main_production.dart --flavor production
   ```

2. **Upload to Play Console**: The Play Console will automatically verify 16 KB support

3. **Check Release Dashboard**: Look for the "16 KB support" indicator on your app bundle

#### Testing in 16 KB Environment

For thorough testing, you can run your app on a device with 16 KB page sizes enabled. See [Testing 16 KB Support](#testing-16-kb-page-size-support) below for detailed instructions.

#### Additional Resources

- [Android 16 KB Page Size Guide](https://developer.android.com/guide/practices/page-alignment)
- [Google Play Requirements](https://support.google.com/googleplay/android-developer/answer/14710219)
- [Testing 16 KB Apps](https://developer.android.com/guide/practices/page-alignment#test)

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore/otogapo-release.jks
```

### 3. Build Release APK

```bash
# Development
flutter build apk --debug --target lib/main_development.dart --flavor development

# Staging
flutter build apk --release --target lib/main_staging.dart --flavor staging

# Production
flutter build apk --release --target lib/main_production.dart --flavor production
```

### 4. Build App Bundle (Recommended)

```bash
# Production
flutter build appbundle --release --target lib/main_production.dart --flavor production
```

### 5. Deploy to Google Play Store

1. Upload AAB file to Google Play Console
2. Fill in store listing information
3. Configure app content and pricing
4. Submit for review

### 6. Testing 16 KB Page Size Support

To ensure your app works correctly on devices with 16 KB page sizes, follow these testing instructions:

#### Option 1: Using Android Emulator (Recommended)

1. **Install Android SDK Platform Tools 35 or higher**:

   ```bash
   # Update SDK tools
   sdkmanager --update
   sdkmanager "platform-tools" "platforms;android-35"
   ```

2. **Create a 16 KB page size AVD**:

   ```bash
   # Create AVD with 16 KB page size support
   avdmanager create avd -n "Pixel_8_16KB" \
     -k "system-images;android-35;google_apis;x86_64" \
     -d "pixel_8" \
     -g "google_apis"

   # Edit AVD config to enable 16 KB pages
   echo "hw.ramSize=4096" >> ~/.android/avd/Pixel_8_16KB.avd/config.ini
   echo "hw.cpu.ncore=4" >> ~/.android/avd/Pixel_8_16KB.avd/config.ini
   ```

3. **Launch emulator with 16 KB page size**:

   ```bash
   # Start emulator with 16 KB page size
   emulator -avd Pixel_8_16KB -qemu -machine kernel-page-size=16k
   ```

4. **Run your app**:
   ```bash
   # Run production flavor on the emulator
   flutter run --release --target lib/main_production.dart --flavor production
   ```

#### Option 2: Using Physical Device

Some newer Android devices (Pixel 8 and newer with Android 15) support 16 KB page sizes natively:

1. **Enable 16 KB page sizes** (if supported by device):

   - This typically requires a device reboot with specific kernel parameters
   - Check your device manufacturer's documentation

2. **Verify page size**:

   ```bash
   adb shell getconf PAGE_SIZE
   # Should output: 16384
   ```

3. **Deploy and test**:
   ```bash
   flutter run --release --target lib/main_production.dart --flavor production
   ```

#### Option 3: Using Android Studio

1. **Open AVD Manager** in Android Studio
2. **Create New Virtual Device**
3. **Select a device** with Android 15 (API 35) or higher
4. **Select System Image** with API 35+
5. **Advanced Settings** → Emulated Performance → **Configure** → Add `-qemu -machine kernel-page-size=16k` to additional emulator command-line options
6. **Finish** and launch the AVD

#### What to Test

When testing with 16 KB page sizes, verify:

1. **App Launch**: App starts without crashes
2. **Core Functionality**: All features work as expected
3. **Native Libraries**: Camera, image picker, and other native features function correctly
4. **Memory Usage**: Monitor for memory-related crashes
5. **Performance**: Check for any performance degradation
6. **Firebase Services**: Authentication and Firestore operations work correctly
7. **Google Sign-In**: OAuth flow completes successfully
8. **PocketBase Integration**: API calls and data synchronization work

#### Common Issues and Solutions

**App crashes on startup**:

- Check that NDK version is 27.0.12077973 or higher
- Verify `useLegacyPackaging = false` in `build.gradle.kts`
- Rebuild the app: `flutter clean && flutter build appbundle`

**Native library errors**:

- Update Flutter to the latest stable version
- Update all Flutter plugins to their latest versions
- Check plugin compatibility with 16 KB page sizes

**Memory issues**:

- Monitor memory usage with Android Profiler
- Check for memory leaks in native code
- Verify proper resource cleanup

#### Verification Checklist

Before submitting to Play Store, ensure:

- [ ] App builds successfully with 16 KB configuration
- [ ] App runs without crashes on 16 KB emulator
- [ ] All core features tested and working
- [ ] Native plugins (camera, image picker) tested
- [ ] Firebase and PocketBase integration tested
- [ ] Memory profiling shows no issues
- [ ] No warnings or errors in logcat related to page size

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

#### Docker Deployment (Self-Hosted)

Deploy to your own Ubuntu server using Docker:

```bash
# Configure environment
cp env.template .env
nano .env  # Update DOMAIN and EMAIL

# Deploy
./scripts/deploy_docker.sh
```

This will:

- Build production Flutter web app
- Create Docker container with Nginx
- Set up SSL with Let's Encrypt
- Deploy to your domain (e.g., https://otogapo.lexserver.org)

**Features:**

- Automatic SSL certificate management
- Nginx reverse proxy with optimized configuration
- Portainer compatible for easy management
- Health checks and auto-restart

For detailed instructions, see **[Docker Deployment Guide](../DOCKER_DEPLOYMENT.md)**.

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
### 4. Microsoft Clarity (Mobile SDK)

Microsoft Clarity provides session replays and heatmaps for mobile apps.

Integration summary:

- Add dependency in `pubspec.yaml`:

  ```yaml
  dependencies:
    clarity_flutter: ^1.4.3
  ```

- Wrap the root `App` with Clarity in `lib/bootstrap.dart` via `ClarityHelper`:

  ```dart
  // lib/bootstrap.dart
  import 'package:otogapo/utils/clarity_helper.dart';
  // ... inside bootstrap after building the app widget
  final wrappedApp = ClarityHelper.wrapWithClarity(appWidget);
  runApp(wrappedApp);
  ```

- Provide the project ID per flavor by setting `FlavorConfig.variables['clarityProjectId']` (optional). If not set, Clarity is skipped.

- Set the user id after authentication (already wired in `AuthBloc`).

Notes:

- iOS native changes are not required when using the Flutter plugin.
- Use `ClarityMask` to hide sensitive widgets in recordings when needed.

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

The Otogapo project supports two CI/CD platforms:

1. **Codemagic** (Recommended) - Flutter-native platform with simplified Play Store deployment
2. **GitHub Actions** - Git-integrated CI/CD with Fastlane integration

Both platforms can coexist or be used independently. See [Codemagic Setup Guide](./CODEMAGIC_SETUP.md) for detailed instructions on the recommended platform.

---

## Codemagic CI/CD (Recommended)

### Why Codemagic?

Codemagic is a Flutter-native CI/CD platform that simplifies deployment:

- ✅ **GUI-based credential management** - Upload keystore and service account via UI
- ✅ **Built-in Play Store publishing** - No Fastlane configuration needed
- ✅ **Mac builds included** - iOS builds without owning a Mac
- ✅ **Flutter-optimized builds** - Faster builds with intelligent caching
- ✅ **Free tier**: 500 build minutes/month for personal projects

### Quick Start with Codemagic

1. **Sign up**: Visit [codemagic.io](https://codemagic.io) and sign in with GitHub
2. **Add repository**: Select `oto-gapo` from your repositories
3. **Upload keystore**: Settings → Code signing → Upload `android/keystore/otogapo-release.jks`
4. **Configure Play Store**: Teams → Integrations → Google Play → Upload service account JSON
5. **Test build**: Push a commit or create a tag `v1.0.0` to trigger builds

### Codemagic Workflows

The project includes `codemagic.yaml` with pre-configured workflows:

#### 1. android-ci (Continuous Integration)

**Triggers:** Push to any branch, pull requests  
**Actions:** Format check, analyze, test, build dev/staging APKs  
**Artifacts:** Development and staging APKs with coverage

#### 2. android-production (Production Release)

**Triggers:** Git tags matching `v*.*.*` (e.g., `v1.0.0`)  
**Actions:** Build signed AAB/APK, upload to Play Store internal track  
**Artifacts:** Android App Bundle, APK, ProGuard mapping

#### 3. web-production (Web Build)

**Triggers:** Git tags matching `v*.*.*`  
**Actions:** Build web app, create ZIP archive  
**Artifacts:** Web build files, deployment metadata

#### 4. web-firebase-deploy (Auto Web Deploy)

**Triggers:** Push to main branch  
**Actions:** Build and deploy to Firebase Hosting automatically  
**Artifacts:** Web build files

#### 5. manual-build (On-Demand Builds)

**Triggers:** Manual via Codemagic UI  
**Actions:** Build any flavor on demand for testing  
**Artifacts:** APK and AAB for selected flavor

### Usage Example

```bash
# Standard release with Codemagic
./scripts/bump_version.sh minor
git commit -am "chore: bump version to 1.1.0"
git push origin main

git tag v1.1.0
git push origin v1.1.0

# Codemagic automatically:
# 1. Builds signed Android AAB and APK
# 2. Uploads AAB to Play Store internal track (10% rollout)
# 3. Builds web application
# 4. Sends email notification
```

### Documentation

- **Setup Guide**: [CODEMAGIC_SETUP.md](./CODEMAGIC_SETUP.md) - Complete setup instructions
- **Migration Guide**: [CODEMAGIC_MIGRATION.md](./CODEMAGIC_MIGRATION.md) - Migrate from GitHub Actions

---

## GitHub Actions CI/CD (Alternative)

The Otogapo project also uses GitHub Actions for continuous integration and automated deployments to the Google Play Store via Fastlane.

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
3. **Never commit keystore or passwords** (use GitHub Secrets or Codemagic UI)
4. **Review generated changelog before releases**
5. **Build and test both platforms** (Android and Web) before release
6. **Document configuration changes** in deployment docs
7. **Set up monitoring and analytics** for all platforms
8. **Maintain separate environments** (dev, staging, production)

#### CI/CD Platform Selection

**Use Codemagic if:**

- ✅ You want simpler Play Store deployment
- ✅ You need iOS builds without a Mac
- ✅ You prefer GUI for credential management
- ✅ Build speed is critical
- ✅ You're within 500 min/month usage

**Use GitHub Actions if:**

- ✅ You need more than 500 min/month (private repos get 2,000 free)
- ✅ You prefer infrastructure-as-code
- ✅ You're already using GitHub heavily
- ✅ You need custom deployment targets
- ✅ You want everything in one place (code + CI/CD)

**Use Both if:**

- ✅ You want maximum redundancy
- ✅ You want to test Codemagic without disruption
- ✅ Different teams prefer different platforms
- ✅ You want GitHub Actions for CI, Codemagic for releases

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

#### CI/CD Documentation

- [Codemagic Setup Guide](./CODEMAGIC_SETUP.md) - Complete Codemagic setup instructions
- [Codemagic Migration Guide](./CODEMAGIC_MIGRATION.md) - Migrate from GitHub Actions
- [Codemagic Documentation](https://docs.codemagic.io/) - Official Codemagic docs
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fastlane Documentation](https://docs.fastlane.tools/)

#### Platform & Deployment Guides

- [Play Console API Guide](https://developers.google.com/android-publisher)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Web Deployment Guide](./WEB_DEPLOYMENT.md)
- [Release Checklist](./RELEASE_CHECKLIST.md)
- [Play Store Setup Guide](./PLAY_STORE_SETUP.md)
