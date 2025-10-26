import 'package:pocketbase/pocketbase.dart';

/// Represents a summary of attendance statistics for a member.
///
/// This model provides cached attendance statistics with:
/// - Total meetings count
/// - Counts by status (present/absent/late/excused)
/// - Calculated attendance rate percentage
/// - Automatic updates from attendance records
///
/// The summary is maintained separately for performance, avoiding the need
/// to aggregate attendance records on every query.
///
/// Example:
/// ```dart
/// final summary = AttendanceSummary(
///   id: '123',
///   userId: 'user123',
///   totalMeetings: 10,
///   totalPresent: 8,
///   totalAbsent: 1,
///   totalLate: 1,
///   totalExcused: 0,
///   attendanceRate: 90.0,
///   created: DateTime.now(),
///   updated: DateTime.now(),
/// );
///
/// if (summary.hasGoodAttendance) {
///   print('Attendance rate: ${summary.attendanceRateDisplay}');
/// }
/// ```
class AttendanceSummary {
  const AttendanceSummary({
    required this.id,
    required this.userId,
    required this.created,
    required this.updated,
    this.totalMeetings = 0,
    this.totalPresent = 0,
    this.totalAbsent = 0,
    this.totalLate = 0,
    this.totalExcused = 0,
    this.attendanceRate = 0.0,
  });

  factory AttendanceSummary.fromRecord(RecordModel record) {
    return AttendanceSummary(
      id: record.id,
      userId: record.data['userId'] as String,
      totalMeetings: (record.data['totalMeetings'] as num?)?.toInt() ?? 0,
      totalPresent: (record.data['totalPresent'] as num?)?.toInt() ?? 0,
      totalAbsent: (record.data['totalAbsent'] as num?)?.toInt() ?? 0,
      totalLate: (record.data['totalLate'] as num?)?.toInt() ?? 0,
      totalExcused: (record.data['totalExcused'] as num?)?.toInt() ?? 0,
      attendanceRate:
          (record.data['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

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

  /// Computed properties

  /// Total meetings actually attended (present + late)
  int get totalAttended => totalPresent + totalLate;

  /// Total meetings not attended (absent - does not include excused)
  int get totalMissed => totalAbsent;

  /// Check if member has good attendance (>= 80%)
  bool get hasGoodAttendance => attendanceRate >= 80.0;

  /// Check if member has perfect attendance (100%)
  bool get hasPerfectAttendance => attendanceRate == 100.0;

  /// Check if member has attended any meetings
  bool get hasAttendedAnyMeeting => totalMeetings > 0;

  /// Get attendance rate as formatted string
  String get attendanceRateDisplay => '${attendanceRate.toStringAsFixed(1)}%';

  /// Get attendance grade based on rate
  String get attendanceGrade {
    if (attendanceRate >= 95) return 'Excellent';
    if (attendanceRate >= 85) return 'Very Good';
    if (attendanceRate >= 75) return 'Good';
    if (attendanceRate >= 60) return 'Fair';
    return 'Poor';
  }

  /// Calculate percentage of meetings attended (present only)
  double get presentPercentage {
    if (totalMeetings == 0) return 0.0;
    return (totalPresent / totalMeetings) * 100;
  }

  /// Calculate percentage of meetings where member was late
  double get latePercentage {
    if (totalMeetings == 0) return 0.0;
    return (totalLate / totalMeetings) * 100;
  }

  /// Calculate percentage of meetings missed (absent)
  double get absentPercentage {
    if (totalMeetings == 0) return 0.0;
    return (totalAbsent / totalMeetings) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalMeetings': totalMeetings,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'totalLate': totalLate,
      'totalExcused': totalExcused,
      'attendanceRate': attendanceRate,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  AttendanceSummary copyWith({
    String? id,
    String? userId,
    int? totalMeetings,
    int? totalPresent,
    int? totalAbsent,
    int? totalLate,
    int? totalExcused,
    double? attendanceRate,
    DateTime? created,
    DateTime? updated,
  }) {
    return AttendanceSummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalMeetings: totalMeetings ?? this.totalMeetings,
      totalPresent: totalPresent ?? this.totalPresent,
      totalAbsent: totalAbsent ?? this.totalAbsent,
      totalLate: totalLate ?? this.totalLate,
      totalExcused: totalExcused ?? this.totalExcused,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'AttendanceSummary(userId: $userId, totalMeetings: $totalMeetings, '
        'attendanceRate: $attendanceRateDisplay)';
  }
}
