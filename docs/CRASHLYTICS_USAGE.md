# Firebase Crashlytics Usage Guide

## Overview

Firebase Crashlytics has been integrated into the OtoGapo app to track crashes, errors, and performance issues across all flavors (DEV, STAGING, PROD).

## Features Implemented

### 1. Automatic Crash Reporting

- All uncaught Flutter errors are automatically reported to Crashlytics
- All uncaught asynchronous errors are automatically reported
- Fatal errors are marked appropriately for prioritization

### 2. Custom Error Logging

- Non-fatal errors can be logged manually using `CrashlyticsHelper.logError()`
- Custom messages can be logged using `CrashlyticsHelper.log()`
- Breadcrumbs can be recorded for debugging context

### 3. User Identification

- User IDs can be set for crash reports using `CrashlyticsHelper.setUserId()`
- Custom key-value pairs can be added for context using `CrashlyticsHelper.setCustomKey()`

### 4. Test Widget

- A test widget (`CrashlyticsTestButton`) is available in development/staging for testing Crashlytics functionality
- This widget is automatically hidden in production builds

## Usage Examples

### Logging Non-Fatal Errors

```dart
import 'package:otogapo/utils/crashlytics_helper.dart';

try {
  // Some operation that might fail
  await riskyOperation();
} catch (e, stackTrace) {
  // Log the error to Crashlytics
  await CrashlyticsHelper.logError(
    e,
    stackTrace,
    reason: 'Failed to perform risky operation',
  );

  // Handle the error gracefully
  showErrorToUser('Operation failed, please try again');
}
```

### Setting User Context

```dart
// When user logs in
await CrashlyticsHelper.setUserId(user.id);

// Add custom context
await CrashlyticsHelper.setCustomKeys({
  'user_type': user.membershipType,
  'app_version': packageInfo.version,
  'device_type': Platform.isIOS ? 'iOS' : 'Android',
});
```

### Logging Important Events

```dart
// Log important user actions
await CrashlyticsHelper.log('User completed profile setup');

// Record breadcrumbs for debugging
await CrashlyticsHelper.recordBreadcrumb('Navigated to payment screen');
```

## Configuration

### Flavor-Specific Configuration

The app uses different Firebase projects for different flavors:

- **Development**: Uses `otogapo-dev` project
- **Staging**: Uses `otogapo-dev` project (same as development)
- **Production**: Uses `otogapo-prod` project

### Firebase Console Setup

1. Enable Crashlytics in Firebase Console for both projects
2. Configure crash alerts and notifications
3. Set up data collection settings according to privacy requirements

### Android Configuration

The following files have been updated for Android:

- `android/build.gradle.kts`: Added Google Services and Crashlytics plugins
- `android/app/build.gradle.kts`: Enabled Firebase plugins
- `android/app/proguard-rules.pro`: Added Crashlytics-specific ProGuard rules

## Testing

### Development Testing

1. Use the `CrashlyticsTestButton` widget to test various Crashlytics features
2. Check Firebase Console for crash reports
3. Verify that crashes appear with proper context and stack traces

### Production Monitoring

1. Monitor Firebase Console for crash reports
2. Set up alerts for critical crashes
3. Review crash trends and prioritize fixes

## Privacy Considerations

- Crashlytics collection can be disabled using `CrashlyticsHelper.setCrashlyticsCollectionEnabled(false)`
- User consent should be obtained before enabling crash reporting
- Sensitive data should not be included in crash reports

## Troubleshooting

### Common Issues

1. **Crashes not appearing in Firebase Console**

   - Ensure Firebase is properly initialized
   - Check that Crashlytics is enabled in Firebase Console
   - Verify network connectivity

2. **Build errors related to Firebase**

   - Ensure all Firebase configuration files are present
   - Check that Google Services plugin is properly configured
   - Verify ProGuard rules are not stripping Crashlytics classes

3. **Test crashes not working**
   - Ensure you're running in development or staging mode
   - Check that Firebase is initialized before testing
   - Verify that the test widget is properly imported

### Debug Information

Enable debug logging by checking the console output for Crashlytics-related messages. All Crashlytics operations are logged in debug mode for troubleshooting.

## Best Practices

1. **Error Context**: Always provide meaningful context when logging errors
2. **User Privacy**: Respect user privacy settings and obtain consent
3. **Performance**: Don't log errors in tight loops or performance-critical code
4. **Testing**: Regularly test Crashlytics functionality in development builds
5. **Monitoring**: Set up proper alerts and monitoring for production crashes

## Files Modified

The following files were added or modified for Crashlytics integration:

### New Files

- `lib/utils/crashlytics_helper.dart`: Helper utility for Crashlytics operations
- `lib/widgets/crashlytics_test_button.dart`: Test widget for development/staging
- `lib/firebase_options_dev.dart`: Development Firebase configuration
- `lib/firebase_options_staging.dart`: Staging Firebase configuration
- `lib/firebase_options_prod.dart`: Production Firebase configuration

### Modified Files

- `pubspec.yaml`: Added Firebase dependencies
- `android/build.gradle.kts`: Added Firebase plugins
- `android/app/build.gradle.kts`: Enabled Firebase plugins
- `android/app/proguard-rules.pro`: Added Crashlytics ProGuard rules
- `lib/bootstrap.dart`: Added Crashlytics error handling
- `lib/main_development.dart`: Added Firebase initialization
- `lib/main_staging.dart`: Added Firebase initialization
- `lib/main_production.dart`: Added Firebase initialization
- `docs/DEPLOYMENT.md`: Updated with Crashlytics setup instructions
- `README.md`: Added Crashlytics to tech stack
