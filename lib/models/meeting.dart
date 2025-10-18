import 'package:pocketbase/pocketbase.dart';

/// Meeting type enum
enum MeetingType {
  regular('regular', 'Regular Meeting'),
  gmm('gmm', 'General Members Meeting'),
  special('special', 'Special Meeting'),
  emergency('emergency', 'Emergency Meeting');

  const MeetingType(this.value, this.displayName);
  final String value;
  final String displayName;

  static MeetingType fromString(String value) {
    return MeetingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeetingType.regular,
    );
  }
}

/// Meeting status enum
enum MeetingStatus {
  scheduled('scheduled', 'Scheduled'),
  ongoing('ongoing', 'Ongoing'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const MeetingStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static MeetingStatus fromString(String value) {
    return MeetingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeetingStatus.scheduled,
    );
  }
}

/// Represents a meeting or event for attendance tracking.
///
/// This model tracks meetings with:
/// - Meeting details (date, time, location, type)
/// - QR code for attendance check-in
/// - Real-time attendance counts
/// - Status tracking (scheduled/ongoing/completed/cancelled)
///
/// Example:
/// ```dart
/// final meeting = Meeting(
///   id: '123',
///   meetingDate: DateTime(2025, 1, 20),
///   meetingType: MeetingType.regular,
///   title: 'Monthly Meeting',
///   status: MeetingStatus.scheduled,
///   createdBy: 'admin123',
///   created: DateTime.now(),
///   updated: DateTime.now(),
/// );
///
/// if (meeting.isOngoing && meeting.hasQRCode) {
///   print('QR code active until ${meeting.qrCodeExpiry}');
/// }
/// ```
class Meeting {
  const Meeting({
    required this.id,
    required this.meetingDate,
    required this.meetingType,
    required this.title,
    required this.status,
    required this.createdBy,
    required this.created,
    required this.updated,
    this.location,
    this.startTime,
    this.endTime,
    this.qrCodeToken,
    this.qrCodeExpiry,
    this.totalExpectedMembers,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.description,
  });

  factory Meeting.fromRecord(RecordModel record) {
    // Helper function to parse date strings safely
    DateTime parseDate(String dateStr) {
      try {
        // If it's just a date (YYYY-MM-DD), parse it at midnight local time
        if (dateStr.length == 10 && !dateStr.contains('T')) {
          final parts = dateStr.split('-');
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        // Otherwise parse as ISO 8601
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr, error: $e');
        rethrow;
      }
    }

    // Helper to safely get optional date field (PocketBase returns empty string for null dates)
    DateTime? parseOptionalDate(dynamic value) {
      if (value == null || value == '' || (value is String && value.isEmpty)) {
        return null;
      }
      return parseDate(value as String);
    }

    try {
      return Meeting(
        id: record.id,
        meetingDate: parseDate(record.data['meetingDate'] as String),
        meetingType: MeetingType.fromString(
          record.data['meetingType'] as String,
        ),
        title: record.data['title'] as String,
        location: record.data['location'] as String?,
        startTime: parseOptionalDate(record.data['startTime']),
        endTime: parseOptionalDate(record.data['endTime']),
        status: MeetingStatus.fromString(
          record.data['status'] as String? ?? 'scheduled',
        ),
        createdBy: record.data['createdBy'] as String,
        qrCodeToken: record.data['qrCodeToken'] as String?,
        qrCodeExpiry: parseOptionalDate(record.data['qrCodeExpiry']),
        totalExpectedMembers: (record.data['totalExpectedMembers'] as num?)?.toInt(),
        presentCount: (record.data['presentCount'] as num?)?.toInt() ?? 0,
        absentCount: (record.data['absentCount'] as num?)?.toInt() ?? 0,
        lateCount: (record.data['lateCount'] as num?)?.toInt() ?? 0,
        excusedCount: (record.data['excusedCount'] as num?)?.toInt() ?? 0,
        description: record.data['description'] as String?,
        created: DateTime.parse(record.created),
        updated: DateTime.parse(record.updated),
      );
    } catch (e, stackTrace) {
      print('Error parsing Meeting from record: $e');
      print('Record data: ${record.data}');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

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
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final String? description;
  final DateTime created;
  final DateTime updated;

  /// Computed properties
  bool get isScheduled => status == MeetingStatus.scheduled;
  bool get isOngoing => status == MeetingStatus.ongoing;
  bool get isCompleted => status == MeetingStatus.completed;
  bool get isCancelled => status == MeetingStatus.cancelled;

  bool get hasQRCode => qrCodeToken != null && qrCodeToken!.isNotEmpty;

  bool get isQRCodeValid {
    if (!hasQRCode || qrCodeExpiry == null) return false;
    return DateTime.now().isBefore(qrCodeExpiry!);
  }

  int get totalAttendance => presentCount + lateCount + absentCount + excusedCount;

  double get attendanceRate {
    if (totalExpectedMembers == null || totalExpectedMembers == 0) {
      return 0.0;
    }
    final attended = presentCount + lateCount;
    return (attended / totalExpectedMembers!) * 100;
  }

  String get meetingTypeDisplay => meetingType.displayName;
  String get statusDisplay => status.displayName;

  /// Check if meeting date has passed
  bool get isPast => meetingDate.isBefore(DateTime.now());

  /// Check if meeting is today
  bool get isToday {
    final now = DateTime.now();
    return meetingDate.year == now.year && meetingDate.month == now.month && meetingDate.day == now.day;
  }

  /// Get formatted date string
  String get formattedDate {
    return '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}'
        '-${meetingDate.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingDate': meetingDate.toIso8601String().split('T')[0],
      'meetingType': meetingType.value,
      'title': title,
      'location': location,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.value,
      'createdBy': createdBy,
      'qrCodeToken': qrCodeToken,
      'qrCodeExpiry': qrCodeExpiry?.toIso8601String(),
      'totalExpectedMembers': totalExpectedMembers,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'lateCount': lateCount,
      'excusedCount': excusedCount,
      'description': description,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Meeting copyWith({
    String? id,
    DateTime? meetingDate,
    MeetingType? meetingType,
    String? title,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    MeetingStatus? status,
    String? createdBy,
    String? qrCodeToken,
    DateTime? qrCodeExpiry,
    int? totalExpectedMembers,
    int? presentCount,
    int? absentCount,
    int? lateCount,
    int? excusedCount,
    String? description,
    DateTime? created,
    DateTime? updated,
  }) {
    return Meeting(
      id: id ?? this.id,
      meetingDate: meetingDate ?? this.meetingDate,
      meetingType: meetingType ?? this.meetingType,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      qrCodeToken: qrCodeToken ?? this.qrCodeToken,
      qrCodeExpiry: qrCodeExpiry ?? this.qrCodeExpiry,
      totalExpectedMembers: totalExpectedMembers ?? this.totalExpectedMembers,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      excusedCount: excusedCount ?? this.excusedCount,
      description: description ?? this.description,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Meeting(id: $id, title: $title, date: $formattedDate, '
        'type: ${meetingType.value}, status: ${status.value})';
  }
}
