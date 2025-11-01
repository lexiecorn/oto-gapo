# Push Notifications - Next Steps

## ⚠️ Important Update

**Firebase Legacy API has been disabled** (July 2024). The current implementation needs to be migrated to HTTP v1 API, which requires a backend service.

## ✅ Completed

- [x] Push notification code implementation
- [x] PocketBase database fields added (`fcm_token` and `notification_topics`)
- [x] FCM token generation working
- [x] Topic subscriptions working

## ⏭️ Required: Migrate to FCM HTTP v1 API

### Current Status

The app currently uses the **deprecated Legacy API** which no longer works. You need to migrate to **FCM HTTP v1 API** using a backend service.

**See migration guide:** `docs/FCM_LEGACY_API_MIGRATION.md`

### Quick Summary

The HTTP v1 API requires:

- Service account credentials (JSON file from Firebase)
- OAuth 2.0 token generation
- Backend server (cannot be done in Flutter)

**Recommended solution:** Use n8n workflow to handle FCM v1 API requests.

**Setup guide:** `docs/N8N_FCM_WORKFLOW_SETUP.md`

### What Still Works

✅ FCM token generation (receiving notifications)  
✅ Topic subscriptions  
✅ Notification permissions  
❌ Sending notifications (needs migration)

### 2. iOS Setup (If deploying to iOS)

If you're deploying to iOS devices, complete these steps:

#### A. Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Add **"Push Notifications"**

#### B. Configure APNs in Firebase

1. In Firebase Console → Project Settings → Cloud Messaging
2. Under **Apple app configuration**, upload your APNs Authentication Key or Certificate
3. Follow the [Firebase iOS setup guide](https://firebase.google.com/docs/cloud-messaging/ios/client)

**Note**: Android is already fully configured! No additional steps needed.

### 3. Test the Implementation

Run these tests in your app:

#### A. Test FCM Token Generation

1. Launch the app
2. Log in with any user
3. Navigate to **Notification Settings** page
4. You should see your FCM token displayed
5. Check PocketBase to verify the token was saved to the `fcm_token` field

#### B. Test Topic Subscriptions

1. In the app, go to **Notification Settings**
2. Subscribe to a topic (e.g., "announcements")
3. Check PocketBase to verify it's saved in `notification_topics` as JSON array

#### C. Test Sending Notifications

**From Admin Panel:**

1. Navigate to **Admin Panel → Send Notification**
2. Paste your Firebase Server Key
3. Fill in:
   - Title: "Test Notification"
   - Body: "This is a test message"
   - Type: Select any type
   - Target: Select "topic"
   - Topic: Select "announcements"
4. Click **Send Notification**
5. You should receive the notification on your device

**Test different scenarios:**

- ✅ **Foreground**: App is open and active
- ✅ **Background**: App is minimized
- ✅ **Terminated**: App is completely closed
- ✅ **Deep Links**: Tap notification and verify it navigates to correct page

### 4. Test Deep Linking

Send notifications with different types and verify navigation:

| Notification Type | Should Navigate To      |
| ----------------- | ----------------------- |
| `meeting`         | Meeting Details Page    |
| `announcement`    | Announcements List Page |
| `payment`         | Profile Page            |
| `post`            | Post Detail Page        |
| `general`         | Home Page               |

### 5. Production Deployment

Once everything is tested:

1. Build your production app
2. Deploy to app stores (Google Play Store / Apple App Store)
3. Monitor notification delivery in Firebase Console → Cloud Messaging → Delivery statistics

## 🆘 Troubleshooting

### Problem: "FCM token not generated"

**Solution**:

- Verify Firebase project is properly configured
- Check `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place
- Check app logs for Firebase initialization errors

### Problem: "Notifications not received"

**Solution**:

- Verify notification permissions are granted on device
- Check Firebase Server Key is correct
- Verify device has internet connection
- Check FCM token is valid and not expired

### Problem: "Deep links not working"

**Solution**:

- Verify notification data payload includes correct `type` field
- Check routes are properly registered in `app_router.dart`
- Verify the app is opened (not just the notification handler triggered)

### Problem: "iOS notifications not working"

**Solution**:

- Verify Push Notifications capability is enabled in Xcode
- Check APNs configuration in Firebase Console
- Ensure you're using a physical iOS device (not simulator)
- Verify certificates are valid in Apple Developer Portal

## 📊 Monitoring

Monitor notification delivery in Firebase Console:

1. Go to Firebase Console → Cloud Messaging
2. View **Delivery statistics**
3. Check **Notifications** tab for success/failure rates
4. Review **User engagement** metrics

## 📚 Additional Resources

- **API Documentation**: `docs/API_DOCUMENTATION.md` - Full API reference
- **Developer Guide**: `docs/DEVELOPER_GUIDE.md` - Setup and implementation details
- **PocketBase Setup**: `docs/POCKETBASE_NOTIFICATIONS_SETUP.md` - Database setup
- **Implementation Complete**: `PUSH_NOTIFICATIONS_IMPLEMENTATION_COMPLETE.md` - Full checklist

## ✅ Final Checklist

- [x] PocketBase fields added
- [ ] Firebase Server Key obtained
- [ ] iOS APNs configured (if deploying to iOS)
- [ ] FCM tokens generating correctly
- [ ] Topic subscriptions working
- [ ] Notifications received in all app states
- [ ] Deep links working for all types
- [ ] Admin panel can send notifications
- [ ] Production app tested
- [ ] Monitoring setup in Firebase Console

**You're almost there! Complete these steps and your push notification system will be fully operational.** 🎉
