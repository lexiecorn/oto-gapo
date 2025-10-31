# Changelog

All notable changes to the Otogapo project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Microsoft Clarity analytics integration via `clarity_flutter` and `ClarityHelper`
  - Configure per flavor using `FlavorConfig.variables['clarityProjectId']`

### Changed

- Centralized logging with `DebugHelper` and `AppLogging` initialization in mains
- Deployment documentation updates and clarifications

### Fixed

- Sign-in reliability improvements, including Google Sign-In flow fixes

### Development

- Dependency updates in `pubspec.lock`
- Added `.fvmrc` (FVM support) and `.cursor/mcp.json` for workspace tooling

## [1.0.0+30] - 2025-11-25

### Changed

- Disabled code obfuscation to eliminate Play Store warnings about missing deobfuscation files
- Removed ProGuard configuration from Android build
- Updated documentation to reflect obfuscation status

### Improved

- Simplified debugging by removing code obfuscation
- Cleaner stack traces in Crashlytics reports
- No need to manage ProGuard mapping files

## [1.0.0+6] - 2025-10-18

### Added

- Complete meeting management system
  - Create and schedule meetings with location, date, and time
  - View upcoming and past meetings with filters
  - Track meeting status (upcoming, ongoing, past, closed)
  - Generate unique QR codes for each meeting
- Comprehensive attendance tracking
  - Quick QR code check-in for members
  - Manual attendance marking for admins
  - Real-time attendance statistics and counts
  - Personal attendance history view
  - Attendance percentage tracking
- Advanced reporting features
  - Export attendance data to CSV format
  - Meeting-specific attendance reports
  - Individual member attendance history
  - Attendance analytics and summaries
- Admin capabilities
  - Mark attendance for any member manually
  - View complete attendee lists
  - Close meetings to finalize attendance
  - Generate detailed attendance reports

### Technical

- New PocketBase collections: `meetings`, `attendance`, `attendance_summary`
- New repository package: `attendance_repository`
- New cubits: `MeetingCubit`, `AttendanceCubit`
- 7 new pages for meeting and attendance management
- CSV export functionality with `csv` package
- Share functionality with `share_plus` package
- Comprehensive unit tests for new features

### Improved

- Enhanced app stability and performance
- Better error handling and user feedback
- Improved UI/UX consistency
- Optimized QR code scanning and generation

## [1.0.0+5] - 2025-10-15

### Added

- CI/CD pipeline with GitHub Actions
- Automated Play Store deployment with Fastlane
- Version bump scripts for automated versioning
- Comprehensive release documentation

## [1.0.0] - 2025-10-11

### Added

- User authentication with Firebase
- Google Sign-In integration
- Member profile management
- Vehicle registration and details tracking
- Driver's license information management
- Emergency contact information
- Monthly dues payment tracking
- Payment history and statistics
- Advance payment support
- Admin dashboard for user management
- Super admin capabilities
- Association announcements system
- Real-time updates
- User roles (Super Admin, Admin, Member)
- Profile photo upload and management
- Secure session management
- Multi-platform support (Android, iOS, Web, Windows)
- Modern Material Design UI
- Responsive layouts with ScreenUtil
- BLoC pattern for state management
- Clean architecture implementation

### Technical

- Flutter 3.24.0 support
- Firebase Authentication integration
- PocketBase backend integration
- Auto Route for type-safe navigation
- GetIt for dependency injection
- Freezed for immutable data classes
- Comprehensive test coverage
- Very Good Analysis linting

### Security

- Secure authentication flow
- Encrypted local storage
- HTTPS-only API communication
- ProGuard configuration for release builds

---

## Release Types

- **Major** (X.0.0): Breaking changes, major features, architecture changes
- **Minor** (0.X.0): New features, non-breaking changes
- **Patch** (0.0.X): Bug fixes, minor improvements

## Links

- [Google Play Store](https://play.google.com/store/apps/details?id=com.digitappstudio.otogapo)
- [GitHub Repository](https://github.com/yourusername/oto-gapo)
- [Documentation](./docs/)

[Unreleased]: https://github.com/yourusername/oto-gapo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/oto-gapo/releases/tag/v1.0.0
