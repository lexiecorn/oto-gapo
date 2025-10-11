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

### 1. Build for Web

```bash
# Production
flutter build web --release --target lib/main_production.dart --flavor production
```

### 2. Deploy to Web Server

```bash
# Copy build files to web server
cp -r build/web/* /var/www/html/

# Configure web server (Nginx example)
server {
    listen 443 ssl;
    server_name your-domain.com;

    root /var/www/html;
    index index.html;

    # SSL configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    # Flutter web configuration
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 3. Configure Firebase Hosting (Alternative)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

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
