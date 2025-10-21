# Announcement Management System

## Overview

The Announcement Management System provides a comprehensive solution for creating, managing, and distributing announcements to users with support for images, type categorization, and login popup functionality.

## Features

### Admin Features

- ✅ Full CRUD operations (Create, Read, Update, Delete)
- ✅ Image upload with automatic compression
- ✅ Type categorization with color coding
- ✅ Toggle active/inactive status
- ✅ Login popup feature for critical announcements
- ✅ Search and filter by type
- ✅ Modern card-based UI with image thumbnails

### User Features

- ✅ Browse announcements with search
- ✅ Filter by type (general, important, urgent, event, reminder, success)
- ✅ View announcements with full-height images
- ✅ See full details in popup dialog
- ✅ Receive critical announcements as login popups

## PocketBase Collection Schema

### Collection: `Announcements`

**Access Rules:**

- List/View: All authenticated users (`@request.auth.id != ""`)
- Create/Update/Delete: Admin only (`@request.auth.membership_type = 1 || @request.auth.membership_type = 2`)

**Fields:**

| Field       | Type     | Required | Description                                |
| ----------- | -------- | -------- | ------------------------------------------ |
| id          | text     | Yes      | Auto-generated 15-char ID                  |
| title       | text     | No       | Announcement title                         |
| content     | text     | No       | Announcement body content                  |
| type        | select   | No       | Announcement type (default: general)       |
| img         | file     | No       | Single image attachment                    |
| showOnLogin | bool     | No       | Display as popup on login (default: false) |
| isActive    | bool     | No       | Visible to users (default: true)           |
| created     | autodate | Yes      | Creation timestamp                         |
| updated     | autodate | Yes      | Last update timestamp                      |

**Type Options:**

- `general` - Regular updates, news
- `important` - High-priority matters
- `urgent` - Critical, time-sensitive information
- `event` - Meetings, activities, gatherings
- `reminder` - Payment reminders, deadlines
- `success` - Achievements, good news

**Image Field Settings:**

- Max file size: 3MB (3242880 bytes)
- Allowed MIME types: image/jpeg, image/png, image/svg+xml, image/gif, image/webp
- Thumbnails: 100x100t, 300x300t, 600x400t
- Max select: 1 (single image only)

## Implementation Details

### File Structure

```
lib/
├── app/
│   ├── pages/
│   │   ├── announcement_management_page.dart  # Admin CRUD interface
│   │   ├── announcements_list_page.dart       # User-facing list
│   │   └── announcements.dart                 # Home widget
│   └── widgets/
│       └── announcement_popup_dialog.dart     # Login popup dialog
├── services/
│   └── pocketbase_service.dart                # Announcement API methods
└── utils/
    ├── image_compression_helper.dart          # Auto-compress images
    └── announcement_type_helper.dart          # Type colors/icons

pocketbase/
├── pocketbase_announcements_schema.json       # Collection schema
└── pocketbase_announcements_corrected.json    # Full collection export
```

### Components

#### 1. Announcement Management Page

**Location:** `lib/app/pages/announcement_management_page.dart`

**Features:**

- Admin access control (membership_type 1 or 2)
- Search announcements by title/content
- Filter by type
- Create/Edit dialog with:
  - Title field (max 200 chars)
  - Content field (max 1000 chars)
  - Type dropdown
  - Image picker with preview
  - Show on Login toggle
  - Active toggle
- Delete confirmation dialog
- Toggle active status quick action
- Grid layout with image thumbnails

**Access:** Admin Panel → Announcement Management

#### 2. Announcements List Page

**Location:** `lib/app/pages/announcements_list_page.dart`

**Features:**

- User-facing announcement list
- Search functionality
- Type filter chips
- Magazine-style cards with:
  - Full-height images (120.w x card height)
  - Title and type badge
  - Content preview (3 lines max)
  - Black footer with date
- Detail dialog with full image and content

**Access:** Home → Announcements navigation card

#### 3. Announcements Home Widget

**Location:** `lib/app/pages/announcements.dart`

**Features:**

- Compact announcement widget for home page
- Scrollable list with animated cards
- Shows latest announcements
- Click to view details

#### 4. Login Popup Dialog

**Location:** `lib/widgets/announcement_popup_dialog.dart`

**Features:**

- Beautiful dialog with type-based styling
- Image display (600x400t thumbnail)
- "Got it!" button to dismiss
- Displays announcements sequentially
- Auto-triggers on HomePage load

### Image Compression

**Location:** `lib/utils/image_compression_helper.dart`

**Process:**

1. Check if image exceeds 3MB
2. If under limit, use original
3. If over limit:
   - Resize to max 1920px width (preserve aspect ratio)
   - Compress to 85% quality JPEG
   - If still too large, reduce quality to 75%, then 65%, then 50%
4. Return compressed image path

**Usage:**

```dart
final compressedPath = await ImageCompressionHelper.compressImageIfNeeded(
  originalImagePath,
);
```

### Type Helper

**Location:** `lib/utils/announcement_type_helper.dart`

Centralized helper for consistent type styling across the app.

**Methods:**

- `getTypeColor(String type, bool isDark)` - Returns color for type
- `getTypeIcon(String type)` - Returns icon for type
- `allTypes` - List of all valid types

## API Methods

### PocketBaseService Methods

Located in `lib/services/pocketbase_service.dart`

#### Get Announcements

```dart
// Get all announcements (sorted by created date, newest first)
Future<List<RecordModel>> getAnnouncements() async

// Get announcements for login popup
Future<List<RecordModel>> getLoginAnnouncements() async
// Returns: announcements where showOnLogin=true AND isActive=true
```

#### Create Announcement

```dart
Future<RecordModel> createAnnouncement({
  required String title,
  required String content,
  String? type,              // Default: 'general'
  String? imageFilePath,     // Auto-compressed if provided
  bool showOnLogin = false,
  bool isActive = true,
}) async
```

**Process:**

1. If no image: Simple `pb.collection().create()`
2. If image provided:
   - Reads file bytes
   - Creates HTTP MultipartRequest
   - Adds authorization header
   - Adds file as 'img' field
   - Adds other fields
   - Sends request
   - Returns RecordModel

#### Update Announcement

```dart
Future<RecordModel> updateAnnouncement({
  required String announcementId,
  String? title,
  String? content,
  String? type,
  String? imageFilePath,     // Replaces image if provided
  bool? showOnLogin,
  bool? isActive,
}) async
```

**Note:** Only provided fields are updated (partial updates supported)

#### Delete Announcement

```dart
Future<void> deleteAnnouncement(String announcementId) async
```

#### Toggle Active Status

```dart
Future<RecordModel> toggleAnnouncementActive(String announcementId) async
```

Gets current status and toggles `isActive` field.

#### Get Image URL

```dart
String getAnnouncementImageUrl(
  RecordModel announcement,
  {String? thumb}  // Optional: '100x100t', '300x300t', '600x400t'
)
```

Returns empty string if no image, otherwise builds PocketBase file URL.

## User Flows

### Admin Creating Announcement

1. Login as admin (membership_type 1 or 2)
2. Navigate to Admin Panel
3. Click "Announcement Management" card
4. Click floating "Create" button
5. Fill in form:
   - Enter title (required)
   - Enter content (required)
   - Select type from dropdown
   - Optionally add image (auto-compressed to 3MB)
   - Toggle "Show on Login" if critical
   - Toggle "Active" to make visible
6. Click "Save"
7. Image is compressed (if needed)
8. Announcement created in PocketBase
9. Success message shown

### User Viewing Announcements

**Login Popup:**

1. User logs in successfully
2. HomePage loads
3. After 500ms, checks for login announcements
4. If found, shows popup dialog(s) sequentially
5. User clicks "Got it!" to dismiss

**Browsing Announcements:**

1. Navigate to Announcements from home
2. See list of active announcements
3. Search by title/content
4. Filter by type
5. Click announcement to view details
6. View full image and content in dialog

## Design Patterns

### Card Layout

Announcements use a magazine-style card layout:

```
┌────────────────────────────────┐
│ [Image] Title + Type Badge     │
│ [120w ] Content preview...     │
│ [ x   ] More content...        │
│ [Full ] ────────────────────── │
│ [Ht  ] █ Date & Arrow Icon █   │ ← Black footer
└────────────────────────────────┘
```

**With Image:**

- Image: 120.w width, full card height, no margins
- Footer: Black background (80% opacity), white text
- Content: Padded area on the right

**Without Image:**

- Icon: 60.w width, type-colored background
- Same footer and content layout

### Type-Based Styling

Each announcement type has consistent colors and icons:

| Type      | Light Color | Dark Color | Icon          |
| --------- | ----------- | ---------- | ------------- |
| general   | Blue 600    | Blue 300   | info          |
| important | Orange 600  | Orange 300 | priority_high |
| urgent    | Red 600     | Red 300    | warning       |
| event     | Purple 600  | Purple 300 | event         |
| reminder  | Teal 600    | Teal 300   | notifications |
| success   | Green 600   | Green 300  | check_circle  |

## Technical Implementation

### Image Upload Process

1. User selects image via `image_picker`
2. Image path received
3. `ImageCompressionHelper.compressImageIfNeeded()` called
4. Checks file size:
   - If ≤ 3MB: Use original
   - If > 3MB: Compress with quality 85%, resize if > 1920px width
   - If still > 3MB: Reduce quality incrementally (75%, 65%, 50%)
5. Compressed image path returned
6. `PocketBaseService.createAnnouncement()` called with path
7. Creates `http.MultipartRequest` with:
   - Authorization header from `pb.authStore.token`
   - File as multipart with field name 'img'
   - Other fields as form data
8. Sends to PocketBase API
9. Returns `RecordModel` on success

### Login Popup Integration

**Location:** `lib/app/pages/home_page.dart` - `initState()`

**Process:**

```dart
1. HomePage.initState() called
2. _checkAndShowLoginAnnouncements() scheduled (500ms delay)
3. Fetches announcements with showOnLogin=true & isActive=true
4. If found, calls AnnouncementPopupDialog.showLoginAnnouncements()
5. Shows each announcement sequentially in dialog
6. User dismisses each dialog
7. Continues to normal app flow
```

**Session Control:**

- `_hasShownLoginAnnouncements` flag prevents multiple shows in same session
- Shows every time app is opened (not limited to once per day)

## Testing

### Admin Functions

1. Create announcement without image
2. Create announcement with image (verify compression)
3. Create announcement with large image (> 3MB, verify compression)
4. Edit announcement - change text only
5. Edit announcement - replace image
6. Toggle active status
7. Delete announcement
8. Search announcements
9. Filter by type

### User Functions

1. View announcements list
2. Search announcements
3. Filter by type
4. Click announcement to view details
5. Verify images display correctly
6. Test login popup (create announcement with showOnLogin=true)

### Image Scenarios

1. Upload small image (< 1MB) - should not compress
2. Upload medium image (1-3MB) - should not compress
3. Upload large image (> 3MB) - should compress
4. Upload very large image (> 10MB) - should aggressively compress
5. Upload image > 1920px width - should resize

## Troubleshooting

### Images Not Uploading

**Issue:** "Converting object to an encodable object failed: Instance of 'MultipartFile'"

**Solution:** Use `http.MultipartRequest` instead of adding `MultipartFile` to regular Map. This is already implemented in the service methods.

### Dropdown Error

**Issue:** "There should be exactly one item with DropdownButton's value"

**Cause:** Old announcement with legacy type ('info', 'announce', etc.) not in new types list

**Solution:** Dialog validates type in `initState()` and defaults to 'general' if not in valid list

### Images Not Previewing in Dialog

**Issue:** Local file path not showing in create/edit dialog

**Cause:** Using `Image.network()` for local files

**Solution:** Use `Image.file(File(path))` for local files, `CachedNetworkImage` for URLs

### Login Popup Not Showing

**Check:**

1. Announcement has `showOnLogin = true`
2. Announcement has `isActive = true`
3. User has successfully authenticated
4. HomePage has loaded
5. Check debug logs for "HomePage - Showing X login announcements"

## Future Enhancements

- [ ] Add expiry date field for announcements
- [ ] Add author field to track who created announcement
- [ ] Add "read" status tracking for users
- [ ] Add push notification integration for urgent announcements
- [ ] Add rich text editor for content formatting
- [ ] Add multiple image support
- [ ] Add analytics for announcement views
- [ ] Add scheduling (publish at specific date/time)

## Related Documentation

- [API Documentation](./API_DOCUMENTATION.md) - API reference for announcement methods
- [Architecture](./ARCHITECTURE.md) - System architecture overview
- [PocketBase Permissions Setup](./POCKETBASE_PERMISSIONS_SETUP.md) - Security configuration
