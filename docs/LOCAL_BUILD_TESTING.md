# Local Build Testing Guide

This guide walks you through testing production builds locally before deployment.

## Prerequisites

- [ ] Flutter SDK installed and configured
- [ ] Android Studio or VS Code with Flutter extensions
- [ ] Physical Android device or emulator
- [ ] Release keystore configured (`android/keystore/otogapo-release.jks`)
- [ ] `key.properties` file configured

## Pre-Build Checklist

### 1. Verify Environment

```bash
# Check Flutter installation
flutter doctor -v

# Verify all dependencies
flutter pub get

# Check for any issues
flutter analyze
```

### 2. Clean Previous Builds

```bash
# Clean build cache
flutter clean

# Remove generated files
rm -rf build/

# Get dependencies again
flutter pub get
```

### 3. Generate Code

```bash
# Generate required code
dart run build_runner build --delete-conflicting-outputs

# Verify no errors in generation
```

### 4. Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Check specific test suites
flutter test test/unit/
flutter test test/widget/
```

## Building for Production

### Option 1: Using Build Script (Recommended)

```bash
# Make script executable (first time only)
chmod +x scripts/build_production.sh

# Build both AAB and APK
./scripts/build_production.sh both

# Or build only AAB
./scripts/build_production.sh appbundle

# Or build only APK
./scripts/build_production.sh apk
```

### Option 2: Manual Build

#### Build App Bundle (AAB)

```bash
flutter build appbundle \
  --release \
  --target lib/main_production.dart \
  --flavor production
```

**Output:** `build/app/outputs/bundle/productionRelease/app-production-release.aab`

#### Build APK

```bash
flutter build apk \
  --release \
  --target lib/main_production.dart \
  --flavor production
```

**Output:** `build/app/outputs/flutter-apk/app-production-release.apk`

## Verifying the Build

### 1. Check Build Artifacts

```bash
# Verify AAB exists and check size
ls -lh build/app/outputs/bundle/productionRelease/app-production-release.aab

# Verify APK exists and check size
ls -lh build/app/outputs/flutter-apk/app-production-release.apk

# Typical sizes:
# APK: 20-50 MB (compressed)
# AAB: 15-40 MB (Google optimizes further)
```

### 2. Verify Signing

```bash
# For AAB
jarsigner -verify -verbose -certs build/app/outputs/bundle/productionRelease/app-production-release.aab

# For APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-production-release.apk

# Should show your certificate details:
# Owner: CN=Otogapo Release, OU=Engineering, O=DigitApp Studio...
# Valid from: Fri Oct 03 21:58:35 PST 2025 until: Sun Sep 09 21:58:35 PST 2125
```

### 3. Check Obfuscation Status

```bash
# Note: Obfuscation is currently disabled in android/app/build.gradle.kts
# This means no mapping file is generated. If you re-enable obfuscation:
# ls -lh build/app/outputs/mapping/productionRelease/mapping.txt

# When obfuscation is enabled, backup the mapping file for crash report deobfuscation
```

## Installing and Testing

### Install on Physical Device

#### Via ADB

```bash
# List connected devices
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-production-release.apk

# Or force reinstall
adb install -r build/app/outputs/flutter-apk/app-production-release.apk
```

#### Manual Installation

1. Transfer APK to device
2. Enable "Install from unknown sources" in Settings
3. Open APK file and install

### Test Checklist

#### Basic Functionality

- [ ] App launches successfully
- [ ] No crash on startup
- [ ] Splash screen displays correctly
- [ ] App icon is correct

#### Authentication

- [ ] Email/password login works
- [ ] Google Sign-In works
- [ ] Remember me functionality
- [ ] Logout works properly
- [ ] Session persistence across app restarts

#### Core Features

- [ ] User can view profile
- [ ] User can edit profile
- [ ] Profile photo upload works
- [ ] Vehicle details display correctly
- [ ] Payment history loads
- [ ] Announcements display
- [ ] Navigation between screens works

#### Admin Features (if admin account)

- [ ] Admin dashboard accessible
- [ ] User management works
- [ ] Payment oversight functions
- [ ] Create/edit announcements

#### Performance Testing

- [ ] App loads within acceptable time (< 3 seconds)
- [ ] Smooth scrolling and animations
- [ ] Images load properly
- [ ] No memory leaks during extended use
- [ ] Battery usage is reasonable

#### Network Testing

- [ ] Works with WiFi
- [ ] Works with mobile data
- [ ] Handles network disconnection gracefully
- [ ] Shows appropriate error messages
- [ ] Offline functionality (if applicable)

#### Edge Cases

- [ ] Handles empty states (no payments, no announcements)
- [ ] Validates input fields properly
- [ ] Shows appropriate error messages
- [ ] Handles API errors gracefully
- [ ] Works on different screen sizes

### Device Testing Matrix

Test on multiple devices if possible:

**Minimum Requirements:**

- [ ] Device with Android 5.0 (API 21)
- [ ] Different screen sizes (phone, tablet)
- [ ] Different Android versions

**Recommended:**

- [ ] Popular devices (Samsung, Xiaomi, etc.)
- [ ] Latest Android version
- [ ] Low-end device (test performance)
- [ ] High-end device (verify features)

## Performance Profiling

### Check App Size

```bash
# Analyze APK size
flutter build apk --analyze-size --target lib/main_production.dart --flavor production

# This will show size breakdown:
# - Dart code
# - Assets
# - Native libraries
# - Resources
```

### Run Performance Tests

```bash
# Profile build (use this for development profiling only)
flutter build apk --profile --target lib/main_production.dart --flavor production

# Install and run with profiling
flutter run --profile --target lib/main_production.dart --flavor production
```

### Check Memory Usage

Use Android Studio's Profiler or:

```bash
# Monitor app while running
adb shell dumpsys meminfo com.digitappstudio.otogapo
```

## Common Issues and Solutions

### Build Fails

**Issue:** Keystore not found

```bash
# Verify keystore exists
ls -lh android/keystore/otogapo-release.jks

# Check key.properties
cat android/key.properties
```

**Issue:** Signing configuration error

```bash
# Verify signing config in build.gradle.kts
# Ensure key.properties has correct paths
```

**Issue:** Out of memory during build

```bash
# Increase Gradle memory
# Edit android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
```

### Installation Fails

**Issue:** App not installed

```bash
# Uninstall existing version first
adb uninstall com.digitappstudio.otogapo

# Then install again
adb install build/app/outputs/flutter-apk/app-production-release.apk
```

**Issue:** INSTALL_FAILED_UPDATE_INCOMPATIBLE

- Uninstall old version manually
- Or use: `adb install -r` (reinstall)

### Runtime Issues

**Issue:** App crashes on startup

- Check logcat: `adb logcat | grep -i flutter`
- Verify ProGuard rules aren't too aggressive
- Check Firebase configuration

**Issue:** White screen or blank page

- Check asset loading
- Verify API endpoints are correct
- Check network permissions

**Issue:** Sign-in not working

- Verify Firebase configuration
- Check SHA-1 fingerprint matches Play Console
- Ensure API keys are correct
- Verify obfuscation settings (currently disabled in build.gradle.kts)

## Getting Debug Information

### View Logs

```bash
# Real-time logs
adb logcat | grep -i "flutter\|otogapo"

# Save logs to file
adb logcat > logs.txt

# Filter for errors only
adb logcat *:E
```

### Extract APK from Device

```bash
# Find package path
adb shell pm path com.digitappstudio.otogapo

# Pull APK
adb pull /data/app/com.digitappstudio.otogapo-xxx/base.apk otogapo-device.apk
```

## Pre-Release Checklist

Before uploading to Play Store:

### Build Quality

- [ ] Build completes without errors
- [ ] APK/AAB size is reasonable
- [ ] Signing verified
- [ ] Obfuscation status confirmed (currently disabled)

### Functional Testing

- [ ] All core features work
- [ ] No critical bugs
- [ ] UI looks correct on test devices
- [ ] Performance is acceptable

### Compliance

- [ ] Version number updated in pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] Privacy policy accessible
- [ ] Permissions justified and documented

### Documentation

- [ ] Release notes prepared
- [ ] Known issues documented
- [ ] Obfuscation status documented
- [ ] Build configuration documented

## Next Steps

After successful local testing:

1. **Tag Release**

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Automated Deployment**

   - GitHub Actions will build and deploy
   - Monitor the Actions tab

3. **Manual Upload** (if not using automation)

   - Go to Google Play Console
   - Upload AAB to internal testing track
   - Add release notes
   - Submit

4. **Post-Upload Testing**
   - Test via internal track
   - Verify with internal testers
   - Monitor crash reports

## Additional Resources

- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
- [Android App Bundles](https://developer.android.com/guide/app-bundle)
- [ProGuard in Flutter](https://docs.flutter.dev/deployment/android#shrinking-your-code-with-r8)
- [ADB Documentation](https://developer.android.com/studio/command-line/adb)

---

**Last Updated:** 2025-10-11  
**Version:** 1.0
