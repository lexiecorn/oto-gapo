# PocketBase Push Notifications Setup

## Required Database Changes

You need to add **2 fields** to the PocketBase `users` collection to enable push notifications.

### Fields to Add

#### 1. `fcm_token` (Text Field)

- **Type**: `text`
- **Required**: ❌ No
- **Default**: Empty
- **Description**: Stores the Firebase Cloud Messaging token for the user's device
- **Used for**: Sending user-specific push notifications

**Field Settings:**
```
Name: fcm_token
Type: Text
Required: No
Max Length: (empty/unlimited)
Min Length: (empty)
```

#### 2. `notification_topics` (JSON Field)

- **Type**: `json`
- **Required**: ❌ No
- **Default**: Empty `[]`
- **Description**: Stores an array of topic subscriptions the user is subscribed to
- **Used for**: Managing topic-based push notification subscriptions

**Field Settings:**
```
Name: notification_topics
Type: JSON
Required: No
Default: [] (empty array)
```

### Complete Schema JSON

```json
{
  "fcm_token": {
    "type": "text",
    "required": false,
    "maxLength": null,
    "minLength": null
  },
  "notification_topics": {
    "type": "json",
    "required": false,
    "default": []
  }
}
```

## How to Add These Fields in PocketBase Admin

### Step-by-Step Instructions

1. **Log in to PocketBase Admin Panel**
   - Navigate to your PocketBase admin interface
   - URL: `https://pb.lexserver.org/_/`

2. **Access Collections**
   - Click on **"Collections"** in the left sidebar

3. **Edit Users Collection**
   - Find and click on the **"users"** collection
   - Click **"Edit collection"** button

4. **Add `fcm_token` Field**
   - Click **"+ New Field"** button
   - Set the following:
     - **Name**: `fcm_token`
     - **Type**: Select **"Text"**
     - **Required**: Leave **unchecked**
     - **Max Length**: Leave empty (unlimited)
   - Click **"Create"**

5. **Add `notification_topics` Field**
   - Click **"+ New Field"** button again
   - Set the following:
     - **Name**: `notification_topics`
     - **Type**: Select **"JSON"**
     - **Required**: Leave **unchecked**
     - **Default**: Leave empty or enter `[]`
   - Click **"Create"**

6. **Save Collection**
   - Click **"Save"** at the bottom of the page
   - Confirm the changes

## How It Works

### FCM Token Storage

When a user logs in, the app:
1. Generates a unique FCM token for their device
2. Automatically saves it to the `fcm_token` field in their user record
3. Updates the token automatically when it refreshes

**Example User Record:**
```json
{
  "id": "user123",
  "email": "john@example.com",
  "fcm_token": "dK8x3mP5jF2...",
  "notification_topics": ["announcements", "meetings"],
  "created": "2024-01-01T00:00:00Z",
  "updated": "2024-01-15T10:30:00Z"
}
```

### Topic Subscriptions

Users can subscribe to notification topics:
- `announcements` - General announcements
- `meetings` - Meeting schedules
- `urgent` - Urgent alerts

**Example `notification_topics` field:**
```json
["announcements", "meetings"]
```

### API Access Rules

The app automatically manages these fields, so you may want to ensure API rules allow:

- **Read**: Users can read their own `fcm_token` and `notification_topics`
- **Update**: Users can update their own `fcm_token` and `notification_topics`

**Recommended API Rule for `fcm_token`:**
```
@request.auth.id = id
```

**Recommended API Rule for `notification_topics`:**
```
@request.auth.id = id
```

## Validation

### Checking if Fields Were Added Correctly

1. **In PocketBase Admin Panel**
   - Go to Collections → users → Fields
   - Verify you see:
     - `fcm_token` (Text)
     - `notification_topics` (JSON)

2. **Check Existing User Records**
   - These fields should exist but be empty initially
   - They will populate when users log in and use the app

3. **In the App**
   - Log in as any user
   - Navigate to **Notification Settings**
   - You should see:
     - Permission status
     - FCM Token (automatically generated)
     - Topic subscriptions

## Troubleshooting

### Problem: App crashes on login after adding fields

**Solution**: Restart the PocketBase server and the Flutter app.

### Problem: FCM token not saving

**Solution**: 
1. Check API rules allow users to update their own fields
2. Verify internet connection
3. Check Firebase configuration is correct

### Problem: Topic subscriptions not working

**Solution**:
1. Verify `notification_topics` field type is set to **JSON** (not Text)
2. Check the field can store arrays
3. Restart the app

## Next Steps

After adding these fields:

1. ✅ **PocketBase Setup Complete**
2. ⏭️ **iOS APNs Setup** - Configure in Xcode and Firebase Console
3. ⏭️ **Get Firebase Server Key** - For sending notifications from admin panel
4. ⏭️ **Test Notifications** - Send test notifications in all app states

See `PUSH_NOTIFICATIONS_IMPLEMENTATION_COMPLETE.md` for full testing checklist.

## Related Documentation

- **API Documentation**: `docs/API_DOCUMENTATION.md` - Push Notifications section
- **Developer Guide**: `docs/DEVELOPER_GUIDE.md` - Notification setup
- **Implementation Complete**: `PUSH_NOTIFICATIONS_IMPLEMENTATION_COMPLETE.md`

