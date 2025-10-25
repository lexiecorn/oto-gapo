# R8 Obfuscation Setup Guide

This guide explains how to enable R8 code shrinking and obfuscation for the Android app, which reduces app size and improves security.

## Overview

R8 is Google's code shrinking and obfuscation tool that:

- Reduces app size by removing unused code
- Obfuscates code to make reverse engineering harder
- Optimizes code for better performance

## Current Configuration

### Build Configuration

R8 obfuscation is enabled in `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true  // Enable R8 code shrinking and obfuscation
        isShrinkResources = true  // Enable resource shrinking
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### ProGuard Rules

ProGuard rules are defined in `android/app/proguard-rules.pro`. These rules keep necessary classes from being obfuscated or removed.

## Building with Obfuscation

### Local Build

To build with obfuscation enabled:

```bash
# Build App Bundle
flutter build appbundle \
  --release \
  --target lib/main_production.dart \
  --flavor production

# Build APK
flutter build apk \
  --release \
  --target lib/main_production.dart \
  --flavor production
```

### CI/CD Build

Codemagic automatically enables obfuscation for production builds:

```yaml
- name: Build Android App Bundle (AAB)
  script: |
    flutter build appbundle \
      --release \
      --target lib/main_production.dart \
      --flavor production \
      --no-tree-shake-icons -v
```

## Mapping File (Deobfuscation)

When R8 obfuscates code, it generates a `mapping.txt` file that maps obfuscated names back to original names. This file is required for reading stack traces from crash reports.

### Mapping File Location

The mapping file is typically located at:

- `android/app/build/outputs/mapping/productionRelease/mapping.txt`
- `build/app/outputs/mapping/productionRelease/mapping.txt`

### Uploading Mapping File

The mapping file is automatically uploaded with the app bundle to Google Play Console via Fastlane:

```ruby
# android/fastlane/Fastfile
mapping_file = File.exist?('../android/app/build/outputs/mapping/productionRelease/mapping.txt') ?
  '../android/app/build/outputs/mapping/productionRelease/mapping.txt' :
  '../build/app/outputs/mapping/productionRelease/mapping.txt'

upload_params[:mapping] = mapping_file if File.exist?(mapping_file)
upload_to_play_store(upload_params)
```

### Benefits of Uploading Mapping File

1. **Readable Crash Reports**: Crash reports in Firebase Crashlytics will show original class and method names
2. **Faster Debugging**: No need to manually deobfuscate stack traces
3. **Better Analytics**: Google Play Console can provide more meaningful crash analytics

## Verifying Obfuscation

### Check Build Output

After building, you should see references to R8 in the build output:

```
> Task :app:minifyProductionRelease
> Task :app:shrinkProductionReleaseResources
```

### Check APK/AAB Size

Obfuscated builds are typically 10-30% smaller than non-obfuscated builds.

### Check Classes in APK

You can inspect the built APK to verify obfuscation:

```bash
# Decompile APK
unzip build/app/outputs/flutter-apk/app-production-release.apk -d unpacked

# Check if classes are obfuscated (should see short names like 'a', 'b', 'c')
find unpacked -name "*.dex" -exec strings {} \; | grep -E "^[abc]$"
```

## Troubleshooting

### App Crashes After Building

If the app crashes after enabling obfuscation, you may need to add ProGuard rules to keep certain classes:

```proguard
# Add to proguard-rules.pro
-keep class com.your.package.ClassName { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
```

### Missing Classes

If classes are being removed incorrectly, add keep rules:

```proguard
-keep class com.your.package.** { *; }
-dontwarn com.your.package.**
```

### Performance Issues

If the build takes too long, you can disable resource shrinking:

```kotlin
isShrinkResources = false
```

## Best Practices

1. **Always Keep Mapping Files**: Store mapping files securely for each release
2. **Test Thoroughly**: Test obfuscated builds thoroughly before release
3. **Update ProGuard Rules**: Add rules as needed when adding new dependencies
4. **Monitor Crashes**: Watch for obfuscation-related crashes and add rules as needed

## Additional Resources

- [R8 Documentation](https://developer.android.com/studio/build/shrink-code)
- [ProGuard Rules Guide](https://www.guardsquare.com/manual/configuration/usage)
- [Android Code Shrinking](https://developer.android.com/studio/build/shrink-code)

