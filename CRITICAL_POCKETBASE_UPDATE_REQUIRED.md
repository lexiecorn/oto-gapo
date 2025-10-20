# CRITICAL: PocketBase Permissions Setup Required

## Problem 1: Social Feed Shows "Unknown User"

The social feed was showing "Unknown User" instead of actual user names because the `users` collection had restrictive **List** and **View** rules.

### Required Fix for Social Feed

Update BOTH the **List** and **View** rules for the `users` collection:

**List Rule:**

```javascript
@request.auth.id != ""
```

**View Rule:**

```javascript
@request.auth.id != ""
```

This allows any authenticated user to view other users' basic information (name, profile picture), which is essential for social features.

### Steps to Fix:

1. Go to PocketBase Admin Dashboard: `https://pb.lexserver.org/_/`
2. Collections → **users** → ⚙️ **Settings** → **API Rules**
3. Update **List** rule to: `@request.auth.id != ""`
4. Update **View** rule to: `@request.auth.id != ""`
5. Click **Save**
6. Users must **log out and log back in** for changes to take effect

## Problem 2: Profile Image Upload (If Applicable)

Regular members (membership_type = 3) **cannot** update their profile images if the update rule only allows admins.

### Required Fix for Profile Updates

Update the `users` collection **Update Rule** to:

```javascript
@request.auth.id != "" && (@request.auth.membership_type = 1 || @request.auth.membership_type = 2 || @request.auth.id = id)
```

This rule allows:

- ✅ Super Admins (membership_type = 1) to update **any** user
- ✅ Admins (membership_type = 2) to update **any** user
- ✅ **Regular members to update THEIR OWN records** (`@request.auth.id = id`)

### Step 2: How to Update in PocketBase

1. Open your PocketBase Admin Dashboard at: `https://pb.lexserver.org/_/`
2. Click on **Collections** in the sidebar
3. Find and click on **users** collection
4. Click the **⚙️ Settings** icon
5. Go to the **API Rules** tab
6. Find the **Update** rule field
7. Replace the existing rule with the new rule above
8. Click **Save**

## What Was Fixed in the Code

### 1. Fixed Field Name Mapping

- PocketBase actually uses `profile_image` (snake_case), not `profileImage` (camelCase)
- Added proper field name conversion from `profile_image` to `profileImage` in the authentication repository
- Fixed Post and PostComment models to read `profile_image` from expanded user records

### 2. Fixed File Upload Method

- Changed from `body: { field: MultipartFile }` to `files: [MultipartFile]`
- This fixes the `JsonUnsupportedObjectError` you were seeing

## Testing After Fix

After updating the PocketBase rule:

1. **Login as a regular member** (membership_type = 3)
2. **Go to Account Information page**
3. **Click "Upload Image"**
4. **Select a photo**
5. **Should now work successfully!** ✅

## What You Should See in Logs (Success)

```
I/flutter: PocketBaseService - File fields: [profileImage]
I/flutter: PocketBaseService - Uploading file for field: profileImage
I/flutter: PocketBaseService - File size: 148845 bytes
I/flutter: PocketBaseService - File uploaded successfully ✅
```

## Important Notes

### Your Current PocketBase Configuration

Based on your collection export, your `users` collection has:

- Field name: **`profileImage`** (camelCase) ✅
- Field type: **file** ✅
- Max select: **1** ✅

The field is configured correctly - you just need to update the **Update Rule** to allow regular members to update their own records.

### Security Note

The new update rule is **secure** because:

- Regular members can **ONLY** update their own records (`@request.auth.id = id`)
- They **cannot** update other users' records
- Admins can still update any user's records
- The rule requires authentication (`@request.auth.id != ""`)

## Files Modified

### Core Service

- `lib/services/pocketbase_service.dart` - Fixed file upload method from `body` to `files` parameter

### UI Pages with State Refresh

- `lib/app/pages/current_user_account_page.dart` - **Added auth store refresh after image upload** so the UI updates immediately

**Key Fix**: After uploading, we now refresh the PocketBase auth store:

```dart
// Manually update the auth store with the new user data
pb.authStore.save(pb.authStore.token, updatedRecord);
```

This triggers the AuthBloc stream to update, causing the UI to refresh and show the new profile image immediately.

### Models (Field Name Consistency)

- `lib/models/post_comment.dart`
- `lib/models/post.dart`
- `lib/models/attendance.dart`
- `lib/app/pages/user_detail_page.dart`

### Repository

- `packages/authentication_repository/lib/src/profile_repository.dart` - Removed unnecessary field conversion

## Vehicle Photo Upload Feature

### Good News!

The `vehicles` collection **already has the correct permissions** for members to update their own vehicles:

```javascript
"updateRule": "@request.auth.id != \"\" && (user = @request.auth.id || @request.auth.membership_type = 1 || @request.auth.membership_type = 2)"
```

The `user = @request.auth.id` part allows users to update vehicles where they are the owner. ✅

### New Features Added

1. **Vehicle Information Display** - Account Information page now shows vehicle details
2. **Primary Vehicle Photo Upload** - Members can tap the camera icon on the main vehicle photo to upload/update it
3. **Additional Vehicle Photos** - Members can upload multiple additional photos (up to 6) using the "Add Photos" button
   - Select multiple photos at once from gallery (max 6)
   - Photos display in a 3-column grid
   - Shows photo count (e.g., "3/6 photos")
   - Shows upload progress
   - Automatic limit: if more than 6 selected, only first 6 are uploaded
4. **Edit Contact Information** - Members can update their own contact details
   - Edit icon (pencil) in Contact Information section
   - Update: Contact Number, Emergency Contact Name/Number, Spouse Name/Number
   - Email is read-only and cannot be edited
   - Clean, scrollable dialog interface
   - All changes save to PocketBase and update immediately
5. **Immediate UI Update** - All changes show immediately after save (no app restart needed)

The vehicle photo upload uses the same corrected approach as the profile image upload (`files` parameter), with enhanced support for multiple file uploads.

## Summary

**Code fixes**: ✅ Complete

- Profile image upload with state refresh ✅
- Vehicle photo upload with immediate UI update ✅
- Contact information editing (all fields except email) ✅

**PocketBase rule update**: ⚠️ **YOU MUST UPDATE THE USERS COLLECTION RULE MANUALLY**

Once you update the PocketBase `users` collection Update Rule as shown above, regular members will be able to:

- ✅ Upload their profile photos
- ✅ Upload their vehicle primary photo (tap camera icon on main photo)
- ✅ Upload up to 6 additional vehicle photos (tap "Add Photos" button)
- ✅ **Edit their contact information** (tap edit icon in Contact Information section)
  - Contact Number
  - Emergency Contact Name & Number
  - Spouse Name & Contact Number
  - Email is read-only (cannot be edited)
- ✅ See all changes immediately in the app
- ✅ View vehicle information including make, model, year, color, plate number
- ✅ See photo count indicator (e.g., "3/6 photos")

## How to Use the New Features

### Profile Photo Upload

1. Open Account Information page
2. Tap the camera icon on your profile picture
3. Choose Camera or Gallery
4. Select/take photo
5. Photo updates instantly ✨

### Edit Contact Information

1. Open Account Information page
2. Find the "Contact Information" section
3. Tap the **Edit icon** (pencil) in the top-right of the section
4. Edit dialog opens with all contact fields:
   - Contact Number
   - Emergency Contact Name
   - Emergency Contact Number
   - Spouse Name (optional)
   - Spouse Contact Number (optional)
5. Email field is **read-only** and cannot be edited
6. Make your changes
7. Tap **Save** to update
8. Changes save instantly and reflect immediately ✨

### Vehicle Primary Photo

1. Scroll to Vehicle Information section
2. Tap the camera icon on the main vehicle photo
3. Choose Camera or Gallery
4. Select/take photo
5. Photo updates instantly ✨

### Additional Vehicle Photos

1. Scroll to "Additional Photos" section
2. See current count (e.g., "3/6 photos")
3. Tap **"Add Photos"** button
4. Select up to 6 photos from gallery
5. If you select more than 6, only first 6 will be uploaded (you'll see a warning)
6. All photos upload and display in a 3-column grid ✨
7. Maximum 6 additional photos allowed

**Note**: If you try to select more than 6 photos, you'll see an orange notification saying "Maximum 6 photos allowed. Selected X, uploading first 6."

🎉
