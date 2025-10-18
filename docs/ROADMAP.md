# Roadmap & Future Features

## 🎯 Priority Levels

- **P0**: Critical - Next release
- **P1**: High - Upcoming releases
- **P2**: Medium - Planned
- **P3**: Low - Backlog/Ideas

## 📋 Planned Features

### P0 - Critical (Next Release)

<!-- Features planned for the immediate next release -->

### P1 - High Priority

<!-- Features planned for upcoming releases -->

**Feature Name**: Attendance Management ✅ **COMPLETED**
**Priority**: P1
**Status**: Complete
**Target Release**: v1.2.0
**Completed**: January 2025
**Description**: Complete attendance management system with QR check-in, meeting management, and reporting
**User Stories - IMPLEMENTED**:

- ✅ As an admin, I can create, edit, and delete meetings
- ✅ As an admin, I can generate QR codes for meetings
- ✅ As an admin, I can mark member attendance manually
- ✅ As an admin, I can view attendance history and statistics
- ✅ As an admin, I can export attendance data to CSV
- ✅ As an admin, during meetings, members can scan QR code to check in
- ✅ As a user, I can view my attendance history and summary
- ✅ As a user, I can check in to meetings via QR scan

**Implementation Details:**

- Backend: PocketBase collections (meetings, attendance, attendance_summary)
- Repository: packages/attendance_repository
- State Management: MeetingCubit, AttendanceCubit
- UI: 7 pages, 3 widgets, 7 routes
- Features: QR generation/scanning, CSV export, real-time stats
- Documentation: See docs/ATTENDANCE_IMPLEMENTATION.md

---

**Feature Name**: Version Update Notifications & Force Update
**Priority**: P1
**Status**: Planned
**Target Release**: v1.3.0
**Description**: Implement an app version management system that can notify users about new versions and enforce mandatory updates when critical fixes are deployed.

**User Stories**:

- As an admin, I want to configure version requirements in the backend so that I can control which versions are supported
- As an admin, I want to mark certain updates as "force update" so users must upgrade before continuing
- As a user, I want to be notified when a new version is available so I can stay up-to-date
- As a user, I want to see what's new in the latest version so I can understand the benefits of updating
- As a user, I want to easily update the app when prompted
- As a user, if an update is mandatory, I should be guided to update before accessing the app

**Technical Notes**:

- **Backend**:
  - Store version configuration in PocketBase (min_version, current_version, force_update flag, release_notes)
  - API endpoint to check version compatibility
  - Admin interface to manage version settings
- **Frontend**:
  - Version check on app launch and resume
  - Dialog/modal for update notifications (optional vs force)
  - Link to app store (Play Store/App Store) for updates
  - Display release notes in update dialog
  - Block app usage if force update is required
- **Package**: Current app version from `package_info_plus`
- **Dependencies**:
  - `package_info_plus` (already in use)
  - PocketBase collection for version management
  - Optional: `url_launcher` for app store links (already in use)
- **Estimated Effort**: Medium

**Implementation Checklist**:

- [ ] Create PocketBase collection for version management
- [ ] Add version check service/repository
- [ ] Implement version comparison logic
- [ ] Create update dialog UI (optional vs mandatory)
- [ ] Add app store deep links
- [ ] Add version check on app startup
- [ ] Add version check on app resume
- [ ] Add admin UI for version management
- [ ] Write tests for version comparison logic
- [ ] Update documentation

### P2 - Medium Priority

<!-- Features in planning stage -->

### P3 - Backlog/Ideas

<!-- Feature ideas and wishlist items -->

---

## 📝 Feature Template

Use this template when adding new features:

**Feature Name**:
**Priority**: P0 | P1 | P2 | P3
**Status**: Planned | In Progress | Testing | Complete
**Target Release**:
**Description**:
**User Stories**:

- As a [user type], I want [feature] so that [benefit]

**Technical Notes**:

- **Dependencies**:

- **Estimated Effort**: Small | Medium | Large

  ***

## 🗂️ Feature Archive

Completed features are moved here for historical reference.

### Version History

<!-- Completed features organized by version -->
