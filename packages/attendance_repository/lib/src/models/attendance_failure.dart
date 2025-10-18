import 'package:equatable/equatable.dart';

/// Exception thrown when attendance operations fail
class AttendanceFailure extends Equatable implements Exception {
  const AttendanceFailure({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final String? details;

  @override
  List<Object?> get props => [code, message, details];

  @override
  String toString() {
    return 'AttendanceFailure(code: $code, message: $message'
        '${details != null ? ', details: $details' : ''})';
  }
}

/// Specific failure types
class MeetingNotFoundFailure extends AttendanceFailure {
  const MeetingNotFoundFailure()
      : super(
          code: 'meeting_not_found',
          message: 'Meeting not found',
        );
}

class AttendanceNotFoundFailure extends AttendanceFailure {
  const AttendanceNotFoundFailure()
      : super(
          code: 'attendance_not_found',
          message: 'Attendance record not found',
        );
}

class DuplicateAttendanceFailure extends AttendanceFailure {
  const DuplicateAttendanceFailure()
      : super(
          code: 'duplicate_attendance',
          message: 'Attendance already exists for this meeting',
        );
}

class InvalidQRCodeFailure extends AttendanceFailure {
  const InvalidQRCodeFailure()
      : super(
          code: 'invalid_qr_code',
          message: 'QR code is invalid or expired',
        );
}

class UnauthorizedFailure extends AttendanceFailure {
  const UnauthorizedFailure()
      : super(
          code: 'unauthorized',
          message: 'You do not have permission to perform this action',
        );
}

