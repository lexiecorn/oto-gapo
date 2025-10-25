# Splash Screen Hanging Issue - Production Fix

## Problem Description

The app gets stuck on the **native Android splash screen** (the one that shows the app logo when you first tap the app icon) after uploading to Play Store, but works fine in the emulator. This is a common production issue caused by Flutter engine initialization failures and network timeouts.

## Root Causes Identified

1. **R8 Code Shrinking**: The most likely cause - R8 (Android's code shrinker) removes critical initialization code
2. **Flutter Engine Initialization Hanging**: The Flutter engine fails to start properly in production
3. **Firebase Initialization Timeout**: Firebase initialization can hang in production environments
4. **PocketBase Network Timeout**: The app tries to connect to `https://pb.lexserver.org` during initialization, which might be unreachable or slow in production
5. **SharedPreferences Timeout**: The app waits for SharedPreferences initialization which can hang
6. **Hive Storage Timeout**: Local storage initialization can hang in production
7. **Authentication Check Hanging**: The AuthBloc tries to check existing authentication but might get stuck

## Solutions Implemented

### 1. Disabled R8 Code Shrinking (Primary Fix)

- **Disabled `isMinifyEnabled`**: Prevents R8 from removing critical code
- **Disabled `isShrinkResources`**: Prevents resource removal
- **Commented out ProGuard rules**: Removes aggressive optimization
- **APK size increased**: From 55.2MB to 58.7MB (confirms code shrinking disabled)

### 2. Reduced Timeouts

- **Splash Screen Timeout**: Reduced from 5 seconds to 3 seconds
- **PocketBase Initialization**: Reduced from 15 seconds to 5 seconds
- **Hive Storage**: Reduced from 10 seconds to 5 seconds
- **SharedPreferences**: Reduced from 10 seconds to 3 seconds

### 2. Network Connectivity Checks

- Added `NetworkHelper` utility to check internet connectivity
- Added network checks before PocketBase initialization
- Added fallback behavior when network is unavailable

### 3. Robust Error Handling

- Added try-catch blocks around all initialization steps
- Added fallback PocketBase initialization when network fails
- Added Crashlytics error reporting for debugging

### 4. Improved Authentication Flow

- Added timeout to authentication checks
- Added fallback to unauthenticated state on errors
- Improved error handling in AuthBloc

## Files Modified

### Core Bootstrap (`lib/bootstrap.dart`)

- Reduced timeouts for all initialization steps
- Added network connectivity checks
- Improved error handling and logging

### Splash Screen (`lib/app/pages/splash_page.dart`)

- Reduced timeout from 5 to 3 seconds
- Added network connectivity check
- Improved error handling

### App View (`lib/app/view/app.dart`)

- Reduced SharedPreferences timeout
- Added fallback handling for initialization errors

### Authentication (`lib/app/modules/auth/auth_bloc.dart`)

- Added timeout to authentication checks
- Improved error handling with Crashlytics reporting
- Added fallback to unauthenticated state

### PocketBase Repository (`packages/authentication_repository/lib/src/pocketbase_auth_repository.dart`)

- Added try-catch around initialization
- Added fallback PocketBase instance creation
- Improved error handling

### Network Helper (`lib/utils/network_helper.dart`)

- New utility for network connectivity checks
- Safe network operations with timeouts
- Fallback mechanisms for network failures

## Testing Recommendations

1. **Test with No Internet**: Disable internet connection and verify app doesn't hang
2. **Test with Slow Network**: Use network throttling to simulate slow connections
3. **Test with PocketBase Down**: Temporarily disable PocketBase server
4. **Test Production Build**: Always test with release builds, not debug builds

## Monitoring

- Added Crashlytics error reporting for all initialization failures
- Added detailed logging for debugging production issues
- Monitor Firebase Crashlytics for initialization errors

## Prevention

1. **Always use timeouts** for network operations
2. **Add fallback mechanisms** for critical initialization steps
3. **Test with production builds** before releasing
4. **Monitor error reports** in Firebase Crashlytics
5. **Use network connectivity checks** before making network calls

## Deployment Checklist

- [ ] Test with no internet connection
- [ ] Test with slow network connection
- [ ] Test with PocketBase server down
- [ ] Verify error reporting in Crashlytics
- [ ] Test on physical devices
- [ ] Test with production build
- [ ] Monitor app performance after deployment

## Additional Recommendations

1. **Consider implementing offline mode** for better user experience
2. **Add retry mechanisms** for failed network operations
3. **Implement progressive loading** to show progress to users
4. **Add user feedback** for network issues
5. **Consider using a CDN** for better global connectivity

## Related Documentation

- [Firebase Crashlytics Usage](CRASHLYTICS_USAGE.md)
- [Network Configuration](API_DOCUMENTATION.md)
- [Production Deployment](DEPLOYMENT.md)
