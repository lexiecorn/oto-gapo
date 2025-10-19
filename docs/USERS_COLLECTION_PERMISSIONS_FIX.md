# Users Collection Permissions Fix

## Problem

The payment dialog shows "user record not found" because the `users` collection API rules don't allow admin users to access individual user records via `getOne()`.

## Root Cause

- `getAllUsers()` uses `getList()` which works (List/Search rule allows admin access)
- `getUser(userId)` uses `getOne()` which fails (View rule may be too restrictive)

## Solution

### Step 1: Check Current Users Collection Rules

In PocketBase Admin Dashboard:

1. Go to **Collections** → **users** → **API Rules** tab
2. Check the current rules

### Step 2: Update Users Collection API Rules

The `users` collection should have these rules:

#### List/Search Rule

```
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.id = id)
```

#### View Rule (CRITICAL - This is likely the issue)

```
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.id = id)
```

#### Create Rule

```
@request.auth.isAdmin = true
```

#### Update Rule

```
@request.auth.isAdmin = true || (@request.auth.id = id && @request.data.isAdmin:isset = false)
```

#### Delete Rule

```
@request.auth.isAdmin = true
```

### Step 3: Verify Admin User Setup

Ensure your admin user has:

- `isAdmin = true` field set
- Proper authentication

### Step 4: Test the Fix

1. **Test as Admin**:

   ```dart
   // This should work after the fix
   final user = await pocketBaseService.getUser(otherUserId);
   print('User found: ${user?.data['email']}');
   ```

2. **Test Payment Dialog**:
   - Click on any user in Payment Management
   - Should see months list instead of "user record not found"

### Step 5: Alternative Solution (Code Fallback)

If you can't modify PocketBase rules immediately, the code already includes a fallback in `getUser()` method:

```dart
// If getOne fails, try getList with filter
final result = await pb.collection('users').getList(
  filter: 'id = "$userId"',
  perPage: 1,
);
```

This should work even with restrictive View rules.

## Debugging Steps

### 1. Check Current Rules

Look at your PocketBase admin interface for the `users` collection and verify the View rule includes admin access.

### 2. Test Authentication

```dart
// Add this debug code to verify admin status
final currentUser = await pocketBaseService.pb.authStore.model;
print('Current user: ${currentUser?.id}');
print('Is admin: ${currentUser?.data['isAdmin']}');
```

### 3. Test Direct Access

```dart
// Test if you can access the user directly
try {
  final user = await pocketBaseService.pb.collection('users').getOne(userId);
  print('Direct access works: ${user.data['email']}');
} catch (e) {
  print('Direct access failed: $e');
}
```

## Expected Behavior After Fix

### ✅ Working Scenario

1. Admin logs in
2. Goes to Payment Management
3. Clicks on any user
4. Dialog opens with months list
5. Can record payments for that user

### ❌ Current Issue

1. Admin logs in
2. Goes to Payment Management
3. Clicks on any user
4. Dialog shows "user record not found"
5. Cannot access payment months

## Files Modified

- `lib/services/pocketbase_service.dart` - Added fallback in `getUser()` method
- `lib/app/pages/payment_management_page_new.dart` - Enhanced error handling and logging

## Quick Test

Run this in your app to test the fix:

```dart
// Test admin access to users
final pocketBaseService = PocketBaseService();

// Test 1: Can get all users (should work)
final allUsers = await pocketBaseService.getAllUsers();
print('All users count: ${allUsers.length}');

// Test 2: Can get specific user (this was failing)
if (allUsers.isNotEmpty) {
  final firstUser = allUsers.first;
  final specificUser = await pocketBaseService.getUser(firstUser.id);
  print('Specific user found: ${specificUser?.data['email']}');
}
```

## Next Steps

1. **Immediate**: Update the `users` collection View rule in PocketBase
2. **Verify**: Test the payment dialog with different users
3. **Monitor**: Check console logs for any remaining permission errors
4. **Document**: Update your PocketBase rules documentation

The fallback code should handle most cases, but updating the PocketBase rules is the proper long-term solution.
