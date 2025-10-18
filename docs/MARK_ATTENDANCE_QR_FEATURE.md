# Mark Attendance Page - User Selection Methods

## Overview

The Mark Attendance Page (`lib/app/pages/mark_attendance_page.dart`) provides admins with flexible methods to select users when marking attendance for meetings. This document details the implementation of the two user selection methods.

## User Selection Methods

### 1. Browse Users Method

A modal bottom sheet interface that allows admins to browse and search through all active members.

#### Implementation

**Modal Component**: `_UserBrowserModal`

Location: `lib/app/pages/mark_attendance_page.dart`

**Features**:

- Full list of active members
- Real-time search filtering
- Profile image display
- Member number and name display
- Smooth animations
- Pull-to-refresh support

**UI Structure**:

```
Modal Bottom Sheet
├── Handle bar (drag indicator)
├── Header
│   ├── Title: "Select Member"
│   └── Close button
├── Search Field
│   └── Real-time filtering
└── Scrollable User List
    └── User Tiles
        ├── Profile Image (CircleAvatar)
        ├── Member Info
        │   ├── Member Name
        │   └── Member Number
        └── Tap to select
```

**Code Flow**:

```dart
1. Admin taps "Browse Users" button
   ↓
2. showModalBottomSheet displays _UserBrowserModal
   ↓
3. Modal loads all users from PocketBase
   ↓
4. User can search to filter list
   ↓
5. User taps on a member
   ↓
6. Modal returns Map<String, String> with:
   - userId
   - memberNumber
   - memberName
   ↓
7. Selected user info displayed on form
```

**Search Implementation**:

```dart
// Filter users based on search query
final filteredUsers = users.where((user) {
  final query = _searchController.text.toLowerCase();
  final name = (user.data['firstName'] ?? '').toLowerCase() +
      ' ' +
      (user.data['lastName'] ?? '').toLowerCase();
  final memberNumber = (user.data['memberNumber'] ?? '').toLowerCase();

  return name.contains(query) || memberNumber.contains(query);
}).toList();
```

**User Tile Design**:

```dart
ListTile(
  leading: CircleAvatar(
    backgroundImage: profileImageUrl != null
        ? NetworkImage(profileImageUrl)
        : null,
    child: profileImageUrl == null ? Icon(Icons.person) : null,
  ),
  title: Text(memberName),
  subtitle: Text('Member #$memberNumber'),
  onTap: () => Navigator.pop(context, {
    'userId': user.id,
    'memberNumber': memberNumber,
    'memberName': memberName,
  }),
)
```

#### User Experience

**Loading State**:

- Shows circular progress indicator while fetching users
- Prevents interaction during load

**Empty State**:

- Displays "No members found" when search returns no results
- Provides clear feedback

**Error State**:

- Shows error message if user fetch fails
- Option to retry

**Performance Optimization**:

- Loads all users once on modal open
- Real-time search filters cached data (no additional API calls)
- Efficient list rendering with ListView.builder

### 2. QR Code Scanning Method

A camera-based interface that scans member QR codes for quick selection.

#### Implementation

**Modal Component**: `_UserQRScannerModal`

Location: `lib/app/pages/mark_attendance_page.dart`

**Features**:

- Live camera preview
- QR code detection
- Visual scanning overlay
- Torch/flashlight toggle
- Error handling for invalid codes
- Smooth camera lifecycle management

**UI Structure**:

```
Modal Bottom Sheet (Full Height)
├── Scanner View
│   ├── MobileScanner (camera preview)
│   ├── Scanning Overlay
│   │   └── Semi-transparent frame
│   └── Torch Toggle Button
├── Instructions
│   └── "Scan member QR code"
└── Close Button
```

**Code Flow**:

```dart
1. Admin taps "Scan QR Code" button
   ↓
2. showModalBottomSheet displays _UserQRScannerModal
   ↓
3. MobileScanner initializes camera
   ↓
4. User points camera at QR code
   ↓
5. Scanner detects barcode
   ↓
6. Extract user ID from QR data
   ↓
7. Fetch user details from PocketBase
   ↓
8. Validate user exists and is active
   ↓
9. Modal returns Map<String, String> with:
   - userId
   - memberNumber
   - memberName
   ↓
10. Selected user info displayed on form
```

**QR Code Format**:

The scanner expects QR codes containing user IDs in the following format:

```
user_id_string
```

Or JSON format:

```json
{
  "userId": "user_id_string",
  "memberNumber": "M001"
}
```

**Scanner Configuration**:

```dart
MobileScanner(
  controller: MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: _torchEnabled,
  ),
  onDetect: (capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        await _processQRCode(barcode.rawValue!);
      }
    }
  },
)
```

**QR Code Processing**:

```dart
Future<void> _processQRCode(String qrData) async {
  // Prevent multiple scans
  if (_isProcessing) return;
  _isProcessing = true;

  try {
    // Extract user ID from QR data
    final userId = _extractUserId(qrData);

    // Fetch user details from PocketBase
    final user = await _pocketbaseService.getUser(userId);

    // Validate user
    if (!user.data['isActive']) {
      throw Exception('User is inactive');
    }

    // Return user info
    Navigator.pop(context, {
      'userId': user.id,
      'memberNumber': user.data['memberNumber'],
      'memberName': '${user.data['firstName']} ${user.data['lastName']}',
    });
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
    _isProcessing = false;
  }
}
```

#### User Experience

**Permission Handling**:

- Requests camera permission on first use
- Shows permission denied message if rejected
- Provides instructions to enable in settings

**Torch Control**:

- Toggle button for flashlight in low light
- Icon updates to reflect torch state
- Accessible from scanner view

**Feedback**:

- Haptic feedback on successful scan
- Visual confirmation animation
- Error messages for invalid codes
- Automatic modal close on success

**Error Handling**:

```dart
try {
  // Scan and process QR code
} on NotFoundException catch (e) {
  showError('User not found');
} on FormatException catch (e) {
  showError('Invalid QR code format');
} catch (e) {
  showError('Error scanning QR code: ${e.toString()}');
}
```

**Camera Lifecycle**:

- Properly initialized on modal open
- Disposed on modal close
- Handles app lifecycle (pause/resume)

## Integration with Mark Attendance Form

### Form State Management

The selected user information is stored in the page state:

```dart
String? _selectedUserId;
String? _selectedMemberNumber;
String? _selectedMemberName;
```

### User Selection Display

After selection, the form displays:

```dart
if (_selectedUserId != null) {
  Container(
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: OpstechColors.lightGray,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        Icon(Icons.person, size: 24.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedMemberName!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Member #$_selectedMemberNumber',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              _selectedUserId = null;
              _selectedMemberNumber = null;
              _selectedMemberName = null;
            });
          },
        ),
      ],
    ),
  )
}
```

### Validation

Before marking attendance:

```dart
void _markAttendance() {
  if (!_formKey.currentState!.validate()) return;

  // Validate user selection
  if (_selectedUserId == null ||
      _selectedMemberNumber == null ||
      _selectedMemberName == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a member first'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Mark attendance via cubit
  context.read<AttendanceCubit>().markAttendance(
    userId: _selectedUserId!,
    memberNumber: _selectedMemberNumber!,
    memberName: _selectedMemberName!,
    meetingId: widget.meetingId,
    meetingDate: DateTime.now(),
    status: _selectedStatus.value,
    checkInMethod: 'manual',
    notes: _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim(),
  );
}
```

## UI/UX Best Practices

### 1. Accessibility

- Clear button labels
- Sufficient tap targets (minimum 48x48 dp)
- Screen reader support
- High contrast colors

### 2. Performance

- Lazy loading of user list
- Efficient search filtering
- Optimized camera preview
- Proper resource disposal

### 3. Error Handling

- Graceful error messages
- Clear recovery actions
- No silent failures
- User-friendly language

### 4. Feedback

- Loading indicators
- Success confirmations
- Error alerts
- Progress visibility

## Dependencies

### Browse Users Method

- `PocketBaseService`: User data fetching
- `flutter_screenutil`: Responsive sizing
- `flutter/material`: UI components

### QR Scanner Method

- `mobile_scanner`: QR code scanning
- `PocketBaseService`: User validation
- `flutter/services`: Haptic feedback
- `flutter_screenutil`: Responsive sizing

## Configuration

### Camera Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan member QR codes</string>
```

## Testing

### Unit Tests

- User selection logic
- QR code parsing
- Error handling
- Validation

### Widget Tests

- Modal rendering
- Search functionality
- Scanner initialization
- User interaction

### Integration Tests

- End-to-end user selection flow
- QR scanning workflow
- Error scenarios
- Network failures

## Future Enhancements

### Browse Users Method

- Pagination for large member lists
- Advanced filtering (by status, membership type)
- Recent selections history
- Favorites/pinned members

### QR Scanner Method

- Batch QR scanning (multiple members at once)
- Offline QR validation
- Custom QR code generator for members
- QR code history/audit trail

## Related Documentation

- [Attendance Implementation Guide](./ATTENDANCE_IMPLEMENTATION.md)
- [Mark Attendance Page Component](../lib/app/pages/mark_attendance_page.dart)
- [Architecture Documentation](./ARCHITECTURE.md)
- [Developer Guide](./DEVELOPER_GUIDE.md)

## Summary

The Mark Attendance Page provides a flexible, user-friendly interface for admins to mark attendance using either browsing or QR scanning methods. Both methods are optimized for performance, accessibility, and error handling, ensuring a smooth user experience in various scenarios.
