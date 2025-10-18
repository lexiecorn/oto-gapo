# Mark Attendance QR Code Feature

## Overview

Added two methods for marking attendance in the Mark Attendance page:

1. **Browse Users** - Search and select from a list of all members
2. **Scan QR Code** - Quick scan of a member's QR code to auto-fill their details

## Implementation Details

### Components Added

#### 1. Mark Attendance Page Updates (`lib/app/pages/mark_attendance_page.dart`)

**New Features:**

- Two selection cards for choosing between Browse and Scan methods
- User browser modal with search functionality
- QR code scanner modal with camera controls
- Display-only selected member information (no manual text input)
- Clear button to remove selection and choose a different member

**Key Methods:**

- `_browseUsers()` - Opens modal to browse and search users
- `_scanQRCode()` - Opens camera modal to scan user QR codes
- Stores member number, name, and user ID in state variables (no text fields)

#### 2. User Browser Modal (`_UserBrowserModal`)

**Features:**

- Search by name or member number
- Real-time filtering
- Profile image display
- Loading and error states
- Pulls user list from PocketBase

**UI Elements:**

- Search bar with real-time filtering
- User list with avatar, name, and member number
- Pull to refresh functionality
- Error handling with retry button

#### 3. QR Scanner Modal (`_UserQRScannerModal`)

**Features:**

- Full-screen camera scanner
- QR code validation (format: `USER:{userId}:{memberNumber}`)
- Flashlight toggle
- Camera switch (front/back)
- Scanning overlay with corner guides
- User validation against PocketBase

**Security:**

- Validates QR code format
- Fetches and verifies user from PocketBase
- Error handling for invalid codes

### User Flow

1. **Browse Method:**

   - User taps "Browse" card
   - Modal opens with searchable user list
   - User searches/scrolls to find member
   - Taps member to select
   - Selected member details display in colored card
   - User can tap "X" button to clear and select different member

2. **Scan Method:**
   - User taps "Scan QR" card
   - Camera modal opens
   - User aligns member's QR code in frame
   - App validates QR code format
   - App fetches user details from PocketBase
   - Selected member details display in colored card
   - Modal closes automatically
   - User can tap "X" button to clear and scan different member

### QR Code Format

Member QR codes must follow this format:

```
USER:{userId}:{memberNumber}
```

Example: `USER:abc123xyz:12345`

This format is generated in `lib/app/pages/user_qr_code_page.dart` (line 59).

### Check-in Method Tracking

The system automatically tracks the check-in method:

- `'manual'` - When user types in details manually
- `'qr_scan'` - When user is selected via Browse or QR Scan

This is stored in the attendance record for reporting purposes.

### Dependencies

- `mobile_scanner` - For QR code scanning
- `PocketBaseService` - For fetching user data
- `flutter_screenutil` - For responsive UI sizing

### UI/UX Improvements

1. **Clear Selection Options**: Two prominent cards make it obvious users have two methods
2. **Visual Feedback**: Selected user shows in a colored card with name, member number, and avatar
3. **No Manual Entry**: Removes redundant text fields - all selection via Browse or Scan
4. **Clear Selection**: "X" button allows administrators to quickly change their selection
5. **Info Message**: When no member selected, shows helpful message to guide user
6. **Search Functionality**: Quick filtering in browse mode
7. **Camera Controls**: Flashlight and camera switch for better scanning
8. **Error Handling**: Clear error messages for invalid QR codes or failed user fetches
9. **Validation**: Prevents form submission without a member selection

## Usage

### For Administrators

1. Navigate to Meeting Details page
2. Tap "Mark" button
3. Choose method:
   - **Browse**: Search and select from user list
   - **Scan QR**: Scan member's QR code from their profile
4. Selected member displays in colored card
5. (Optional) Tap "X" button on card to clear and select different member
6. Select attendance status (Present, Absent, Late, Excused)
7. Add optional notes
8. Tap "Mark Attendance"

### For Members

To use the QR scan feature:

1. Open your profile
2. Navigate to "My QR Code"
3. Show QR code to administrator
4. Administrator scans your code
5. Attendance is marked instantly

## Technical Notes

### PocketBase Integration

- Uses `PocketBaseService.getAllUsers()` to fetch user list
- Uses `PocketBaseService.getUser(userId)` to fetch individual user details
- Handles authentication automatically via shared PocketBase instance

### Error Handling

- Invalid QR code format: "Invalid user QR code"
- User not found in database: "User not found"
- Network errors: Displayed with retry option
- Camera permission denied: Handled by mobile_scanner package

### Performance

- User list is loaded once and cached in modal
- Search filtering happens locally (no API calls)
- QR scanning processes at camera frame rate
- Duplicate scans prevented with `_isProcessing` flag

## Future Enhancements

Potential improvements:

1. Bulk attendance marking (scan multiple QR codes in sequence)
2. Offline mode with sync
3. NFC support for contactless check-in
4. Face recognition as alternative to QR
5. Barcode support for member cards
6. Export attendance with check-in method analytics
