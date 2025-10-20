# Architecture Documentation - OtoGapo

## Overview

OtoGapo follows a clean architecture pattern with clear separation of concerns, making the codebase maintainable, testable, and scalable. The architecture is built around modern Flutter best practices and design patterns.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [Dependency Injection](#dependency-injection)
- [Routing System](#routing-system)
- [Data Layer](#data-layer)
- [Presentation Layer](#presentation-layer)
- [Domain Layer](#domain-layer)
- [Package Architecture](#package-architecture)
- [Docker Deployment Architecture](#docker-deployment-architecture)
- [Design Patterns](#design-patterns)
- [Best Practices](#best-practices)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Pages/Widgets  │  BLoC/Cubit  │  Providers  │  Routes     │
├─────────────────────────────────────────────────────────────┤
│                     Domain Layer                            │
├─────────────────────────────────────────────────────────────┤
│  Models  │  Repositories  │  Use Cases  │  Services       │
├─────────────────────────────────────────────────────────────┤
│                     Data Layer                              │
├─────────────────────────────────────────────────────────────┤
│  Firebase  │  PocketBase  │  Local Storage  │  HTTP       │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns** - Each layer has distinct responsibilities
2. **Dependency Inversion** - High-level modules don't depend on low-level modules
3. **Single Responsibility** - Each class has one reason to change
4. **Open/Closed Principle** - Open for extension, closed for modification
5. **Testability** - Architecture supports comprehensive testing

## Project Structure

```
lib/
├── app/                          # Main application code
│   ├── modules/                  # Feature-based modules
│   │   ├── auth/                # Authentication module
│   │   │   ├── auth_bloc.dart   # Authentication BLoC
│   │   │   ├── auth_event.dart  # Authentication events
│   │   │   └── auth_state.dart  # Authentication states
│   │   ├── profile/             # Profile management module
│   │   │   ├── bloc/           # Profile BLoC/Cubit
│   │   │   └── profile_page.dart # Profile UI
│   │   ├── signin/              # Sign-in module
│   │   │   ├── bloc/           # Sign-in Cubit
│   │   │   └── signin_page.dart # Sign-in UI
│   │   └── signup/              # Sign-up module
│   │       ├── signup_cubit.dart # Sign-up Cubit
│   │       └── signup_page.dart  # Sign-up UI
│   ├── pages/                   # Application pages/screens
│   │   ├── home_page.dart      # Main home page
│   │   ├── home_body.dart      # Home page content with carousel
│   │   ├── splash_page.dart    # Splash screen
│   │   ├── admin_page.dart     # Admin dashboard
│   │   ├── gallery_management_page.dart  # Gallery admin (admin only)
│   │   ├── settings_page.dart  # Settings page
│   │   └── ...                 # Other pages
│   ├── routes/                 # Navigation routing
│   │   ├── app_router.dart     # Route definitions
│   │   └── app_router.gr.dart  # Generated routes
│   ├── view/                   # App shell and main views
│   │   └── app.dart           # Main app widget
│   └── widgets/               # Reusable UI components
│       ├── carousel_view_from_pocketbase.dart  # Gallery carousel
│       └── ...
├── bootstrap.dart             # App initialization
├── main_development.dart      # Development entry point
├── main_staging.dart         # Staging entry point
├── main_production.dart      # Production entry point
├── models/                   # Data models
│   ├── custom_error.dart     # Error handling model
│   ├── monthly_dues.dart     # Payment model
│   └── user.dart            # User model
├── providers/               # Provider classes
│   ├── auth_provider.dart   # Authentication provider
│   ├── theme_provider.dart  # Theme management
│   └── user_provider.dart   # User data provider
├── services/               # Service classes
│   └── pocketbase_service.dart # PocketBase integration
└── utils/                  # Utility functions
    └── ...

packages/                   # Local packages
├── authentication_repository/ # Authentication logic
├── local_storage/          # Local storage abstraction
└── otogapo_core/          # Core UI components and themes
```

## State Management

### BLoC Pattern Implementation

The app uses the BLoC (Business Logic Component) pattern for state management:

#### BLoC Structure

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final PocketBaseAuthRepository pocketBaseAuth;

  AuthBloc({
    required this.authRepository,
    required this.pocketBaseAuth,
  }) : super(AuthState.unknown()) {
    // Event handlers
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignUpRequestedEvent>(_onSignUpRequested);
    on<SignoutRequestedEvent>(_onSignOutRequested);
  }
}
```

#### Cubit Structure (for simpler state)

```dart
class SigninCubit extends Cubit<SigninState> {
  final AuthRepository authRepository;
  final PocketBaseAuthRepository pocketBaseAuth;

  SigninCubit({
    required this.authRepository,
    required this.pocketBaseAuth,
  }) : super(const SigninState());

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### State Management Hierarchy

```
App
├── AuthBloc (Global authentication state)
├── SigninCubit (Sign-in form state)
├── SignupCubit (Sign-up form state)
├── ProfileCubit (Profile management state)
├── MeetingCubit (Meeting management state)
├── AttendanceCubit (Attendance tracking state)
├── ConnectivityCubit (Network connectivity and sync state)
├── SearchCubit (Search functionality state)
├── CalendarCubit (Attendance calendar state)
├── ProfileProgressCubit (Profile completion tracking)
├── AdminAnalyticsCubit (Admin dashboard analytics)
└── ThemeProvider (Theme state)
```

### State Flow

1. **User Action** → Triggers Event
2. **Event** → Processed by BLoC/Cubit
3. **Business Logic** → Executed in BLoC/Cubit
4. **Repository Call** → Data layer interaction
5. **State Emission** → New state emitted
6. **UI Update** → Widget rebuilds with new state

## Dependency Injection

### GetIt Service Locator

The app uses GetIt for dependency injection and service location:

```dart
// Registration in bootstrap.dart
final getIt = GetIt.instance;

// Register services
getIt
  ..registerSingleton<AppRouter>(AppRouter())
  ..registerSingleton<Dio>(dio)
  ..registerSingleton<PocketBaseService>(pocketBaseService)
  ..registerSingleton<AuthRepository>(authRepository)
  ..registerSingleton<PocketBaseAuthRepository>(pocketBaseAuthRepository);
```

### Repository Provider Pattern

```dart
// In app.dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<AuthRepository>.value(value: _authRepository),
    RepositoryProvider<PocketBaseAuthRepository>.value(value: _pocketBaseAuthRepository),
    RepositoryProvider<ProfileRepository>(
      create: (context) => ProfileRepository(
        firebaseFirestore: FirebaseFirestore.instance,
        pocketBaseAuth: context.read<PocketBaseAuthRepository>(),
      ),
    ),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
          pocketBaseAuth: context.read<PocketBaseAuthRepository>(),
        ),
      ),
      // Other BLoC providers...
    ],
    child: const AppView(),
  ),
)
```

## Routing System

### Auto Route Implementation

The app uses auto_route for type-safe navigation:

```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashPageRouter.page,
      path: '/',
      initial: true,
    ),
    AutoRoute(
      page: SigninPageRouter.page,
      path: '/signin',
    ),
    AutoRoute(
      page: SignupPageRouter.page,
      path: '/signup',
    ),
    AutoRoute(
      page: HomePageRouter.page,
      path: '/home',
    ),
    // Other routes...
  ];
}
```

### Route Annotations

```dart
@RoutePage(name: 'HomePageRouter')
class HomePage extends StatefulWidget {
  const HomePage({super.key});
}
```

### Navigation Patterns

```dart
// Navigate to route
AutoRouter.of(context).push(const SigninPageRouter());

// Replace current route
AutoRouter.of(context).pushAndClearStack(const HomePageRouter());

// Go back
AutoRouter.of(context).pop();
```

## Data Layer

### Repository Pattern

The data layer implements the Repository pattern for data abstraction:

```dart
abstract class AuthRepository {
  Future<User> signInWithGoogle({required String idToken, String? displayName});
  Future<void> signOut();
  Stream<User?> get user;
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _client;
  final LocalStorage _storage;

  AuthRepositoryImpl({
    required Dio client,
    required LocalStorage storage,
  }) : _client = client, _storage = storage;

  // Implementation...
}
```

### Data Sources

1. **Firebase** - Authentication only
2. **PocketBase** - Primary data management and file storage
3. **Local Storage** - Offline data and caching
4. **HTTP Client** - API communications and file uploads

### PocketBase Collections

The app uses PocketBase (https://pb.lexserver.org/) for data management with the following collections:

#### users

- User profile data
- Authentication information
- Membership details
- Vehicle information

#### monthly_dues

- Payment tracking
- Due dates and amounts
- Payment history

#### Announcements

- System-wide announcements
- News and updates

#### gallery_images

- Homepage carousel images
- Managed by admin users
- Fields:
  - `image` (file) - The gallery image
  - `title` (text) - Optional image title
  - `description` (text) - Optional description
  - `display_order` (number) - Sort order for carousel
  - `is_active` (bool) - Show/hide in carousel
  - `uploaded_by` (relation) - Admin who uploaded
  - `created` (autodate) - Upload timestamp
  - `updated` (autodate) - Last update timestamp

**API Rules:**

- View: Authenticated users only
- Create/Update/Delete: Admins only (membership_type 1 or 2)

#### app_data

- Application configuration
- System settings

#### meetings

- Meeting schedules and details
- QR code tokens for check-in
- Attendance count tracking
- Meeting status and types
- Fields: meetingDate, meetingType, title, location, status, qrCodeToken, qrCodeExpiry, presentCount, absentCount, etc.

#### attendance

- Individual attendance records
- User check-in tracking
- Denormalized member data for performance
- Unique constraint on (userId, meetingId)
- Fields: userId, memberNumber, memberName, meetingId, status, checkInTime, checkInMethod, markedBy, notes

#### attendance_summary

- User attendance statistics
- Cached attendance rates
- Auto-updated by attendance changes
- Unique constraint on userId
- Fields: userId, totalMeetings, totalPresent, totalAbsent, totalLate, totalExcused, attendanceRate

### Data Flow

```
UI → BLoC → Repository → Data Source
UI ← BLoC ← Repository ← Data Source
```

### File Upload Architecture

The application uses a sophisticated file upload system that handles both regular data and file uploads separately to avoid JSON serialization issues:

#### File Upload Flow

```
User Action (Image Pick) → File Selection → PocketBaseService.updateUser()
                                                      ↓
                                              Separate File/Data Processing
                                                      ↓
                                    Regular Data → PocketBase Client API
                                    File Data → Direct HTTP Multipart Request
                                                      ↓
                                              PocketBase File Storage
                                                      ↓
                                              Construct File URLs
                                                      ↓
                                              Update UI with New Images
```

#### Implementation Details

**1. File Upload Separation**

```dart
// PocketBaseService.updateUser() method
Future<RecordModel> updateUser(String userId, Map<String, dynamic> data) async {
  // Separate file uploads from regular data
  final fileFields = <String, File>{};
  final regularData = <String, dynamic>{};

  for (final entry in data.entries) {
    if (entry.value is File) {
      fileFields[entry.key] = entry.value as File;
    } else {
      regularData[entry.key] = entry.value;
    }
  }

  // Process regular data first
  if (regularData.isNotEmpty) {
    result = await pb.collection('users').update(userId, body: regularData);
  }

  // Process file uploads separately
  if (fileFields.isNotEmpty) {
    for (final entry in fileFields.entries) {
      result = await _uploadUserFile(userId, entry.key, entry.value);
    }
  }
}
```

**2. Direct HTTP File Upload**

```dart
Future<RecordModel> _uploadUserFile(String userId, String fieldName, File file) async {
  // Create multipart request manually
  final request = http.MultipartRequest(
    'PATCH',
    Uri.parse('${pb.baseUrl}/api/collections/users/records/$userId'),
  );

  // Add authentication
  final token = pb.authStore.token;
  request.headers['Authorization'] = 'Bearer $token';

  // Add the file
  request.files.add(
    http.MultipartFile.fromBytes(
      fieldName,
      await file.readAsBytes(),
      filename: file.path.split('/').last,
    ),
  );

  // Send request and handle response
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    return RecordModel.fromJson(responseData);
  } else {
    throw Exception('File upload failed: ${response.statusCode}');
  }
}
```

**3. File URL Construction**

```dart
// Construct PocketBase file URLs
String getPocketBaseImageUrl(String filename, String userId) {
  final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
  return '$pocketbaseUrl/api/files/users/$userId/$filename';
}
```

#### Supported File Types

- **Profile Images**: `profileImage` field
- **Car Images**: `carImage1`, `carImage2`, `carImage3`, `carImage4`, `carImagemain`
- **Gallery Images**: `image` field in `gallery_images` collection

#### Error Handling

The file upload system includes comprehensive error handling:

1. **File Validation**: Checks file existence and size
2. **Network Errors**: Handles connection issues gracefully
3. **Authentication**: Ensures proper PocketBase authentication
4. **Response Validation**: Verifies successful upload responses
5. **Debug Logging**: Extensive logging for troubleshooting

#### Benefits of This Architecture

1. **No JSON Serialization Issues**: Files bypass PocketBase client JSON conversion
2. **Direct Control**: Full control over HTTP request structure
3. **Better Performance**: Optimized file upload process
4. **Unified Backend**: Single backend for all data and files
5. **Cost Efficiency**: No Firebase Storage costs
6. **Simplified Maintenance**: Single backend system to manage

## Presentation Layer

### Widget Architecture

The presentation layer follows a hierarchical widget structure:

```
MaterialApp
└── AppView (ScreenUtilInit)
    └── Consumer<ThemeProvider>
        └── MaterialApp.router
            └── Route Pages
                └── Feature Widgets
                    └── Reusable Components
```

### Responsive Design

Using ScreenUtil for responsive design:

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) {
    return MaterialApp.router(
      // App configuration
    );
  },
)
```

### Widget Usage Patterns

```dart
// Responsive sizing
Container(
  width: 200.w,
  height: 100.h,
  child: Text(
    'Hello World',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

## Domain Layer

### Models

Domain models represent business entities:

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String firstName,
    required String lastName,
    // Other properties...
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Business Logic

Business logic is encapsulated in BLoCs and Cubits:

```dart
// Authentication business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onSignInRequested(
    SignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(authStatus: AuthStatus.unknown));
      await pocketBaseAuth.signIn(
        email: event.email,
        password: event.password,
      );
    } catch (e) {
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      rethrow;
    }
  }
}
```

## Package Architecture

### Local Packages

The app uses a modular package architecture:

#### 1. authentication_repository

- **Purpose**: Authentication logic abstraction
- **Dependencies**: Firebase Auth, PocketBase, Dio
- **Exports**: AuthRepository, PocketBaseAuthRepository, User model

#### 2. attendance_repository

- **Purpose**: Meeting and attendance management
- **Dependencies**: PocketBase, CSV
- **Exports**: AttendanceRepository, Meeting, Attendance, AttendanceSummary models
- **Features**:
  - Meeting CRUD operations
  - Attendance tracking and marking
  - QR code generation and validation
  - CSV export functionality
  - Real-time attendance statistics
  - Automatic count updates

#### 3. local_storage

- **Purpose**: Local data persistence
- **Dependencies**: Hive, SharedPreferences
- **Exports**: LocalStorage interface and implementation

#### 4. otogapo_core

- **Purpose**: Core UI components and themes
- **Dependencies**: Flutter, Google Fonts, ScreenUtil
- **Exports**: Themes, colors, widgets, utilities

### Package Dependencies

```
otogapo (main app)
├── authentication_repository
│   ├── local_storage
│   ├── firebase_auth
│   └── pocketbase
├── attendance_repository
│   ├── pocketbase
│   └── csv
├── local_storage
│   └── hive
└── otogapo_core
    ├── google_fonts
    └── flutter_screenutil
```

## Design Patterns

### 1. Repository Pattern

```dart
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
  Future<void> updateUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  final PocketBaseService _pocketBaseService;

  UserRepositoryImpl(this._pocketBaseService);

  @override
  Future<List<User>> getUsers() async {
    // Implementation
  }
}
```

### 2. Observer Pattern (BLoC)

```dart
// BLoC acts as observer for state changes
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Observers listen to state changes
  Stream<AuthState> get stream => super.stream;
}
```

### 3. Singleton Pattern

```dart
class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();
}
```

### 4. Factory Pattern

```dart
class UserFactory {
  static User createUser({
    required String firstName,
    required String lastName,
    // Other parameters...
  }) {
    return User(
      uid: _generateUid(),
      firstName: firstName,
      lastName: lastName,
      // Other properties...
    );
  }
}
```

### 5. Builder Pattern

```dart
class UserBuilder {
  String? _firstName;
  String? _lastName;
  String? _email;

  UserBuilder firstName(String firstName) {
    _firstName = firstName;
    return this;
  }

  UserBuilder lastName(String lastName) {
    _lastName = lastName;
    return this;
  }

  User build() {
    return User(
      firstName: _firstName!,
      lastName: _lastName!,
      // Other properties...
    );
  }
}
```

## Best Practices

### 1. Code Organization

- **Feature-based structure** - Group related functionality together
- **Clear naming conventions** - Use descriptive names for classes and methods
- **Consistent file structure** - Follow established patterns across modules

### 2. State Management

- **Immutable states** - Use Freezed for state classes
- **Single source of truth** - Each piece of data has one authoritative source
- **Predictable state updates** - All state changes go through BLoC/Cubit

### 3. Error Handling

- **Comprehensive error types** - Define specific error classes
- **Graceful degradation** - Handle errors without crashing
- **User-friendly messages** - Provide meaningful error messages

### 4. Testing Strategy

- **Unit tests** - Test individual components in isolation
- **Widget tests** - Test UI components
- **Integration tests** - Test complete user flows
- **Mock dependencies** - Use mocktail for external dependencies

### 5. Performance

- **Lazy loading** - Load data only when needed
- **Efficient rebuilds** - Use const constructors where possible
- **Memory management** - Properly dispose of resources

### 6. Security

- **Input validation** - Validate all user inputs
- **Secure storage** - Use encrypted storage for sensitive data
- **Authentication checks** - Verify permissions before operations

## Attendance Management System

The application includes a comprehensive attendance management system for tracking member attendance at meetings.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│  MeetingsListPage  │  CreateMeetingPage  │  MarkAttendance │
│  MeetingDetails    │  MeetingQRCode      │  UserHistory    │
├─────────────────────────────────────────────────────────────┤
│            State Management (BLoC/Cubit)                    │
├─────────────────────────────────────────────────────────────┤
│  MeetingCubit      │  AttendanceCubit                       │
├─────────────────────────────────────────────────────────────┤
│            Domain Layer (Repository)                        │
├─────────────────────────────────────────────────────────────┤
│  AttendanceRepository (packages/attendance_repository)      │
├─────────────────────────────────────────────────────────────┤
│            Data Layer (PocketBase)                          │
├─────────────────────────────────────────────────────────────┤
│  meetings  │  attendance  │  attendance_summary             │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. Meeting Management

**MeetingCubit** (`lib/app/modules/meetings/bloc/meeting_cubit.dart`)

Manages meeting-related state including:

- Meeting list (upcoming/past)
- Meeting creation and updates
- QR code generation
- Meeting filters
- Real-time count updates

**Features:**

- Create meetings with details and scheduling
- Generate time-limited QR codes for check-in
- Filter meetings by status and type
- Track attendance counts in real-time
- Export meeting attendance to CSV

#### 2. Attendance Tracking

**AttendanceCubit** (`lib/app/modules/attendance/bloc/attendance_cubit.dart`)

Manages attendance-related state including:

- Attendance marking (manual and QR)
- User attendance history
- Attendance statistics
- Real-time updates

**Features:**

- Mark attendance manually by admin
- QR code-based check-in
- Track multiple attendance statuses (present, late, absent, excused, leave)
- Calculate attendance rates
- View personal attendance history

#### 3. User Selection Methods

**MarkAttendancePage** supports two methods for selecting users:

1. **Browse Users**

   - Modal bottom sheet with searchable user list
   - Displays all active members
   - Shows member number, name, and profile image
   - Real-time search filtering

2. **QR Code Scanning**
   - Mobile scanner integration
   - Scans member QR codes
   - Automatic user selection
   - Error handling for invalid codes

#### 4. Data Models

**Meeting Model** (`lib/models/meeting.dart`)

- Comprehensive meeting information
- Computed properties (hasActiveQRCode, isUpcoming, attendanceRate)
- Enums for MeetingType and MeetingStatus

**Attendance Model** (`lib/models/attendance.dart`)

- Individual attendance records
- Denormalized member data for performance
- Enums for AttendanceStatus and CheckInMethod

**AttendanceSummary Model** (`lib/models/attendance_summary.dart`)

- Cached user statistics
- Attendance rate calculations
- Historical data aggregation

### Data Flow

**Creating a Meeting:**

```
CreateMeetingPage
  ↓ Form submission
MeetingCubit.createMeeting()
  ↓ Call repository
AttendanceRepository.createMeeting()
  ↓ API call
PocketBase (meetings collection)
  ↓ Record created
Meeting object returned
  ↓ State emission
UI updated with new meeting
```

**Marking Attendance via QR:**

```
User scans QR code
  ↓
QRScannerPage validates token
  ↓
AttendanceCubit.markAttendanceViaQR()
  ↓
AttendanceRepository.validateQRCode()
  ↓
If valid, create attendance record
  ↓
Update meeting counts
  ↓
Update user summary
  ↓
Emit success state
```

### PocketBase Schema

The attendance system uses three related collections with specific indexes and API rules for security and performance:

**meetings** - Stores meeting information

- Unique QR tokens per meeting
- Auto-updated attendance counts
- Admin-only create/update/delete

**attendance** - Stores individual check-ins

- Unique index on (userId, meetingId)
- Denormalized member data
- Users can create via QR scan only

**attendance_summary** - Stores user statistics

- Unique index on userId
- Auto-calculated attendance rates
- Admin-only updates

For detailed schema information, see [docs/ATTENDANCE_SCHEMA.md](./ATTENDANCE_SCHEMA.md)

### Security

**Permission Model:**

- Admins (membership_type 1 or 2) can:

  - Create, edit, delete meetings
  - Mark attendance manually
  - View all attendance records
  - Export data to CSV
  - Manage meeting QR codes

- Members can:
  - View meeting list
  - Check in via QR code
  - View own attendance history
  - See own statistics

**QR Code Security:**

- Tokens are time-limited (configurable expiry)
- One-time use per user per meeting
- Validated server-side
- Unique constraint prevents duplicate check-ins

### Performance Optimizations

1. **Denormalized Data**

   - Member info cached in attendance records
   - Fast display without joins
   - Reduces database queries

2. **Auto-Updated Counts**

   - Meeting counts updated on attendance changes
   - No need to count on every query
   - Improves list view performance

3. **Cached Summaries**
   - User statistics pre-calculated
   - Updated incrementally
   - Fast history page loads

### Export Features

**CSV Export:**

- Meeting attendance exported to CSV
- Includes member info and attendance details
- Shareable via system share sheet
- Compatible with Excel/Google Sheets

### Future Enhancements

Planned features for v2.0:

- Push notifications for upcoming meetings
- Advanced analytics dashboard with charts
- Attendance trends and predictions
- Bulk attendance operations
- Meeting templates
- Recurring meetings support
- Offline QR scanning with sync

For complete attendance documentation, see:

- [Attendance Implementation Guide](./ATTENDANCE_IMPLEMENTATION.md)
- [Attendance Schema Design](./ATTENDANCE_SCHEMA.md)
- [PocketBase Setup Guide](./POCKETBASE_ATTENDANCE_SETUP.md)
- [Attendance Feature Summary](../ATTENDANCE_FEATURE_COMPLETE.md)

## Admin Features

The application includes comprehensive admin functionality for managing users, payments, and content.

### Admin Access Control

Admin access is controlled by the `membership_type` field in the user profile:

- **Type 1**: Super Admin (full access)
- **Type 2**: Admin (full access)
- **Type 3+**: Regular users (no admin access)

### Admin Dashboard

Location: `lib/app/pages/admin_page.dart`

The admin dashboard provides centralized access to:

1. **User Management** - Manage all user accounts
2. **Payment Management** - Track and manage monthly dues
3. **Gallery Management** - Manage homepage carousel images
4. **Analytics** - View system analytics (planned)
5. **System Settings** - Configure application (planned)

### Gallery Management System

Location: `lib/app/pages/gallery_management_page.dart`

#### Overview

The gallery management system allows admin users to manage the homepage carousel images displayed to all users. Images are stored in PocketBase with rich metadata.

#### Features

**Upload**

- Image picker integration
- Metadata collection (title, description, display order)
- Active/inactive status toggle
- Automatic display order assignment

**Edit**

- Update image metadata
- Replace image file
- Change display order
- Toggle active status

**Delete**

- Confirmation dialog
- Permanent deletion from PocketBase

**View**

- Grid view of all gallery images
- Visual indicators for active/inactive status
- Display order badges
- Thumbnail previews

#### Workflow

```
1. Admin navigates to Admin Panel
2. Selects "Gallery Management"
3. Views all gallery images in grid
4. Performs actions:
   - Upload: Pick image → Enter metadata → Save
   - Edit: Click edit → Modify fields → Save
   - Delete: Click delete → Confirm → Remove
   - Toggle: Click visibility icon → Update status
```

#### Data Flow

```
GalleryManagementPage
  ↓
PocketBaseService
  ↓
PocketBase API (https://pb.lexserver.org/)
  ↓
gallery_images collection
```

#### Service Methods

Location: `lib/services/pocketbase_service.dart`

- `getActiveGalleryImages()` - Fetch visible images for carousel
- `getAllGalleryImages()` - Fetch all images (admin only)
- `createGalleryImage()` - Upload new image with metadata
- `updateGalleryImage()` - Update image or metadata
- `deleteGalleryImage()` - Remove image
- `getGalleryImageUrl()` - Generate image URL

### Homepage Carousel

Location: `lib/app/widgets/carousel_view_from_pocketbase.dart`

The carousel displays active gallery images to all authenticated users:

- Fetches only active images (`is_active = true`)
- Sorted by `display_order` (ascending)
- Auto-plays with 5-second intervals
- Displays optional title overlay
- Error handling and loading states
- Responsive sizing with ScreenUtil

#### Integration

```dart
// In home_body.dart
Container(
  color: Colors.black,
  height: 220.h,
  child: const CarouselViewFromPocketbase(),
)
```

#### Authentication & Loading Strategy

The carousel and announcements widgets implement a robust authentication-aware loading strategy:

**Problem Solved**: On first app launch, gallery images and announcements would show "no data available" because widgets tried to fetch data before user authentication was complete.

**Solution Implemented**:

1. **Authentication Monitoring**: Widgets monitor `AuthBloc` state changes
2. **Delayed Fetching**: Data fetching only occurs after user authentication is confirmed
3. **Single Fetch Prevention**: `_hasTriedFetching` flag prevents multiple fetch attempts
4. **Proper Loading States**: Shows loading indicators until authentication is ready

**Code Pattern**:

```dart
void _checkAuthAndFetch() {
  final authState = context.read<AuthBloc>().state;

  if (authState.authStatus == AuthStatus.authenticated &&
      authState.user != null &&
      !_hasTriedFetching) {
    _hasTriedFetching = true;
    _fetchData();
  }
}

@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkAuthAndFetch();
  });

  // Show loading until authenticated
  final authState = context.read<AuthBloc>().state;
  if (authState.authStatus != AuthStatus.authenticated || authState.user == null) {
    return const Center(child: CircularProgressIndicator());
  }
  // ... rest of build method
}
```

**PocketBase Service Authentication**: All gallery and announcement methods now call `_ensureAuthenticated()` before making API requests to ensure proper authentication state.

## Flavor Architecture

### Environment Configuration

The app supports multiple environments through Flutter Flavor:

```dart
// Development flavor
FlavorConfig(
  name: 'DEV',
  variables: {
    'pocketbaseUrl': 'https://dev.pocketbase.com',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);

// Staging flavor
FlavorConfig(
  name: 'STAGING',
  variables: {
    'pocketbaseUrl': 'https://staging.pocketbase.com',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);

// Production flavor
FlavorConfig(
  name: 'PROD',
  variables: {
    'pocketbaseUrl': 'https://prod.pocketbase.com',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);
```

### Flavor-specific Builds

Each flavor has its own entry point and configuration:

- `main_development.dart` - Development environment
- `main_staging.dart` - Staging environment
- `main_production.dart` - Production environment

## Docker Deployment Architecture

The application supports containerized deployment for the web platform using Docker. This provides a production-ready infrastructure with automatic SSL management and optimized serving.

### Container Architecture

```
┌───────────────────────────────────────────────────────┐
│                   Internet (HTTP/HTTPS)               │
│                    Ports 80/443                       │
└──────────────────┬────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│            nginx-proxy Container                    │
│  ┌───────────────────────────────────────────────┐  │
│  │  - SSL Termination (Let's Encrypt)           │  │
│  │  - HTTP → HTTPS Redirect                     │  │
│  │  - Reverse Proxy                             │  │
│  │  - Security Headers (HSTS, X-Frame, etc.)    │  │
│  └───────────────────────────────────────────────┘  │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│            otogapo-web Container                    │
│  ┌───────────────────────────────────────────────┐  │
│  │  Multi-stage Build:                          │  │
│  │  Stage 1: Flutter SDK + Build                │  │
│  │  Stage 2: Nginx Alpine + Static Files        │  │
│  │                                               │  │
│  │  Features:                                    │  │
│  │  - SPA routing (all → index.html)            │  │
│  │  - Gzip compression                           │  │
│  │  - Static asset caching (1 year)             │  │
│  │  - HTML no-cache for updates                 │  │
│  │  - Proper MIME types (.wasm, .js, .json)     │  │
│  │  - Health check endpoint                     │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│              certbot Container                      │
│  ┌───────────────────────────────────────────────┐  │
│  │  - Automatic SSL certificate renewal         │  │
│  │  - Let's Encrypt integration                 │  │
│  │  - Runs every 12 hours                       │  │
│  │  - Nginx reload on renewal                   │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│               Shared Volumes                        │
│  - certbot/conf  → SSL certificates               │
│  - certbot/www   → ACME challenges                │
└─────────────────────────────────────────────────────┘
```

### Docker Components

**1. Dockerfile (Multi-stage)**

- **Stage 1 (Build)**: Ubuntu-based Flutter build environment
  - Installs Flutter SDK
  - Builds production web app
  - Target: `lib/main_production.dart`
- **Stage 2 (Serve)**: Nginx Alpine
  - Minimal footprint (~20MB)
  - Serves static files
  - Custom nginx configuration
  - Health check support

**2. docker-compose.yml**

Orchestrates three services:

- `otogapo-web`: Flutter web application
- `nginx-proxy`: SSL-enabled reverse proxy
- `certbot`: Certificate management

**3. Nginx Configurations**

- **app.conf**: Application-specific serving rules
- **proxy.conf**: Reverse proxy with SSL termination
- **ssl-params.conf**: Secure TLS configuration

### Deployment Flow

```
1. Developer pushes code → GitHub Repository
                              ↓
2. Server pulls latest     ← git pull
                              ↓
3. deploy_docker.sh        → Build Flutter web app
                              ↓
4. Docker build            → Create multi-stage image
                              ↓
5. First run?              → Initialize SSL certificates
                              ↓
6. docker-compose up       → Start all containers
                              ↓
7. Health check            → Verify deployment
                              ↓
8. Live application        → https://otogapo.lexserver.org
```

### Security Features

1. **SSL/TLS**

   - Automatic Let's Encrypt certificates
   - TLS 1.2 and 1.3 only
   - Strong cipher suites
   - OCSP stapling
   - HTTP Strict Transport Security (HSTS)

2. **Security Headers**

   - X-Frame-Options: SAMEORIGIN
   - X-Content-Type-Options: nosniff
   - X-XSS-Protection: enabled
   - Referrer-Policy: no-referrer-when-downgrade

3. **Container Security**
   - Minimal base images (Alpine)
   - Non-root user execution
   - Health checks for availability
   - Restart policies for reliability

### Performance Optimizations

1. **Caching Strategy**

   - Static assets: 1 year cache
   - HTML files: no-cache for instant updates
   - Service worker: no-cache for version control

2. **Compression**

   - Gzip enabled for text-based files
   - Optimized compression levels

3. **Build Optimization**
   - Multi-stage builds (smaller images)
   - Flutter web renderer: auto-selection
   - Tree-shaking enabled

### Management Tools

**Portainer Integration**

The Docker setup is compatible with Portainer for visual management:

- Stack import from docker-compose.yml
- Container monitoring and logs
- Resource usage tracking
- One-click restarts and updates
- Webhook support for CI/CD

**Automation Scripts**

- `deploy_docker.sh`: Full deployment automation
- `renew_ssl.sh`: SSL renewal (cron-compatible)

### Monitoring and Maintenance

**Health Checks**

- Application: `http://localhost/health`
- Container: Docker health check every 30s
- SSL: Certificate expiry monitoring

**Logging**

```bash
# View all logs
docker-compose logs -f

# Specific service
docker-compose logs -f otogapo-web
docker-compose logs -f nginx-proxy

# SSL renewal logs
cat certbot-renew.log
```

**Updates**

```bash
# Pull latest code
git pull origin main

# Rebuild and redeploy
./scripts/deploy_docker.sh
```

### Backup and Recovery

**Backup**

- SSL certificates: `certbot/conf/` directory
- Docker images: `docker save otogapo-web:latest`
- Configuration: `.env` file (excluded from git)

**Rollback**

- Previous Docker images tagged by version
- Quick rollback: `docker-compose down && docker-compose up -d <previous-tag>`

For detailed deployment instructions, see [Docker Deployment Guide](../DOCKER_DEPLOYMENT.md).

## Offline Support Architecture

### Overview

The application includes comprehensive offline support allowing users to continue using the app without internet connectivity.

### Components

**1. ConnectivityService**

- Monitors network connectivity using `connectivity_plus`
- Provides real-time connectivity status stream
- Singleton pattern for consistent monitoring

**2. SyncService**

- Queues offline actions using Hive
- Auto-syncs when connectivity restored
- Retry logic with max 3 attempts
- Persistent storage of pending actions

**3. ConnectivityCubit**

- Exposes connectivity state to UI
- Tracks pending action count
- Triggers manual sync
- Shows sync status (idle, pending, syncing, synced)

### Offline Capabilities

**What Works Offline**:

- View cached posts (last 100)
- View cached meetings
- View user profile
- Queue reactions and comments
- Queue profile updates
- Navigate between pages

**What Requires Online**:

- Initial authentication
- Image uploads
- Server-side search
- Real-time updates
- New data fetching

### Sync Strategy

**Priority Order**:

1. Profile updates
2. Post reactions/comments
3. Attendance marking
4. New posts
5. User settings

**Conflict Resolution**: Server wins, user notified of conflicts

### UI Indicators

- **ConnectivityBanner**: Sliding banner showing status
- **Navigation Badge**: Red dot on Settings when pending actions
- **Manual Sync**: Tap banner to trigger sync

See [Offline Support Documentation](./OFFLINE_SUPPORT.md) for detailed information.

## Animation System

### Animation Packages

1. **flutter_animate**: Widget-level animations
2. **flutter_staggered_animations**: List/grid animations
3. **shimmer**: Loading skeleton screens

### Animation Patterns

**Entry Animations**:

- Page entry: Fade + Slide (400ms)
- List items: Staggered slide (375ms)
- Cards: Scale (300ms)

**Loading States**:

- Skeleton loaders with shimmer
- Circular progress indicators
- Loading placeholders

**Micro-interactions**:

- Button press: Scale (150ms)
- Navigation: Haptic feedback
- Badges: Pulsing animation

**Success States**:

- Completion: Elastic scale (500ms)
- Streaks: Fire icon shimmer + shake

See [Animations Guide](./ANIMATIONS_GUIDE.md) for complete documentation.

## Advanced Features

### Search System

**SearchCubit**: Manages search state and history

- Server-side post search with filters
- User search by name, email, member number
- Recent searches persistence
- Search history management

**Filters**:

- Date range
- Author
- Hashtags

**Implementation**: `lib/app/modules/search/`

### Attendance Calendar

**CalendarCubit**: Manages calendar state

- Monthly attendance view
- Color-coded attendance status
- Streak calculation
- Monthly statistics

**Features**:

- Visual calendar with table_calendar
- Attendance streaks with fire icon
- Monthly stats (present, late, absent, excused)
- Date selection with details

**Implementation**: `lib/app/pages/attendance_calendar_page.dart`

### Profile Progress Tracking

**ProfileProgressCubit**: Tracks profile completion

- Calculates completion percentage
- Identifies missing fields
- Generates suggestions
- Priority-based recommendations

**Display**: Progress card with suggestions on profile page

**Implementation**: `lib/app/modules/profile_progress/`

### Admin Analytics Dashboard

**AdminAnalyticsCubit**: Provides dashboard analytics

- Real-time statistics
- User growth charts
- Attendance trends
- Revenue tracking

**Dashboard Stats**:

- Total users
- Active today
- Pending payments
- Average attendance rate

**Implementation**: `lib/app/modules/admin_analytics/`

## Scalability Considerations

### 1. Modular Architecture

- **Package-based modules** - Separate concerns into packages
- **Feature modules** - Group related functionality
- **Clear interfaces** - Define contracts between modules

### 2. Performance Optimization

- **Code splitting** - Load only necessary code
- **Lazy initialization** - Initialize services on demand
- **Caching strategies** - Implement appropriate caching

### 3. Maintainability

- **Documentation** - Comprehensive code documentation
- **Testing** - High test coverage
- **Code reviews** - Regular code review process

### 4. Extensibility

- **Plugin architecture** - Support for additional features
- **Configuration-driven** - External configuration support
- **API versioning** - Support for API evolution

This architecture provides a solid foundation for the OtoGapo application, ensuring maintainability, testability, and scalability while following Flutter and Dart best practices.
