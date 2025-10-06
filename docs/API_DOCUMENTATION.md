# API Documentation - OtoGapo

## Overview

OtoGapo uses a hybrid backend approach combining Firebase for authentication and PocketBase for data management. This document provides comprehensive API documentation for all services and endpoints.

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
// Update user data
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

### Monthly Dues System

The app manages monthly association dues with comprehensive tracking.

#### Data Model: `MonthlyDues`

Located in `lib/models/monthly_dues.dart`

```dart
class MonthlyDues {
  final String id;
  final String userId;
  final DateTime? dueForMonth;
  final double amount;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime created;
  final DateTime updated;

  bool get isPaid => paymentDate != null;
  bool get isUnpaid => paymentDate == null;
  bool get isOverdue {
    if (paymentDate != null) return false; // Already paid
    if (dueForMonth == null) return false; // No due date set

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final dueMonth = DateTime(dueForMonth!.year, dueForMonth!.month);

    return currentMonth.isAfter(dueMonth);
  }
}
```

#### Payment Operations

```dart
// Get monthly dues for a specific user
Future<List<MonthlyDues>> getMonthlyDuesForUser(String userId)

// Get dues for specific user and month
Future<MonthlyDues?> getMonthlyDuesForUserAndMonth(String userId, DateTime month)

// Create or update monthly dues
Future<MonthlyDues> createOrUpdateMonthlyDues({
  required String userId,
  required DateTime dueForMonth,
  required double amount,
  DateTime? paymentDate,
  String? notes,
  String? existingId
})

// Mark payment status
Future<MonthlyDues> markPaymentStatus({
  required String userId,
  required DateTime month,
  required bool isPaid,
  DateTime? paymentDate,
  String? notes
})

// Get payment statistics
Future<Map<String, int>> getPaymentStatistics(String userId)

// Get payment status for a specific month
Future<bool?> getPaymentStatusForMonth({
  required String userId,
  required DateTime monthDate,
})

// Get all monthly dues (admin only)
Future<List<MonthlyDues>> getAllMonthlyDues()

// Delete monthly dues
Future<void> deleteMonthlyDues(String duesId)
```

#### Payment Statistics

The `getPaymentStatistics` method returns:

```dart
{
  'paid': int,      // Number of paid months (from joinedDate to current)
  'unpaid': int,    // Number of unpaid months (from joinedDate to current)
  'advance': int,   // Number of advance payments (future months)
  'total': int      // Total months user should have paid (joinedDate to current)
}
```

#### Payment Status Values

- `true` - Payment completed (paymentDate exists)
- `false` - Payment pending (no paymentDate)
- `null` - Not applicable (month is before user's joinedDate)

#### Payment Statistics Utility

Located in `lib/utils/payment_statistics_utils.dart`

A reusable utility class for computing payment statistics based on user's joined date and monthly dues records.

```dart
class PaymentStatisticsUtils {
  // Compute payment statistics for a user
  static Map<String, int> computePaymentStatistics({
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
    DateTime? currentDate,
  })

  // Compute statistics for a specific date range
  static Map<String, int> computePaymentStatisticsForRange({
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
    required DateTime startDate,
    required DateTime endDate,
  })

  // Get payment status for a specific month
  static bool? getPaymentStatusForMonth({
    required DateTime monthDate,
    required DateTime joinedDate,
    required List<MonthlyDues> monthlyDues,
  })

  // Get all months from joinedDate to current date
  static List<DateTime> getAllPaymentMonths({
    required DateTime joinedDate,
    DateTime? currentDate,
  })

  // Calculate payment percentage
  static double calculatePaymentPercentage(Map<String, int> stats)

  // Get human-readable summary
  static String getPaymentSummary(Map<String, int> stats)
}
```

**Example Usage:**

```dart
// Get user's joined date and dues
final joinedDate = DateTime.parse(userRecord.data['joinedDate']);
final dues = await pocketBaseService.getMonthlyDuesForUser(userId);

// Compute statistics
final stats = PaymentStatisticsUtils.computePaymentStatistics(
  joinedDate: joinedDate,
  monthlyDues: dues,
);

// Get summary
final summary = PaymentStatisticsUtils.getPaymentSummary(stats);
print(summary); // "Payment Summary: 8 paid, 2 unpaid, 1 advance (10 total months, 80.0% paid)"

// Get payment status for specific month
final status = PaymentStatisticsUtils.getPaymentStatusForMonth(
  monthDate: DateTime(2024, 6),
  joinedDate: joinedDate,
  monthlyDues: dues,
);
```

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

```dart
// Get all announcements
Future<List<RecordModel>> getAnnouncements()

// Create announcement
Future<RecordModel> createAnnouncement({
  required String title,
  required String content,
  required String authorId,
  String? type
})

// Subscribe to announcement updates
Future<UnsubscribeFunc> subscribeToAnnouncements(
  void Function(RecordModel) onUpdate
)
```

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
