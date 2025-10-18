import 'package:pocketbase/pocketbase.dart';

/// Attendance status enum
enum AttendanceStatus {
  present('present', 'Present'),
  late('late', 'Late'),
  absent('absent', 'Absent'),
  excused('excused', 'Excused'),
  leave('leave', 'On Leave');

  const AttendanceStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

/// Check-in method enum
enum CheckInMethod {
  manual('manual', 'Manual'),
  qrScan('qr_scan', 'QR Scan'),
  auto('auto', 'Auto');

  const CheckInMethod(this.value, this.displayName);
  final String value;
  final String displayName;

  static CheckInMethod? fromString(String? value) {
    if (value == null) return null;
    return CheckInMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckInMethod.manual,
    );
  }
}

/// Represents an attendance record for a member at a meeting.
///
/// This model tracks individual attendance with:
/// - User/member information (cached for quick display)
/// - Meeting reference and date
/// - Attendance status (present/late/absent/excused/leave)
/// - Check-in details (time and method)
/// - Admin audit trail (markedBy)
///
/// Example:
/// ```dart
/// final attendance = Attendance(
///   id: '123',
///   userId: 'user123',
///   memberNumber: 'OTO-2024-001',
///   memberName: 'Juan Dela Cruz',
///   meetingId: 'meeting456',
///   meetingDate: DateTime(2025, 1, 20),
///   status: AttendanceStatus.present,
///   checkInTime: DateTime.now(),
///   checkInMethod: CheckInMethod.qrScan,
///   created: DateTime.now(),
///   updated: DateTime.now(),
/// );
///
/// if (attendance.isPresent && attendance.wasScanned) {
///   print('Checked in via QR at ${attendance.checkInTime}');
/// }
/// ```
class Attendance {
  const Attendance({
    required this.id,
    required this.userId,
    required this.memberNumber,
    required this.memberName,
    required this.meetingId,
    required this.meetingDate,
    required this.status,
    required this.created,
    required this.updated,
    this.profileImage,
    this.checkInTime,
    this.checkInMethod,
    this.markedBy,
    this.notes,
  });

  factory Attendance.fromRecord(RecordModel record) {
    // Helper to parse date safely
    DateTime parseDate(String dateStr) {
      // If it's just a date (YYYY-MM-DD), parse it at midnight local time
      if (dateStr.length == 10 && !dateStr.contains('T')) {
        final parts = dateStr.split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return DateTime.parse(dateStr);
    }

    // Helper to safely get optional date field (PocketBase returns empty string for null dates)
    DateTime? parseOptionalDate(dynamic value) {
      if (value == null || value == '' || (value is String && value.isEmpty)) {
        return null;
      }
      return parseDate(value as String);
    }

    return Attendance(
      id: record.id,
      userId: record.data['userId'] as String,
      memberNumber: record.data['memberNumber'] as String,
      memberName: record.data['memberName'] as String,
      profileImage: record.data['profileImage'] as String?,
      meetingId: record.data['meetingId'] as String,
      meetingDate: parseDate(record.data['meetingDate'] as String),
      status: AttendanceStatus.fromString(record.data['status'] as String),
      checkInTime: parseOptionalDate(record.data['checkInTime']),
      checkInMethod: CheckInMethod.fromString(record.data['checkInMethod'] as String?),
      markedBy: record.data['markedBy'] as String?,
      notes: record.data['notes'] as String?,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  final String id;
  final String userId;
  final String memberNumber;
  final String memberName;
  final String? profileImage;
  final String meetingId;
  final DateTime meetingDate;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final CheckInMethod? checkInMethod;
  final String? markedBy;
  final String? notes;
  final DateTime created;
  final DateTime updated;

  /// Computed properties
  bool get isPresent => status == AttendanceStatus.present;
  bool get isLate => status == AttendanceStatus.late;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isExcused => status == AttendanceStatus.excused;
  bool get isOnLeave => status == AttendanceStatus.leave;

  bool get hasAttended => isPresent || isLate;
  bool get wasScanned => checkInMethod == CheckInMethod.qrScan;
  bool get wasMarkedManually => checkInMethod == CheckInMethod.manual;
  bool get wasAutoMarked => checkInMethod == CheckInMethod.auto;

  String get statusDisplay => status.displayName;
  String get checkInMethodDisplay => checkInMethod?.displayName ?? '-';

  /// Get formatted meeting date string
  String get formattedMeetingDate {
    return '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}'
        '-${meetingDate.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted check-in time
  String get formattedCheckInTime {
    if (checkInTime == null) return '-';
    final hour = checkInTime!.hour.toString().padLeft(2, '0');
    final minute = checkInTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'memberNumber': memberNumber,
      'memberName': memberName,
      'profileImage': profileImage,
      'meetingId': meetingId,
      'meetingDate': meetingDate.toIso8601String().split('T')[0],
      'status': status.value,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkInMethod': checkInMethod?.value,
      'markedBy': markedBy,
      'notes': notes,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Attendance copyWith({
    String? id,
    String? userId,
    String? memberNumber,
    String? memberName,
    String? profileImage,
    String? meetingId,
    DateTime? meetingDate,
    AttendanceStatus? status,
    DateTime? checkInTime,
    CheckInMethod? checkInMethod,
    String? markedBy,
    String? notes,
    DateTime? created,
    DateTime? updated,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      memberNumber: memberNumber ?? this.memberNumber,
      memberName: memberName ?? this.memberName,
      profileImage: profileImage ?? this.profileImage,
      meetingId: meetingId ?? this.meetingId,
      meetingDate: meetingDate ?? this.meetingDate,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      markedBy: markedBy ?? this.markedBy,
      notes: notes ?? this.notes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Attendance(id: $id, memberName: $memberName, '
        'meetingDate: $formattedMeetingDate, status: ${status.value})';
  }
}
