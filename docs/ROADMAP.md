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
