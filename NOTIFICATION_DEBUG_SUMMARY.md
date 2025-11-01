# Push Notification Debug Summary

## Problem

Notifications were successfully **sent** from n8n and Firebase Console's "Test on Device" but **not received** in the app, even though permissions were granted.

## Root Causes Identified

### 1. PocketBase Singleton Access Issue ✅ FIXED
**Problem**: `NotificationService` was capturing a stale PocketBase instance at construction time, before authentication was initialized.

**Fix**: Changed `_pocketBase` from a field to a getter that always accesses the singleton:
```dart
// Before (line 29):
final PocketBase _pocketBase = PocketBaseAuthRepository().pocketBase;

// After:
PocketBase get _pocketBase => PocketBaseAuthRepository().pocketBase;
```

### 2. Android Notification Channel Missing ✅ FIXED
**Problem**: Android requires notification channels to be created programmatically (API 26+). The channel was defined in manifest but not created in code.

**Fix**: Added channel creation in `MainActivity.kt`:
```kotlin
private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel(
            "otogapo_notifications",
            "OtoGapo Notifications",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "OtoGapo push notifications"
            enableVibration(true)
            enableLights(true)
        }
        
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager?.createNotificationChannel(channel)
    }
}
```

### 3. Missing flutter_local_notifications ✅ FIXED
**Problem**: Foreground notifications require `flutter_local_notifications` on Android.

**Fix**: Added to `pubspec.yaml`:
```yaml
flutter_local_notifications: ^17.2.4
```

### 4. Post-Login Token Saving ✅ FIXED
**Problem**: Token was obtained before user logged in, but never saved after authentication.

**Fix**: Added call in `SplashPage` when authentication detected:
```dart
notificationService.saveCurrentTokenIfAuthenticated();
```

## Changes Made

### Files Modified
1. `lib/services/notification_service.dart`
   - Changed `_pocketBase` to a getter
   - Added enhanced logging
   - Fixed save token method

2. `lib/app/pages/splash_page.dart`
   - Added FCM token saving on authentication detection

3. `android/app/src/main/kotlin/com/digitappstudio/otogapo/MainActivity.kt`
   - Added `createNotificationChannel()` method
   - Created notification channel on app start

4. `pubspec.yaml`
   - Added `flutter_local_notifications` dependency

## Testing Instructions

### 1. Rebuild Required
Since we modified native Android code (`MainActivity.kt`), you **MUST rebuild the app** (not just hot restart):

```bash
flutter clean
flutter pub get
flutter run --flavor development --target lib/main_development.dart
```

### 2. Verify Notification Channel
After running, check Android logs:
```
adb logcat | grep "Notification channel created"
```

### 3. Check FCM Token Logs
Look for these logs:
```
NotificationService: Initial token obtained: <token>
NotificationService: Token length: <length>
```

After login:
```
NotificationService: Attempting to save FCM token
NotificationService: Saving FCM token for user: <userId>
NotificationService: FCM token saved successfully
```

### 4. Test Notifications
1. **Uninstall and reinstall** the app (to ensure clean state)
2. Open app and login
3. Check PocketBase - verify `fcm_token` field is populated
4. Send test notification from Firebase Console or n8n
5. Verify notification is received

## Known Issues

- iOS APNs not configured yet (if deploying to iOS)
- FCM HTTP v1 API migration needed (Legacy API disabled July 2024)
- See `docs/PUSH_NOTIFICATIONS_NEXT_STEPS.md` for details

## Next Steps

1. ✅ Rebuild app with native changes
2. ✅ Test notification receipt
3. ⏭️ Setup n8n workflow (see `docs/N8N_FCM_WORKFLOW_SETUP.md`)
4. ⏭️ Complete iOS APNs configuration
5. ⏭️ Test in all app states (foreground, background, terminated)

## Debug Checklist

If notifications still don't work:

- [ ] App rebuilt (not hot restarted)
- [ ] Notification channel created (check logs)
- [ ] FCM token generated and logged
- [ ] FCM token saved to PocketBase after login
- [ ] Using correct FCM token in tests
- [ ] App has notification permissions enabled
- [ ] Device not in Do Not Disturb mode
- [ ] Testing on physical device (not emulator)
- [ ] Firebase project matches FCM token source
- [ ] n8n workflow using correct Firebase project ID

## Resources

- `docs/N8N_FCM_WORKFLOW_SETUP.md` - n8n workflow setup
- `docs/PUSH_NOTIFICATIONS_NEXT_STEPS.md` - Complete next steps
- `docs/POCKETBASE_NOTIFICATIONS_SETUP.md` - PocketBase setup
- `docs/API_DOCUMENTATION.md` - API reference
- `docs/DEVELOPER_GUIDE.md` - Developer guide

