# API Documentation - OtoGapo

## Overview

OtoGapo uses a hybrid backend approach combining Firebase for authentication and PocketBase for data management. This document provides comprehensive API documentation for all services and endpoints.

## Recent Updates

### File Upload Migration (Latest)

**Migration from Firebase Storage to PocketBase**

The application has been fully migrated from Firebase Storage to PocketBase for all file uploads and storage operations:

- **Profile Images**: Now stored in PocketBase with direct HTTP multipart requests
- **Car Images**: All vehicle photos managed through PocketBase
- **Gallery Images**: Homepage carousel images stored in PocketBase
- **File URLs**: Constructed using PocketBase file serving endpoints

**Key Changes:**

1. **Removed Firebase Storage Dependencies**: No longer uses `firebase_storage` package
2. **Direct HTTP Uploads**: Files uploaded using `http.MultipartRequest` to avoid JSON serialization issues
3. **PocketBase File URLs**: Images served via `{pocketbaseUrl}/api/files/{collection}/{recordId}/{filename}`
4. **Enhanced Error Handling**: Comprehensive debugging and error reporting for file operations

**Benefits:**

- **Unified Backend**: Single backend for all data and file operations
- **Better Performance**: Direct file serving without Firebase overhead
- **Simplified Architecture**: Reduced complexity with one backend system
- **Cost Efficiency**: No Firebase Storage usage costs

## Table of Contents

- [Authentication Services](#authentication-services)
- [PocketBase Service](#pocketbase-service)
- [User Management](#user-management)
- [Payment Management](#payment-management)
- [Admin Services](#admin-services)
- [Data Models](#data-models)
- [Error Handling](#error-handling)

## Authentication Services

### Firebase Authentication

The app uses Firebase Authentication for primary authentication with Google Sign-In support.

#### Repository: `AuthRepository`

Located in `packages/authentication_repository/lib/src/`

**Methods:**

```dart
// Sign in with Google
Future<User> signInWithGoogle({required String idToken, String? displayName})

// Sign out
Future<void> signOut()

// Get current user
Stream<User?> get user

// Check authentication status
bool get isAuthenticated
```

### PocketBase Authentication

Secondary authentication layer using PocketBase for enhanced user management.

#### Repository: `PocketBaseAuthRepository`

Located in `packages/authentication_repository/lib/src/pocketbase_auth_repository.dart`

**Methods:**

```dart
// Sign in with email/password
Future<void> signIn({required String email, required String password})

// Sign up new user
Future<void> signUp({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  Map<String, dynamic>? additionalData
})

// Sign out
Future<void> signOut()

// Get current user
RecordModel? get currentUser

// Check authentication status
bool get isAuthenticated

// Listen to auth changes
Stream<RecordModel?> get user
```

## PocketBase Service

### Main Service Class

Located in `lib/services/pocketbase_service.dart`

The `PocketBaseService` class provides comprehensive data management functionality.

#### Configuration

```dart
class PocketBaseService {
  // Singleton instance
  static final PocketBaseService _instance = PocketBaseService._internal();

  // Lazy initialization with flavor-specific URL
  PocketBase get pb {
    if (!_isInitialized) {
      _pb = PocketBase(FlavorConfig.instance.variables['pocketbaseUrl'] as String);
      _isInitialized = true;
    }
    return _pb!;
  }
}
```

#### Authentication Methods

```dart
// Ensure user is authenticated before operations
Future<void> _ensureAuthenticated()

// Get user by Firebase UID
Future<RecordModel?> getUserByFirebaseUid(String firebaseUid)

// Create user with Firebase UID
Future<RecordModel> createUserWithFirebaseUid({
  required String firebaseUid,
  required String email,
  required String firstName,
  required String lastName,
  Map<String, dynamic>? additionalData
})
```

Notes:

- The service automatically sets `joinedDate` to the current timestamp on user creation unless explicitly provided in `additionalData`.

## User Management

### User CRUD Operations

#### Get User Data

```dart
// Get user by ID
Future<RecordModel> getUser(String userId)

// Get all users (admin only)
Future<List<RecordModel>> getAllUsers()
```

#### Create User

```dart
// Create new user
Future<RecordModel> createUserWithFirebaseUid({
  required String firebaseUid,
  required String email,
  required String firstName,
  required String lastName,
  Map<String, dynamic>? additionalData
})
```

#### Update User

```dart
// Update user data (handles both regular data and file uploads)
Future<RecordModel> updateUser(String userId, Map<String, dynamic> data)

// Update user profile with detailed information
Future<RecordModel> updateUserProfile({
  required String userId,
  String? firstName,
  String? lastName,
  String? middleName,
  String? contactNumber,
  String? age,
  String? dateOfBirth,
  String? birthplace,
  String? bloodType,
  String? civilStatus,
  String? gender,
  String? nationality,
  String? religion,
  String? driversLicenseNumber,
  String? driversLicenseExpirationDate,
  String? driversLicenseRestrictionCode,
  String? emergencyContactName,
  String? emergencyContactNumber,
  String? spouseName,
  String? spouseContactNumber,
  String? memberNumber,
  int? membershipType,
  bool? isActive,
  bool? isAdmin,
  Map<String, dynamic>? vehicle,
  String? joinedDate
})
```

#### File Upload Support

The `updateUser` method now supports file uploads for profile images and car images:

```dart
// Upload profile image
final result = await pocketBaseService.updateUser(userId, {
  'profileImage': File('/path/to/image.jpg'),
  'updatedAt': DateTime.now().toIso8601String(),
});

// Upload car images
final result = await pocketBaseService.updateUser(userId, {
  'carImage1': File('/path/to/car1.jpg'),
  'carImage2': File('/path/to/car2.jpg'),
  'carImagemain': File('/path/to/main_car.jpg'),
  'updatedAt': DateTime.now().toIso8601String(),
});
```

**File Upload Implementation:**

The service automatically handles file uploads using direct HTTP multipart requests to avoid JSON serialization issues:

1. **Separates file uploads from regular data** - Files and regular data are processed separately
2. **Uses direct HTTP requests** - Bypasses PocketBase client JSON serialization for files
3. **Proper multipart handling** - Uses `http.MultipartRequest` for file uploads
4. **Authentication preserved** - Maintains PocketBase authentication tokens
5. **Error handling** - Comprehensive error reporting and debugging

**Supported File Fields:**

- `profileImage` - User profile picture
- `carImage1`, `carImage2`, `carImage3`, `carImage4` - Car photos
- `carImagemain` - Primary car photo

### User Profile Fields

The user profile supports the following fields:

#### Personal Information

- `firstName` - First name
- `lastName` - Last name
- `middleName` - Middle name (optional)
- `age` - Age
- `dateOfBirth` - Date of birth
- `birthplace` - Place of birth
- `gender` - Gender
- `nationality` - Nationality
- `religion` - Religion
- `civilStatus` - Civil status

#### Contact Information

- `contactNumber` - Primary contact number
- `emergencyContactName` - Emergency contact name
- `emergencyContactNumber` - Emergency contact number
- `spouseName` - Spouse name (if applicable)
- `spouseContactNumber` - Spouse contact number

#### Driver's License Information

- `driversLicenseNumber` - License number
- `driversLicenseExpirationDate` - Expiration date
- `driversLicenseRestrictionCode` - Restriction codes

#### Medical Information

- `bloodType` - Blood type
- `emergencyContactName` - Emergency contact for medical

#### Membership Information

- `memberNumber` - Unique member number
- `membershipType` - Membership level (1=Super Admin, 2=Admin, 3=Member)
- `isActive` - Account status
- `isAdmin` - Admin privileges
- `joinedDate` - Date the user joined (ISO 8601 string)

#### Vehicle Information

- `vehicle` - Vehicle details (Map<String, dynamic>)

Note: Each user has exactly one vehicle. The `vehicle` field is a single object. For backward compatibility, older records may store `vehicle` as a single-element array; the app reads the first item and always writes back a single object.

## Payment Management

### Payment Transactions System

The app uses a modern payment tracking system with explicit status fields, payment methods, and admin audit trails.

> **Note:** The old `MonthlyDues` model is deprecated. Use `PaymentTransaction` for all new code.

#### Data Models

##### PaymentTransaction

Located in `lib/models/payment_transaction.dart`

```dart
class PaymentTransaction {
  final String id;
  final String userId;
  final String month;                // Format: "YYYY-MM"
  final double amount;
  final PaymentStatus status;        // pending, paid, waived
  final DateTime? paymentDate;
  final PaymentMethod? paymentMethod; // cash, bank_transfer, gcash, other
  final String? recordedBy;          // Admin user ID
  final String? notes;
  final DateTime created;
  final DateTime updated;

  // Computed properties
  bool get isPaid => status == PaymentStatus.paid;
  bool get isPending => status == PaymentStatus.pending;
  bool get isWaived => status == PaymentStatus.waived;
  bool get isOverdue; // pending + month before current
  DateTime get monthDate;
  String get paymentMethodDisplay;
}

enum PaymentStatus { pending, paid, waived }
enum PaymentMethod { cash, bankTransfer, gcash, other }
```

##### PaymentStatistics

Located in `lib/models/payment_statistics.dart`

```dart
class PaymentStatistics {
  final int totalMonths;           // Total months user should have paid
  final int paidCount;             // Number of paid months
  final int pendingCount;          // Number of pending months
  final int waivedCount;           // Number of waived months
  final int overdueCount;          // Number of overdue months
  final double totalPaidAmount;    // Total amount paid
  final double totalExpectedAmount; // Total expected amount
  final DateTime? lastPaymentDate;
  final String? lastPaymentMethod;

  // Computed properties
  double get paymentPercentage;
  bool get isUpToDate;
}
```

#### Payment Operations

All operations are handled through `PocketBaseService`:

```dart
// Get all transactions for a user
Future<List<PaymentTransaction>> getPaymentTransactions(String userId)

// Get specific month transaction
Future<PaymentTransaction?> getPaymentTransaction(String userId, String month)

// Create or update a transaction
Future<PaymentTransaction> updatePaymentTransaction({
  required String userId,
  required String month,      // Format: "YYYY-MM"
  required PaymentStatus status,
  DateTime? paymentDate,
  PaymentMethod? paymentMethod,
  String? notes,
  String? recordedBy,         // Admin user ID
})

// Delete a transaction
Future<void> deletePaymentTransaction(String transactionId)

// Get payment statistics for a user
Future<PaymentStatistics> getPaymentStatistics(String userId)

// Get expected months from join date to current
List<String> getExpectedMonths(DateTime joinedDate)

// Initialize payment records for a user
Future<void> initializePaymentRecords(String userId, DateTime joinedDate)

// Get admin name for audit trail
Future<String> getRecordedByName(String? recordedById)

// Subscribe to real-time updates
Future<UnsubscribeFunc> subscribeToPaymentTransactions(
  void Function(RecordModel) onUpdate
)
```

#### Payment Status Values

- **`pending`** - Payment not yet received
- **`paid`** - Payment completed and recorded
- **`waived`** - Payment waived by admin (no payment required)

#### Month is Overdue When:

- Status is `pending` AND
- Month is before current month

**Example Usage:**

```dart
// Record a payment (admin operation)
final currentAdminId = context.read<AuthBloc>().state.user?.id;
final transaction = await pocketBaseService.updatePaymentTransaction(
  userId: 'user123',
  month: '2025-10',
  status: PaymentStatus.paid,
  paymentDate: DateTime.now(),
  paymentMethod: PaymentMethod.cash,
  notes: 'Paid in full',
  recordedBy: currentAdminId,
);

// Get user's payment statistics
final stats = await pocketBaseService.getPaymentStatistics('user123');
print('Paid ${stats.paidCount} of ${stats.totalMonths} months');
print('Payment percentage: ${stats.paymentPercentage}%');
print('Overdue: ${stats.overdueCount}');

// Get specific month transaction
final octoberPayment = await pocketBaseService.getPaymentTransaction(
  'user123',
  '2025-10',
);
if (octoberPayment != null && octoberPayment.isPaid) {
  print('October 2025 is paid via ${octoberPayment.paymentMethodDisplay}');
}

// Initialize records for a new user
await pocketBaseService.initializePaymentRecords(
  'user123',
  DateTime(2024, 1), // Joined January 2024
);
```

#### PocketBase Schema

**Collection:** `payment_transactions`

| Field          | Type     | Required | Description                       |
| -------------- | -------- | -------- | --------------------------------- |
| id             | text     | Yes      | Auto-generated unique ID          |
| user           | relation | Yes      | Reference to users collection     |
| month          | text     | Yes      | Payment month "YYYY-MM"           |
| amount         | number   | Yes      | Payment amount (default: 100)     |
| status         | select   | Yes      | pending, paid, or waived          |
| payment_date   | date     | No       | Date payment was made             |
| payment_method | select   | No       | cash, bank_transfer, gcash, other |
| recorded_by    | relation | No       | Admin who recorded payment        |
| notes          | text     | No       | Optional notes                    |
| created        | autodate | Yes      | Record creation timestamp         |
| updated        | autodate | Yes      | Record update timestamp           |

**Indexes:**

- Unique index on `(user, month)` prevents duplicates
- Index on `status` for faster filtering
- Index on `payment_date` for sorting

**API Rules:**

```javascript
// List/View: Users see their own, admins see all
@request.auth.id != "" && (user = @request.auth.id || @request.auth.isAdmin = true)

// Create/Update/Delete: Only admins
@request.auth.id != "" && @request.auth.isAdmin = true
```

#### Benefits Over Old System

1. **Explicit status field** - No inferring from payment_date existence
2. **Unique constraint** - Prevents duplicate entries automatically
3. **Payment methods** - Track how payments were made
4. **Audit trail** - Know who recorded each payment
5. **Clean API** - Simpler, more maintainable code
6. **Better UX** - Users see detailed payment history

For complete documentation, see [docs/PAYMENT_SYSTEM.md](./PAYMENT_SYSTEM.md)

## Admin Services

### User Management (Admin)

```dart
// Get all users with sorting
Future<List<RecordModel>> getAllUsers()

// Update user membership type
Future<RecordModel> updateUser(String userId, {
  int? membershipType,
  bool? isActive,
  bool? isAdmin
})
```

### Announcement Management

The announcement system provides full CRUD operations with image support, type categorization, and login popup functionality.

#### Collection Schema

- **Collection Name**: `Announcements`
- **Fields**:
  - `title` (text) - Announcement title
  - `content` (text) - Announcement body content
  - `type` (select) - Type: general, important, urgent, event, reminder, success
  - `img` (file) - Optional image (max 3MB, thumbnails: 100x100t, 300x300t, 600x400t)
  - `showOnLogin` (bool) - Display as popup when user logs in
  - `isActive` (bool) - Toggle visibility to users
  - `created` (autodate) - Creation timestamp
  - `updated` (autodate) - Last update timestamp

#### Service Methods

```dart
// Get all announcements
Future<List<RecordModel>> getAnnouncements()

// Get announcements for login popup
Future<List<RecordModel>> getLoginAnnouncements()

// Create announcement with optional image
Future<RecordModel> createAnnouncement({
  required String title,
  required String content,
  String? type,              // Default: 'general'
  String? imageFilePath,     // Auto-compressed to 3MB
  bool showOnLogin = false,  // Show as login popup
  bool isActive = true,      // Visible to users
})

// Update announcement
Future<RecordModel> updateAnnouncement({
  required String announcementId,
  String? title,
  String? content,
  String? type,
  String? imageFilePath,     // Replace image if provided
  bool? showOnLogin,
  bool? isActive,
})

// Delete announcement
Future<void> deleteAnnouncement(String announcementId)

// Toggle active status
Future<RecordModel> toggleAnnouncementActive(String announcementId)

// Get announcement image URL
String getAnnouncementImageUrl(
  RecordModel announcement,
  {String? thumb}  // e.g., '100x100t', '300x300t', '600x400t'
)

// Subscribe to announcement updates (real-time)
Future<UnsubscribeFunc> subscribeToAnnouncements(
  void Function(RecordModel) onUpdate
)
```

#### Announcement Types

| Type      | Color  | Icon          | Use Case                     |
| --------- | ------ | ------------- | ---------------------------- |
| general   | Blue   | info          | Regular updates, news        |
| important | Orange | priority_high | High-priority matters        |
| urgent    | Red    | warning       | Critical, time-sensitive     |
| event     | Purple | event         | Meetings, activities         |
| reminder  | Teal   | notifications | Payment reminders, deadlines |
| success   | Green  | check_circle  | Achievements, good news      |

#### Image Handling

- **Automatic Compression**: Images are automatically compressed to 3MB max before upload
- **Quality Target**: 80-85% JPEG quality
- **Resize**: Images wider than 1920px are resized while preserving aspect ratio
- **Thumbnails**: PocketBase generates 100x100, 300x300, and 600x400 thumbnails
- **Supported Formats**: JPEG, PNG, WebP, GIF, SVG

#### Login Popup Feature

Announcements with `showOnLogin = true` automatically display as popups when users open the app:

```dart
// In HomePage after authentication
final announcements = await PocketBaseService().getLoginAnnouncements();
if (announcements.isNotEmpty) {
  await AnnouncementPopupDialog.showLoginAnnouncements(
    context,
    announcements,
    PocketBaseService().getAnnouncementImageUrl,
  );
}
```

**Behavior**:

- Shows all announcements with `showOnLogin = true` and `isActive = true`
- Displays sequentially if multiple announcements exist
- Shows every time user opens the app (once per session)
- Beautiful dialog with image support and type-based styling

### App Data Management

```dart
// Get app configuration data
Future<RecordModel?> getAppData(String key)

// Set app configuration data
Future<RecordModel> setAppData({
  required String key,
  required dynamic value,
  String? description,
  String? category
})
```

## Attendance Management

### Attendance Repository

Located in `packages/attendance_repository/lib/src/attendance_repository.dart`

The Attendance Repository provides comprehensive meeting and attendance management functionality.

#### Repository Class

```dart
class AttendanceRepository {
  final PocketBase pb;

  AttendanceRepository(this.pb);
}
```

#### Meeting Operations

```dart
// Create a new meeting
Future<Meeting> createMeeting({
  required DateTime meetingDate,
  required String meetingType,
  required String title,
  required String createdBy,
  String? location,
  DateTime? startTime,
  DateTime? endTime,
  String? description,
  int? totalExpectedMembers,
})

// Get all meetings with optional filters
Future<List<Meeting>> getMeetings({
  String? status,
  String? meetingType,
  DateTime? startDate,
  DateTime? endDate,
  int? page,
  int? perPage,
})

// Get specific meeting by ID
Future<Meeting> getMeetingById(String meetingId)

// Update meeting
Future<Meeting> updateMeeting(String meetingId, Map<String, dynamic> data)

// Delete meeting
Future<void> deleteMeeting(String meetingId)

// Generate QR code for meeting
Future<Meeting> generateMeetingQRCode(String meetingId)

// Validate QR code token
Future<Meeting?> validateQRCode(String token)
```

#### Attendance Operations

```dart
// Mark attendance for a user
Future<Attendance> markAttendance({
  required String userId,
  required String memberNumber,
  required String memberName,
  required String meetingId,
  required DateTime meetingDate,
  required String meetingTitle,
  required String status,
  String? checkInMethod,
  String? markedBy,
  String? notes,
  String? profileImage,
})

// Get attendance records for a meeting
Future<List<Attendance>> getMeetingAttendance(String meetingId)

// Get attendance records for a user
Future<List<Attendance>> getUserAttendance(String userId)

// Update attendance status
Future<Attendance> updateAttendance(
  String attendanceId,
  Map<String, dynamic> data,
)

// Delete attendance record
Future<void> deleteAttendance(String attendanceId)
```

#### Attendance Summary Operations

```dart
// Get user's attendance summary
Future<AttendanceSummary?> getUserSummary(String userId)

// Update user's attendance summary
Future<AttendanceSummary> updateUserSummary(
  String userId,
  Map<String, dynamic> data,
)
```

#### Meeting Count Updates

```dart
// Update meeting attendance counts
Future<Meeting> updateMeetingCounts(String meetingId)
```

#### CSV Export

```dart
// Export meeting attendance to CSV
String exportAttendanceToCsv(List<Attendance> attendanceList)
```

### Attendance Data Models

#### Meeting Model

Located in `lib/models/meeting.dart`

```dart
class Meeting {
  final String id;
  final DateTime meetingDate;
  final MeetingType meetingType;
  final String title;
  final String? location;
  final DateTime? startTime;
  final DateTime? endTime;
  final MeetingStatus status;
  final String createdBy;
  final String? qrCodeToken;
  final DateTime? qrCodeExpiry;
  final int? totalExpectedMembers;
  final int? presentCount;
  final int? absentCount;
  final int? lateCount;
  final int? excusedCount;
  final String? description;
  final DateTime created;
  final DateTime updated;

  // Computed properties
  bool get hasActiveQRCode;
  bool get isUpcoming;
  bool get isPast;
  int get totalAttended;
  double? get attendanceRate;
}

enum MeetingType {
  regular,
  gmm,      // General Member Meeting
  special,
  emergency,
}

enum MeetingStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}
```

#### Attendance Model

Located in `lib/models/attendance.dart`

```dart
class Attendance {
  final String id;
  final String userId;
  final String memberNumber;
  final String memberName;
  final String? profileImage;
  final String meetingId;
  final DateTime meetingDate;
  final String meetingTitle;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final CheckInMethod? checkInMethod;
  final String? markedBy;
  final String? notes;
  final DateTime created;
  final DateTime updated;

  // Computed properties
  bool get isPresent;
  bool get isAbsent;
  bool get isLate;
  String get statusDisplay;
  String get checkInMethodDisplay;
}

enum AttendanceStatus {
  present,
  late,
  absent,
  excused,
  leave,
}

enum CheckInMethod {
  manual,
  qrScan,
  auto,
}
```

#### AttendanceSummary Model

Located in `lib/models/attendance_summary.dart`

```dart
class AttendanceSummary {
  final String id;
  final String userId;
  final int totalMeetings;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalExcused;
  final double attendanceRate;
  final DateTime created;
  final DateTime updated;

  // Computed properties
  int get totalAttended; // present + late + excused
  double get presentPercentage;
  double get latePercentage;
  double get absentPercentage;
}
```

### Attendance PocketBase Collections

#### meetings Collection

| Field                | Type     | Required | Description                              |
| -------------------- | -------- | -------- | ---------------------------------------- |
| id                   | text     | Yes      | Auto-generated unique ID                 |
| meetingDate          | date     | Yes      | Date and time of meeting                 |
| meetingType          | select   | Yes      | regular, gmm, special, emergency         |
| title                | text     | Yes      | Meeting title                            |
| location             | text     | No       | Meeting location                         |
| startTime            | date     | No       | Meeting start time                       |
| endTime              | date     | No       | Meeting end time                         |
| status               | select   | Yes      | scheduled, ongoing, completed, cancelled |
| createdBy            | relation | Yes      | Reference to users collection            |
| qrCodeToken          | text     | No       | QR code token for check-in               |
| qrCodeExpiry         | date     | No       | QR code expiration time                  |
| totalExpectedMembers | number   | No       | Expected number of attendees             |
| presentCount         | number   | No       | Number of present members                |
| absentCount          | number   | No       | Number of absent members                 |
| lateCount            | number   | No       | Number of late members                   |
| excusedCount         | number   | No       | Number of excused members                |
| description          | text     | No       | Meeting description                      |
| created              | autodate | Yes      | Record creation timestamp                |
| updated              | autodate | Yes      | Record update timestamp                  |

**API Rules:**

```javascript
// List/View: All authenticated users
List/View: @request.auth.id != ""

// Create/Update: Admin only
Create/Update: @request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

// Delete: Super Admin only
Delete: @request.auth.membership_type = 1
```

#### attendance Collection

| Field         | Type     | Required | Description                           |
| ------------- | -------- | -------- | ------------------------------------- |
| id            | text     | Yes      | Auto-generated unique ID              |
| userId        | relation | Yes      | Reference to users collection         |
| memberNumber  | text     | Yes      | Cached member number                  |
| memberName    | text     | Yes      | Cached member name                    |
| profileImage  | url      | No       | Cached profile image URL              |
| meetingId     | relation | Yes      | Reference to meetings collection      |
| meetingDate   | date     | Yes      | Cached meeting date                   |
| meetingTitle  | text     | Yes      | Cached meeting title                  |
| status        | select   | Yes      | present, late, absent, excused, leave |
| checkInTime   | date     | No       | Time of check-in                      |
| checkInMethod | select   | No       | manual, qr_scan, auto                 |
| markedBy      | relation | No       | Admin who marked attendance           |
| notes         | text     | No       | Optional notes                        |
| created       | autodate | Yes      | Record creation timestamp             |
| updated       | autodate | Yes      | Record update timestamp               |

**Unique Index:** `(userId, meetingId)` prevents duplicate attendance records

**API Rules:**

```javascript
// List/View: Users see their own, admins see all
List/View: @request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

// Create: Admin or user via QR scan
Create: @request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || (userId = @request.auth.id && checkInMethod = "qr_scan")

// Update: Admin only
Update: @request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

// Delete: Super Admin only
Delete: @request.auth.membership_type = 1
```

#### attendance_summary Collection

| Field          | Type     | Required | Description                   |
| -------------- | -------- | -------- | ----------------------------- |
| id             | text     | Yes      | Auto-generated unique ID      |
| userId         | relation | Yes      | Reference to users collection |
| totalMeetings  | number   | No       | Total meetings held           |
| totalPresent   | number   | No       | Number of present attendances |
| totalAbsent    | number   | No       | Number of absent records      |
| totalLate      | number   | No       | Number of late check-ins      |
| totalExcused   | number   | No       | Number of excused absences    |
| attendanceRate | number   | No       | Overall attendance percentage |
| created        | autodate | Yes      | Record creation timestamp     |
| updated        | autodate | Yes      | Record update timestamp       |

**Unique Index:** `userId` ensures one summary per user

**API Rules:**

```javascript
// List/View: Users see their own, admins see all
List/View: @request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

// Create/Update: Admin only
Create/Update: @request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

// Delete: Super Admin only
Delete: @request.auth.membership_type = 1
```

### Attendance Error Handling

The attendance repository uses custom error types for clear error handling:

```dart
class AttendanceFailure {
  final String message;
  final String code;

  AttendanceFailure(this.message, this.code);

  // Common error codes
  static const String duplicateAttendance = 'DUPLICATE_ATTENDANCE';
  static const String meetingNotFound = 'MEETING_NOT_FOUND';
  static const String invalidQRCode = 'INVALID_QR_CODE';
  static const String qrCodeExpired = 'QR_CODE_EXPIRED';
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String networkError = 'NETWORK_ERROR';
}
```

### Usage Example

```dart
// Initialize repository
final attendanceRepository = AttendanceRepository(pocketBase);

// Create a meeting
final meeting = await attendanceRepository.createMeeting(
  meetingDate: DateTime.now().add(Duration(days: 7)),
  meetingType: 'regular',
  title: 'Monthly General Meeting',
  createdBy: 'admin_user_id',
  location: 'Main Hall',
  totalExpectedMembers: 50,
);

// Generate QR code for check-in
final updatedMeeting = await attendanceRepository.generateMeetingQRCode(meeting.id);

// Mark attendance via QR scan
final attendance = await attendanceRepository.markAttendance(
  userId: 'user_id',
  memberNumber: 'M001',
  memberName: 'John Doe',
  meetingId: meeting.id,
  meetingDate: meeting.meetingDate,
  meetingTitle: meeting.title,
  status: 'present',
  checkInMethod: 'qr_scan',
);

// Get meeting attendance list
final attendanceList = await attendanceRepository.getMeetingAttendance(meeting.id);

// Export to CSV
final csvData = attendanceRepository.exportAttendanceToCsv(attendanceList);

// Get user's attendance summary
final summary = await attendanceRepository.getUserSummary('user_id');
print('Attendance rate: ${summary?.attendanceRate}%');
```

For complete attendance system documentation, see:

- [Attendance Implementation Guide](./ATTENDANCE_IMPLEMENTATION.md)
- [Attendance Schema Design](./ATTENDANCE_SCHEMA.md)
- [PocketBase Attendance Setup](./POCKETBASE_ATTENDANCE_SETUP.md)

## Real-time Updates

### Subscriptions

The service provides real-time updates for various data types:

```dart
// Subscribe to user updates
Future<UnsubscribeFunc> subscribeToUsers(
  void Function(RecordModel) onUpdate
)

// Subscribe to announcement updates
Future<UnsubscribeFunc> subscribeToAnnouncements(
  void Function(RecordModel) onUpdate
)

// Subscribe to monthly dues updates
Future<UnsubscribeFunc> subscribeToMonthlyDues(
  void Function(RecordModel) onUpdate
)
```

### Usage Example

```dart
// Subscribe to updates
final unsubscribe = await pocketBaseService.subscribeToUsers((record) {
  // Handle user update
  print('User updated: ${record.id}');
});

// Unsubscribe when done
await unsubscribe();
```

## Data Models

### User Model (Firebase)

Located in `packages/authentication_repository/lib/src/models/user.dart`

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String firstName,
    String? middleName,
    required String lastName,
    required String gender,
    required String memberNumber,
    required String civilStatus,
    required Timestamp dateOfBirth,
    required String birthplace,
    required String nationality,
    String? emergencyContactNumber,
    String? driversLicenseNumber,
    required Timestamp driversLicenseExpirationDate,
    String? driversLicenseRestrictionCode,
    required String contactNumber,
    String? bloodType,
    String? religion,
    String? spouseName,
    String? spouseContactNumber,
    String? emergencyContactName,
    String? profile_image,
    num? membership_type,
  }) = _User;
}
```

### Custom Error Model

Located in `lib/models/custom_error.dart`

```dart
@freezed
abstract class CustomError with _$CustomError {
  const factory CustomError({
    required String message,
    required String code,
    required String plugin,
  }) = _CustomError;

  const factory CustomError.initial() = _Initial;
}
```

## Error Handling

### Error Types

1. **AuthFailure** - Authentication errors
2. **FirebaseAuthApiFailure** - Firebase-specific auth errors
3. **CustomError** - General application errors

### Error Handling Pattern

```dart
try {
  await pocketBaseAuth.signIn(email: email, password: password);
} on AuthFailure catch (e) {
  // Handle PocketBase auth error
  emit(state.copyWith(
    signinStatus: SigninStatus.error,
    error: FirebaseAuthApiFailure(e.message.toString(), e.code, e.plugin)
  ));
} catch (e) {
  // Handle unexpected errors
  emit(state.copyWith(
    signinStatus: SigninStatus.error,
    error: CustomError(
      message: e.toString(),
      code: 'UNKNOWN_ERROR',
      plugin: 'PocketBaseService'
    )
  ));
}
```

### Common Error Codes

- `'INVALID_CREDENTIALS'` - Invalid email/password
- `'USER_NOT_FOUND'` - User doesn't exist
- `'NETWORK_ERROR'` - Network connectivity issues
- `'PERMISSION_DENIED'` - Insufficient permissions
- `'VALIDATION_ERROR'` - Data validation failed

## Configuration

### Environment Variables

The app uses Flutter Flavor for environment-specific configuration:

```dart
FlavorConfig(
  name: 'DEV', // or 'STAGING', 'PROD'
  variables: {
    'pocketbaseUrl': 'https://pb.lexserver.org',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);
```

### PocketBase Collections

#### Users Collection

```json
{
  "id": "string",
  "firebaseUid": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "middleName": "string",
  "contactNumber": "string",
  "age": "string",
  "dateOfBirth": "date",
  "birthplace": "string",
  "bloodType": "string",
  "civilStatus": "string",
  "gender": "string",
  "nationality": "string",
  "religion": "string",
  "driversLicenseNumber": "string",
  "driversLicenseExpirationDate": "date",
  "driversLicenseRestrictionCode": "string",
  "emergencyContactName": "string",
  "emergencyContactNumber": "string",
  "spouseName": "string",
  "spouseContactNumber": "string",
  "memberNumber": "string",
  "membership_type": "number",
  "isActive": "boolean",
  "isAdmin": "boolean",
  "joinedDate": "date",
  "vehicle": "object",
  "created": "datetime",
  "updated": "datetime"
}
```

#### Monthly Dues Collection

```json
{
  "id": "string",
  "user": "relation_to_users",
  "due_for_month": "date",
  "amount": "number",
  "status": "string",
  "payment_date": "date",
  "notes": "string",
  "created": "datetime",
  "updated": "datetime"
}
```

#### Announcements Collection

```json
{
  "id": "string",
  "title": "string",
  "content": "string",
  "author": "relation_to_users",
  "type": "string",
  "isActive": "boolean",
  "created": "datetime",
  "updated": "datetime"
}
```

## Best Practices

### Authentication Flow

1. Check existing PocketBase session on app start
2. Fall back to Firebase authentication if needed
3. Sync user data between Firebase and PocketBase
4. Maintain session state across app restarts

### Error Handling

1. Always wrap API calls in try-catch blocks
2. Provide meaningful error messages to users
3. Log errors for debugging purposes
4. Implement retry mechanisms for network errors

### Data Synchronization

1. Use real-time subscriptions for live data updates
2. Implement optimistic updates for better UX
3. Handle offline scenarios gracefully
4. Validate data before sending to backend

### Security

1. Never store sensitive data in local storage
2. Validate all user inputs
3. Use HTTPS for all API communications
4. Implement proper authentication checks

## Testing

### Unit Tests

- Test individual service methods
- Mock external dependencies
- Verify error handling scenarios
- Test data transformation logic

### Integration Tests

- Test complete user flows
- Verify authentication processes
- Test real-time subscriptions
- Validate data synchronization

### API Testing

- Test all endpoint responses
- Verify authentication requirements
- Test error scenarios
- Validate data formats
