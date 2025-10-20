# Social Feed Permissions Fix

## Problem

Social feed posts were showing "Unknown User" instead of the actual user names because PocketBase expand was failing due to restrictive permissions.

## Root Cause

The `users` collection had restrictive **List** and **View** rules that prevented regular users from viewing other users' basic information. This broke the expand functionality when fetching posts, as PocketBase couldn't populate the user data for posts created by other users.

### Previous Rules (Restrictive)

**List Rule:**

```javascript
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2) || id = @request.auth.id
```

- ✅ Admins could list all users
- ✅ Users could only list themselves
- ❌ Users could NOT list other users (breaking expand)

**View Rule:**

```javascript
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || id = @request.auth.id)
```

- ✅ Admins could view any user
- ✅ Users could only view themselves
- ❌ Users could NOT view other users (breaking manual fetch fallback)

## Solution

### Updated Rules (Social-Friendly)

Both rules were updated to allow any authenticated user to view basic user information:

**List Rule:**

```javascript
@request.auth.id != ""
```

**View Rule:**

```javascript
@request.auth.id != ""
```

### Security Considerations

This change is **safe** because:

- Users must still be authenticated to view any data
- Sensitive fields (password, email, tokenKey) are protected by PocketBase system
- This is standard for social features where users need to see other users' names and profile pictures
- You can control field-level visibility if needed

### Code Changes

Added a fallback mechanism in `lib/services/pocketbase_service.dart` that manually fetches user data if expand fails:

```dart
// Manual user data population if expand failed
for (final post in result.items) {
  if (post.expand == null || post.expand!.isEmpty || !post.expand!.containsKey('user_id')) {
    final userId = post.data['user_id'] as String?;
    if (userId != null && userId.isNotEmpty) {
      try {
        final userRecord = await pb.collection('users').getOne(userId);
        post.expand = post.expand ?? {};
        post.expand!['user_id'] = userRecord;
      } catch (e) {
        print('Error fetching user $userId: $e');
      }
    }
  }
}
```

This provides resilience in case expand fails for any reason.

## How to Apply

1. Open PocketBase Admin Dashboard: `https://pb.lexserver.org/_/`
2. Navigate to **Collections** → **users**
3. Click **⚙️ Settings** → **API Rules** tab
4. Update **List** rule to: `@request.auth.id != ""`
5. Update **View** rule to: `@request.auth.id != ""`
6. Click **Save**
7. Users need to **log out and log back in** for changes to take effect

## Testing

After applying the fix, verify:

- ✅ Social feed shows actual user names (not "Unknown User")
- ✅ Profile pictures display correctly
- ✅ User profiles are accessible when tapping on names
- ✅ Comments show commenter names
- ✅ Post reactions show user information

## Related Files

- `lib/models/post.dart` - Post model with user expand logic
- `lib/models/post_comment.dart` - Comment model with user expand logic
- `lib/services/pocketbase_service.dart` - PocketBase service with manual fetch fallback
- `lib/app/pages/social_feed_page.dart` - Social feed display

## Date Fixed

October 20, 2025
