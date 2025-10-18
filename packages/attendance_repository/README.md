# Attendance Repository

A Flutter package for managing attendance and meetings with PocketBase backend.

## Features

- **Meeting Management**: Create, update, delete, and query meetings
- **Attendance Tracking**: Mark and manage attendance for members
- **QR Code Check-in**: Generate and validate QR codes for quick check-ins
- **Attendance Summary**: Automatic calculation of attendance statistics
- **Real-time Counts**: Auto-update meeting attendance counts

## Usage

### Initialize

```dart
final attendanceRepository = AttendanceRepository(
  pocketBase: pocketBaseInstance,
);
```

### Create a Meeting

```dart
final meeting = await attendanceRepository.createMeeting(
  meetingDate: DateTime(2025, 1, 20),
  meetingType: 'regular',
  title: 'Monthly Meeting',
  createdBy: currentUserId,
  location: 'Main Hall',
);
```

### Generate QR Code

```dart
final updatedMeeting = await attendanceRepository.generateQRCode(
  meetingId,
  validity: Duration(hours: 3),
);
```

### Mark Attendance

```dart
final attendance = await attendanceRepository.markAttendance(
  userId: currentUserId,
  memberNumber: 'OTO-2024-001',
  memberName: 'Juan Dela Cruz',
  meetingId: meetingId,
  meetingDate: DateTime(2025, 1, 20),
  status: 'present',
  checkInMethod: 'qr_scan',
);
```

### Get User's Attendance History

```dart
final history = await attendanceRepository.getAttendanceForUser(
  userId,
  page: 1,
  perPage: 20,
);
```

### Get Attendance Summary

```dart
final summary = await attendanceRepository.getAttendanceSummary(userId);
```

## Collections

The repository manages three PocketBase collections:

- `meetings` - Meeting information and QR codes
- `attendance` - Individual attendance records
- `attendance_summary` - Cached attendance statistics

## Error Handling

The repository throws specific exception types:

- `MeetingNotFoundFailure` - Meeting doesn't exist
- `AttendanceNotFoundFailure` - Attendance record not found
- `DuplicateAttendanceFailure` - Already checked in
- `InvalidQRCodeFailure` - QR code expired or invalid
- `UnauthorizedFailure` - Insufficient permissions
- `AttendanceFailure` - Generic failures with details

## License

MIT

