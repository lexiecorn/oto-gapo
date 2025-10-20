# PocketBase Permissions Setup Guide

## Overview

This guide explains how to configure PocketBase collection permissions to allow admin users to manage payment records for all users.

## Issue

When an admin tries to view or edit payment records for other users, they may encounter "user record not found" or permission errors if the PocketBase collections are not configured correctly.

## Required Collections

### 1. `users` Collection

**Purpose**: Stores user profile information

**Required API Rules**:

#### List/Search Rule (for getAllUsers)

```javascript
// Allow admins to list all users
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2) || id = @request.auth.id
```

This allows:

- Admins (membership_type 1 or 2) to get list of all users
- Regular users to see only themselves

#### View Rule (for getUser)

```javascript
// Allow admins to view any user, or users to view themselves
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || id = @request.auth.id)
```

This allows:

- Admins (membership_type 1 or 2) to view any user's profile
- Regular users to view their own profile
- Only authenticated users can access records

#### Create Rule

```javascript
// Only admins can create users (or allow public registration)
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)
```

#### Update Rule

```javascript
// Admins can update any user, users can update themselves (with restrictions)
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2) || (@request.auth.id = id && (@request.data.isAdmin:isset = false || @request.data.isAdmin:isset != true) && (@request.data.membership_type:isset = false || @request.data.membership_type = @record.membership_type))
```

**Alternative simpler rule (recommended for regular users to update their profile):**

```javascript
// Admins can update any user, users can update their own profile (excluding admin/membership fields)
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || @request.auth.id = id)
```

**Note**: If using the simpler rule, you should handle admin/membership field restrictions in your application code, not in PocketBase rules.

This allows:

- Admins to update any user
- Regular users to update their own profile including **profileImage** field
- Restrictions on admin/membership fields should be enforced in application logic

#### Delete Rule

```javascript
// Only admins can delete users
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)
```

### 2. `payment_transactions` Collection

**Purpose**: Stores monthly payment records

**Required API Rules**:

#### List/Search Rule

```javascript
// Allow admins to list all transactions, users to see only their own
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || user = @request.auth.id)
```

#### View Rule

```javascript
// Allow admins to view any transaction, users to view their own
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || user = @request.auth.id)
```

#### Create Rule

```javascript
// Only admins can create payment transactions
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)
```

#### Update Rule

```javascript
// Only admins can update payment transactions
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)
```

#### Delete Rule

```javascript
// Only admins can delete payment transactions
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)
```

### 3. `vehicles` Collection

**Purpose**: Stores user vehicle information

**Required API Rules**:

#### List/Search Rule

```javascript
// Allow admins to list all vehicles, users to see only their own
@request.auth.isAdmin = true || userId = @request.auth.id
```

#### View Rule

```javascript
// Allow admins to view any vehicle, users to view their own
@request.auth.isAdmin = true || userId = @request.auth.id
```

#### Create Rule

```javascript
// Admins can create for anyone, users can create for themselves
@request.auth.isAdmin = true || userId = @request.auth.id
```

#### Update Rule

```javascript
// Admins can update any vehicle, users can update their own
@request.auth.isAdmin = true || userId = @request.auth.id
```

#### Delete Rule

```javascript
// Admins can delete any vehicle, users can delete their own
@request.auth.isAdmin = true || userId = @request.auth.id
```

### 4. `attendance_records` Collection

**Purpose**: Stores meeting attendance

**Required API Rules**:

#### List/Search Rule

```javascript
// Allow admins to list all records, users to see their own
@request.auth.isAdmin = true || user_id = @request.auth.id
```

#### View Rule

```javascript
// Allow admins to view any record, users to view their own
@request.auth.isAdmin = true || user_id = @request.auth.id
```

#### Create Rule

```javascript
// Only admins can create attendance records
@request.auth.isAdmin = true
```

#### Update Rule

```javascript
// Only admins can update attendance records
@request.auth.isAdmin = true
```

#### Delete Rule

```javascript
// Only admins can delete attendance records
@request.auth.isAdmin = true
```

### 5. `meetings` Collection

**Purpose**: Stores meeting information

**Required API Rules**:

#### List/Search Rule

```javascript
// Allow all authenticated users to list meetings
@request.auth.id != ""
```

#### View Rule

```javascript
// Allow all authenticated users to view meetings
@request.auth.id != ""
```

#### Create Rule

```javascript
// Only admins can create meetings
@request.auth.isAdmin = true
```

#### Update Rule

```javascript
// Only admins can update meetings
@request.auth.isAdmin = true
```

#### Delete Rule

```javascript
// Only admins can delete meetings
@request.auth.isAdmin = true
```

### 6. `Announcements` Collection

**Purpose**: Stores announcements

**Required API Rules**:

#### List/Search Rule

```javascript
// Allow all authenticated users to list announcements
@request.auth.id != ""
```

#### View Rule

```javascript
// Allow all authenticated users to view announcements
@request.auth.id != ""
```

#### Create Rule

```javascript
// Only admins can create announcements
@request.auth.isAdmin = true
```

#### Update Rule

```javascript
// Only admins can update announcements
@request.auth.isAdmin = true
```

#### Delete Rule

```javascript
// Only admins can delete announcements
@request.auth.isAdmin = true
```

## Step-by-Step Setup

### 1. Access PocketBase Admin Dashboard

```bash
# Navigate to your PocketBase admin dashboard
# Usually at: http://localhost:8090/_/ (local)
# Or your deployed URL + /_/
```

### 2. For Each Collection

1. Click on the collection name in the sidebar
2. Click the ⚙️ (Settings) icon
3. Go to the **API Rules** tab
4. Configure each rule type (List, View, Create, Update, Delete)
5. Use the formulas provided above
6. Click **Save** after configuring all rules

### 3. Test Permissions

#### Test as Admin

```dart
// Should work: Get any user's information
final user = await pocketBaseService.getUser(otherUserId);

// Should work: Get all users
final users = await pocketBaseService.getAllUsers();

// Should work: Update any user's payment
await pocketBaseService.updatePaymentTransaction(
  userId: otherUserId,
  month: '2024-01',
  status: PaymentStatus.paid,
);
```

#### Test as Regular User

```dart
// Should work: Get own information
final user = await pocketBaseService.getUser(currentUserId);

// Should fail: Get other user's information
final user = await pocketBaseService.getUser(otherUserId); // Returns null or error

// Should fail: Get all users
final users = await pocketBaseService.getAllUsers(); // Returns only self or error
```

## Profile Image Upload Configuration

### Required Field Setup

Ensure the `users` collection has a `profile_image` field (note: snake_case) configured as:

- **Field Name**: `profile_image` (PocketBase uses snake_case)
- **Type**: File
- **Max Select**: 1
- **Max Size**: 5MB (or as needed)
- **Allowed Types**: image/jpeg, image/png, image/jpg, image/webp

**Important**: The Dart code uses `profileImage` (camelCase) but PocketBase schema uses `profile_image` (snake_case). The field name conversion is handled automatically by the service layer.

### Update Rule for Profile Images

For regular members to upload their own profile photos, use this Update rule:

```javascript
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || @request.auth.id = id)
```

This allows:

- Admins to update any user's profile image
- Regular members to update their own profile image

### Testing Profile Image Upload

```dart
// Test as regular member - should work
final pocketBaseService = PocketBaseService();
await pocketBaseService.updateUser(
  currentUserId,
  {'profileImage': File('/path/to/image.jpg')},
);

// Test as admin - should work for any user
await pocketBaseService.updateUser(
  otherUserId,
  {'profileImage': File('/path/to/image.jpg')},
);
```

## Common Issues and Solutions

### Issue: 404 Error when uploading profile image

**Cause**: PocketBase endpoint not found or incorrect URL configuration
**Solution**:

1. Ensure `pocketbaseUrl` is correctly set in FlavorConfig
2. Verify the PocketBase server is running and accessible
3. Check that the file upload is using the PocketBase SDK's built-in `update` method

### Issue: "User record not found" for admins

**Cause**: View rule on `users` collection is too restrictive
**Solution**: Ensure View rule includes admin access: `@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || id = @request.auth.id)`

### Issue: Admin can see user list but not individual users

**Cause**: List rule is correct but View rule is wrong
**Solution**: Add admin access to View rule: `@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || id = @request.auth.id)`

### Issue: Regular users can't see their own profile

**Cause**: Missing self-access in rules
**Solution**: Add `|| @request.auth.id = id` to View and List rules

### Issue: Admin can't update payment transactions

**Cause**: Update rule on `payment_transactions` is too restrictive
**Solution**: Ensure Update rule includes admin access: `@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)`

### Issue: User field not found in payment_transactions

**Cause**: Field name mismatch
**Solution**: Check if your field is named `user`, `userId`, or `user_id` and update rules accordingly

## Verification Checklist

- [ ] Users collection allows admin to getOne (View rule)
- [ ] Users collection allows admin to getList (List rule)
- [ ] Payment_transactions collection allows admin to create/update
- [ ] Payment_transactions collection has correct relation field name
- [ ] All users have `isAdmin` field set correctly
- [ ] Test admin access with debug logging enabled
- [ ] Test regular user access (should be restricted)

## Code Changes Made

To handle permission issues gracefully, the `getUser()` method in `PocketBaseService` now includes a fallback:

```dart
// If getOne fails due to permissions, try getList with filter
// This works around cases where List rule is more permissive than View rule
final result = await pb.collection('users').getList(
  filter: 'id = "$userId"',
  perPage: 1,
);
```

This ensures that even if View permissions are misconfigured, admins can still access user data through the List endpoint.

## Related Files

- `lib/services/pocketbase_service.dart` - Service with getUser fallback
- `lib/app/pages/payment_management_page_new.dart` - Payment management UI
- `pocketbase_users_schema.json` - User collection schema
- `pocketbase_collections_import.json` - Collection definitions

## Best Practices

1. **Always test permissions** after making changes
2. **Use least privilege principle** - give minimum required permissions
3. **Log permission errors** for debugging
4. **Document any custom rules** specific to your deployment
5. **Backup collection rules** before making changes
6. **Test with both admin and regular user accounts**

## Additional Resources

- [PocketBase API Rules Documentation](https://pocketbase.io/docs/manage-collections/#api-rules)
- [PocketBase Collection Types](https://pocketbase.io/docs/collections/)
- Project Documentation: `docs/API_DOCUMENTATION.md`
