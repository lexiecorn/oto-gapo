# n8n FCM Push Notification Workflow Setup

## Overview

Use your existing n8n server to send FCM HTTP v1 push notifications. This replaces the deprecated Legacy API.

## Prerequisites

1. ✅ n8n server running at `https://n8n.lexserver.org`
2. Firebase project with FCM enabled
3. Service account credentials from Firebase

## Step 1: Get Firebase Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (otogapo-prod)
3. Go to **Project Settings** → **Service Accounts** tab
4. Click **"Generate New Private Key"**
5. Download the JSON file
6. **Keep this file secure!** Don't commit it to git.

The JSON file contains:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## Step 2: Create n8n Workflow

### Node Setup

#### Node 1: Webhook Trigger

- **Node**: Webhook
- **Name**: "Receive Notification Request"
- **HTTP Method**: POST
- **Path**: `/webhook/fcm-push-notification`
- **Response Mode**: "Respond When Last Node Finishes"
- **Authentication**: None (or add if you want security)

**Production webhook URL**: `https://n8n.lexserver.org/webhook/fcm-push-notification`

**Expected input payload**:

```json
{
  "title": "Notification Title",
  "body": "Notification body text",
  "type": "meeting",
  "target": "user",
  "fcmToken": "user-fcm-token-here"
}
```

OR for topics:

```json
{
  "title": "Notification Title",
  "body": "Notification body text",
  "type": "announcement",
  "target": "topic",
  "topic": "announcements"
}
```

**Expected output** (same as input, passed to next node):

```json
{
  "title": "Notification Title",
  "body": "Notification body text",
  "type": "meeting",
  "target": "user",
  "fcmToken": "user-fcm-token-here"
}
```

#### Node 2: Code (Generate FCM Payload)

- **Node**: Code
- **Mode**: "Run Once for All Items"
- **Name**: "Build FCM Payload"

```javascript
const items = $input.all();

return items.map((item) => {
  const data = item.json;

  // Start with base FCM v1 structure
  const payload = {
    message: {
      notification: {
        title: data.title,
        body: data.body,
      },
      data: {
        type: data.type || "general",
      },
    },
  };

  // Add target based on type
  if (data.target === "user") {
    payload.message.token = data.fcmToken;
  } else if (data.target === "topic") {
    payload.message.topic = data.topic;
  }

  return { json: payload };
});
```

**Expected output** (for user target):

```json
{
  "message": {
    "notification": {
      "title": "Notification Title",
      "body": "Notification body text"
    },
    "data": {
      "type": "meeting"
    },
    "token": "user-fcm-token-here"
  }
}
```

OR (for topic target):

```json
{
  "message": {
    "notification": {
      "title": "Notification Title",
      "body": "Notification body text"
    },
    "data": {
      "type": "announcement"
    },
    "topic": "announcements"
  }
}
```

#### Node 3: Google Service Account (Get Access Token)

- **Node**: Google Service Account
- **Operation**: "Get Access Token"
- **Name**: "Get OAuth Token"
- **Project ID**: From your service account JSON
- **Private Key**: From your service account JSON (full key including BEGIN/END lines)
- **Client Email**: From your service account JSON

**Expected output**:

```json
{
  "access_token": "ya29.c.b0Aaek...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "project_id": "your-project-id"
}
```

> **Note**: The `access_token` will be used in the Authorization header. It's valid for 1 hour.

#### Node 4: HTTP Request (Send to FCM)

- **Node**: HTTP Request
- **Method**: POST
- **URL**: `https://fcm.googleapis.com/v1/projects/{{ $('Get OAuth Token').item.json.project_id }}/messages:send`
- **Name**: "Send FCM Notification"
- **Send Headers**:
  - `Authorization`: `Bearer {{ $('Get OAuth Token').item.json.access_token }}`
  - `Content-Type`: `application/json`
- **Body**: JSON
- **JSON Body**: `{{ $json }}`

**Expected output** (successful response):

```json
{
  "name": "projects/your-project-id/messages/0:1234567890123456%abc123def456"
}
```

**Expected output** (error response):

```json
{
  "error": {
    "code": 400,
    "message": "Invalid registration token",
    "status": "INVALID_ARGUMENT"
  }
}
```

#### Node 5: Code (Handle Response)

- **Node**: Code
- **Mode**: "Run Once for All Items"
- **Name**: "Process Response"

```javascript
const items = $input.all();

return items.map((item) => {
  const response = item.json;

  if (response.name) {
    // Success - FCM returns { "name": "projects/.../messages/..." }
    return {
      json: {
        success: true,
        message: "Notification sent successfully",
        messageId: response.name,
      },
    };
  } else {
    // Error
    return {
      json: {
        success: false,
        message: "Failed to send notification",
        error: response.error || "Unknown error",
      },
    };
  }
});
```

**Expected output** (successful):

```json
{
  "success": true,
  "message": "Notification sent successfully",
  "messageId": "projects/your-project-id/messages/0:1234567890123456%abc123def456"
}
```

**Expected output** (error):

```json
{
  "success": false,
  "message": "Failed to send notification",
  "error": {
    "code": 400,
    "message": "Invalid registration token",
    "status": "INVALID_ARGUMENT"
  }
}
```

#### Node 6: Respond to Webhook

- **Node**: Respond to Webhook
- **Name**: "Send Response"
- **Response Code**: 200
- **Body**: Use JSON from "Process Response" node

**Expected output** (HTTP Response sent to client):

**Status**: `200 OK`

**Headers**:

```
Content-Type: application/json
```

**Body** (successful):

```json
{
  "success": true,
  "message": "Notification sent successfully",
  "messageId": "projects/your-project-id/messages/0:1234567890123456%abc123def456"
}
```

**Body** (error):

```json
{
  "success": false,
  "message": "Failed to send notification",
  "error": {
    "code": 400,
    "message": "Invalid registration token",
    "status": "INVALID_ARGUMENT"
  }
}
```

## Step 3: Update Flutter App

Modify `lib/app/pages/send_notification_page.dart`:

```dart
Future<void> _sendFcmRestRequest(Map<String, dynamic> payload) async {
  final dio = getIt<Dio>();

  // Get FCM token if sending to user
  String? fcmToken;
  if (_selectedTarget == NotificationTarget.user && _selectedUserId != null) {
    final userRecord = await _pbService.getUser(_selectedUserId!);
    fcmToken = userRecord?.data['fcm_token'] as String?;

    if (fcmToken == null || fcmToken.isEmpty) {
      throw Exception('User does not have an FCM token registered');
    }
  }

  // Build n8n webhook payload
  final n8nPayload = {
    'title': _titleController.text,
    'body': _bodyController.text,
    'type': _selectedType.value,
    'target': _selectedTarget.value,
    if (fcmToken != null) 'fcmToken': fcmToken,
    if (_selectedTopic != null) 'topic': _selectedTopic,
  };

   try {
     final response = await dio.post<Map<String, dynamic>>(
       'https://n8n.lexserver.org/webhook/fcm-push-notification',
       data: n8nPayload,
      options: Options(
        headers: {'Content-Type': 'application/json'},
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (response.data != null &&
        response.data!.containsKey('success') &&
        response.data!['success'] == true) {
      debugPrint('FCM notification sent successfully: ${response.data}');
    } else {
      throw Exception('Failed to send notification: ${response.data}');
    }
  } on DioException catch (e) {
    debugPrint('FCM send error: ${e.response?.data}');
    throw Exception('Failed to send notification: ${e.message}');
  }
}
```

## Step 4: Testing

### Test 1: Manual Webhook Test

1. In n8n, click "Test" button on Webhook node
2. n8n will provide a test URL
3. Use curl or Postman to send test request:

```bash
curl -X POST https://n8n.lexserver.org/webhook/fcm-push-notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "body": "This is a test from n8n",
    "type": "general",
    "target": "topic",
    "topic": "announcements"
  }'
```

### Test 2: From Flutter App

1. Launch your app
2. Go to Admin Panel → Send Notification
3. Fill in notification details
4. Click "Send Notification"
5. Check device receives notification

### Test 3: Check n8n Execution Log

1. Go to n8n → Executions
2. Find your test execution
3. Click to view each node's output
4. Debug any errors

## Troubleshooting

### Issue: "401 Unauthorized" in FCM request

**Solution**: Check your OAuth token is being generated correctly in Google Service Account node.

### Issue: "Invalid registration token"

**Solution**: Ensure FCM token is valid and not expired. User needs to reopen app to refresh token.

### Issue: "Topic format is incorrect"

**Solution**: Topic names must contain only lowercase letters, numbers, and underscores/dashes. No slashes.

### Issue: Webhook not receiving requests

**Solution**:

1. Check webhook is active in n8n
2. Verify URL is correct
3. Check firewall/security settings

## Security Considerations

1. **Add webhook authentication**: Use query parameters or headers to secure your webhook
2. **Store credentials securely**: Never commit service account JSON to git
3. **Rate limiting**: Consider adding rate limits in n8n workflow
4. **Logging**: Monitor n8n execution logs for suspicious activity

## Next Steps

1. ✅ Create n8n workflow
2. ✅ Get service account credentials
3. ⏭️ Update Flutter app code
4. ⏭️ Test workflow
5. ⏭️ Deploy to production

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [FCM HTTP v1 API Reference](https://firebase.google.com/docs/cloud-messaging/send-message)
- [n8n Google Service Account Node](https://docs.n8n.io/integrations/builtin/credentials/google/service-account/)

## Quick Reference

**n8n Webhook URL**: `https://n8n.lexserver.org/webhook/fcm-push-notification`

**Project ID**: Get from Firebase Console → Project Settings

**Testing**: Use n8n's "Test" button or curl command above
