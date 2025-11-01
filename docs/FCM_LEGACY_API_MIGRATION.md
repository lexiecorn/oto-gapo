# FCM Legacy API Migration Guide

## Problem

Firebase Cloud Messaging Legacy API was **disabled in July 2024**. The current implementation in `lib/app/pages/send_notification_page.dart` uses the legacy `/fcm/send` endpoint which no longer works.

## Why We Need a Backend

The new FCM HTTP v1 API requires:
- Service account credentials (JSON file)
- OAuth 2.0 token generation
- Backend environment to securely store credentials

**Cannot be implemented directly in Flutter client** for security reasons.

## Migration Options

### Option 1: n8n Workflow (Recommended) ⭐

Use your existing n8n server to handle FCM v1 API requests.

**Pros:**
- You already have n8n running (`n8n.lexserver.org`)
- Visual workflow builder (no coding needed)
- Can reuse existing webhook infrastructure
- Easy to test and debug
- Handles OAuth token generation automatically

**Cons:**
- None for your setup!

**See detailed guide below.**

### Option 2: PocketBase Custom HTTP Hook

Create a custom PocketBase route that handles FCM v1 API requests.

**Steps:**
1. Create a new PocketBase collection: `notification_requests`
2. Add an After Create hook
3. In the hook, make HTTP request to FCM v1 API
4. Flutter app creates records in this collection to trigger notifications

**Pros:**
- Minimal setup
- Uses existing PocketBase infrastructure
- Secure (credentials stay on server)
- No additional server needed

**Cons:**
- Requires PocketBase admin access
- Need to write server-side code

### Option 2: Separate Backend Service

Deploy a simple Node.js/Python service that handles FCM v1 API.

**Pros:**
- More flexibility
- Better for complex notification logic

**Cons:**
- Requires separate server deployment
- Additional infrastructure cost
- More complex setup

### Option 3: Firebase Cloud Functions

Deploy a Firebase Cloud Function that handles notifications.

**Pros:**
- Native Firebase integration
- Easy OAuth token generation

**Cons:**
- Requires Firebase plan (pay-as-you-go)
- Additional setup in Firebase Console

## Recommended: n8n Workflow Implementation

### Step 1: Get Service Account Credentials

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download the JSON file
4. Open the JSON file and copy its contents

### Step 2: Create n8n Workflow

1. Go to your n8n instance: `https://n8n.lexserver.org`
2. Create a new workflow
3. Name it: "Send FCM Push Notification"

**Workflow Nodes:**

#### Node 1: Webhook Trigger
- **Type**: Webhook
- **Method**: POST
- **Path**: `/webhook/fcm-push-notification` (or your preferred path)
- **Response Mode**: "Respond When Last Node Finishes"

#### Node 2: Google Service Account (Authentication)
- **Type**: Google Service Account
- **Action**: "Authenticate"
- **Project ID**: From your service account JSON (e.g., "otogapo-prod")
- **Private Key**: From service account JSON
- **Client Email**: From service account JSON

#### Node 3: Google OAuth 2 (Get Access Token)
- **Type**: HTTP Request
- **Method**: POST
- **URL**: `https://oauth2.googleapis.com/token`
- **Authentication**: "Generic Credential Type"
- **Send Headers**: Yes
  - Header 1: `Content-Type` = `application/x-www-form-urlencoded`
- **Body Parameters**:
  - `grant_type` = `urn:ietf:params:oauth:grant-type:jwt-bearer`
  - `assertion` = (JWT token from previous node or use Code node to generate)

**Alternative simpler approach**: Use n8n's built-in OAuth handling

#### Node 3 (Simpler): HTTP Request with Service Account
- **Type**: HTTP Request
- **Method**: POST
- **URL**: `https://fcm.googleapis.com/v1/projects/{{ $json.project_id }}/messages:send`
- **Authentication**: "Service Account"
- **Send Headers**: Yes
  - Header 1: `Authorization` = `Bearer {{ $json.access_token }}`
  - Header 2: `Content-Type` = `application/json`

#### Node 4: Code (Generate FCM Payload)
- **Type**: Code
- **Mode**: "Run Once for All Items"
- **Code**:
```javascript
const items = $input.all();

return items.map(item => {
  const webhookData = item.json;
  
  // Build FCM v1 payload
  const payload = {
    message: {
      notification: {
        title: webhookData.title,
        body: webhookData.body
      },
      data: {
        type: webhookData.type || 'general'
      }
    }
  };
  
  // Add target (token or topic)
  if (webhookData.target === 'user') {
    // Get FCM token from PocketBase
    // For now, use the fcmToken from webhook payload
    payload.message.token = webhookData.fcmToken;
  } else {
    payload.message.topic = webhookData.topic;
  }
  
  return { json: payload };
});
```

#### Node 5: HTTP Request to FCM
- **Type**: HTTP Request
- **Method**: POST
- **URL**: `https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send`
- **Send Headers**: Yes
  - `Authorization`: `Bearer {{ $json.access_token }}`
  - `Content-Type`: `application/json`
- **Body**: Use JSON from previous node

### Step 3: Get Your Access Token (Simpler Method)

Actually, the simplest way is to use Google's HTTP Request node with Service Account authentication that n8n provides.

**Better approach**: Use Google Service Account node

1. **Node**: Google Service Account
2. **Operation**: "Get Access Token"
3. Configure with your service account JSON

### Step 4: Create a Simpler n8n Workflow

**Recommended n8n nodes:**

1. **Webhook Trigger** → Receives POST from Flutter app
2. **Code Node** → Generates FCM v1 payload
3. **Google Service Account** → Gets OAuth token
4. **HTTP Request** → Calls FCM API
5. **Response** → Returns success/failure

### Step 5: Update Flutter App

Modify `send_notification_page.dart` to call n8n webhook instead of FCM directly:

```dart
Future<void> _sendNotification() async {
    final payload = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'type': _selectedType.value,
        'target': _selectedTarget.value,
        if (_selectedTarget == NotificationTarget.user)
            'fcmToken': _selectedUserId, // Get FCM token from PocketBase first
        if (_selectedTarget == NotificationTarget.topic)
            'topic': _selectedTopic,
    };
    
    final dio = getIt<Dio>();
    final response = await dio.post(
        'https://n8n.lexserver.org/webhook/fcm-push-notification',
        data: payload,
    );
}
```

## Testing

1. Create a notification request record in PocketBase
2. Verify the hook is triggered
3. Check notification is sent
4. Verify record status is updated to 'sent'

## Resources

- [FCM HTTP v1 API Guide](https://firebase.google.com/docs/cloud-messaging/migrate-v1)
- [PocketBase Hooks Documentation](https://pocketbase.io/docs/hooks/)
- [PocketBase JavaScript SDK](https://pocketbase.io/docs/server-side-javascript-sdk/)

