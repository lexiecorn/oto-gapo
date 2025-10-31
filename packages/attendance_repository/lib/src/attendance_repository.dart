import 'dart:math';

import 'package:attendance_repository/src/models/attendance_failure.dart';
import 'package:pocketbase/pocketbase.dart';

/// Repository for managing attendance and meetings with PocketBase
class AttendanceRepository {
  AttendanceRepository({required PocketBase pocketBase}) : _pocketBase = pocketBase;

  final PocketBase _pocketBase;

  // Collection names
  static const String _meetingsCollection = 'meetings';
  static const String _attendanceCollection = 'attendance';
  static const String _attendanceSummaryCollection = 'attendance_summary';

  // ==================== MEETINGS ====================

  /// Get all meetings with optional filters
  Future<ResultList<RecordModel>> getMeetings({
    int page = 1,
    int perPage = 20,
    String? filter,
    String sort = '-meetingDate',
  }) async {
    try {
      return await _pocketBase.collection(_meetingsCollection).getList(
            page: page,
            perPage: perPage,
            filter: filter,
            sort: sort,
          );
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_meetings_failed',
        message: 'Failed to get meetings',
        details: e.toString(),
      );
    }
  }

  /// Get a single meeting by ID
  Future<RecordModel> getMeeting(String meetingId) async {
    try {
      return await _pocketBase.collection(_meetingsCollection).getOne(
            meetingId,
          );
    } catch (e) {
      if (e.toString().contains('404')) {
        throw const MeetingNotFoundFailure();
      }
      throw AttendanceFailure(
        code: 'get_meeting_failed',
        message: 'Failed to get meeting',
        details: e.toString(),
      );
    }
  }

  /// Create a new meeting
  Future<RecordModel> createMeeting({
    required DateTime meetingDate,
    required String meetingType,
    required String title,
    required String createdBy,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String status = 'scheduled',
    String? description,
    int? totalExpectedMembers,
  }) async {
    try {
      // Format dates for PocketBase
      // meetingDate should be date-only (YYYY-MM-DD)
      final formattedMeetingDate = '${meetingDate.year.toString().padLeft(4, '0')}-'
          '${meetingDate.month.toString().padLeft(2, '0')}-'
          '${meetingDate.day.toString().padLeft(2, '0')}';

      final data = {
        'meetingDate': formattedMeetingDate,
        'meetingType': meetingType,
        'title': title,
        'status': status,
        'createdBy': createdBy,
        if (location != null) 'location': location,
        if (startTime != null) 'startTime': startTime.toUtc().toIso8601String(),
        if (endTime != null) 'endTime': endTime.toUtc().toIso8601String(),
        if (description != null) 'description': description,
        if (totalExpectedMembers != null) 'totalExpectedMembers': totalExpectedMembers,
        'presentCount': 0,
        'absentCount': 0,
        'lateCount': 0,
        'excusedCount': 0,
      };

      print('Creating meeting with data: $data');

      return await _pocketBase.collection(_meetingsCollection).create(
            body: data,
          );
    } catch (e) {
      print('Error creating meeting: $e');
      throw AttendanceFailure(
        code: 'create_meeting_failed',
        message: 'Failed to create meeting',
        details: e.toString(),
      );
    }
  }

  /// Update an existing meeting
  Future<RecordModel> updateMeeting(
    String meetingId,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _pocketBase.collection(_meetingsCollection).update(
            meetingId,
            body: data,
          );
    } catch (e) {
      throw AttendanceFailure(
        code: 'update_meeting_failed',
        message: 'Failed to update meeting',
        details: e.toString(),
      );
    }
  }

  /// Delete a meeting
  Future<void> deleteMeeting(String meetingId) async {
    try {
      await _pocketBase.collection(_meetingsCollection).delete(meetingId);
    } catch (e) {
      throw AttendanceFailure(
        code: 'delete_meeting_failed',
        message: 'Failed to delete meeting',
        details: e.toString(),
      );
    }
  }

  /// Generate QR code for a meeting
  Future<RecordModel> generateQRCode(
    String meetingId, {
    Duration validity = const Duration(hours: 3),
  }) async {
    try {
      final token = _generateRandomToken();
      final expiry = DateTime.now().add(validity);

      return await updateMeeting(
        meetingId,
        {
          'qrCodeToken': token,
          'qrCodeExpiry': expiry.toIso8601String(),
          'status': 'ongoing',
        },
      );
    } catch (e) {
      throw AttendanceFailure(
        code: 'generate_qr_failed',
        message: 'Failed to generate QR code',
        details: e.toString(),
      );
    }
  }

  /// Validate QR code and return meeting if valid
  Future<RecordModel?> validateQRCode(String token) async {
    try {
      final now = DateTime.now().toIso8601String();
      final filter = 'qrCodeToken = "$token" && qrCodeExpiry > "$now" && status = "ongoing"';

      final result = await _pocketBase.collection(_meetingsCollection).getList(
            filter: filter,
            perPage: 1,
          );

      if (result.items.isEmpty) {
        return null;
      }

      return result.items.first;
    } catch (e) {
      throw AttendanceFailure(
        code: 'validate_qr_failed',
        message: 'Failed to validate QR code',
        details: e.toString(),
      );
    }
  }

  // ==================== ATTENDANCE ====================

  /// Get all attendance records for a meeting
  Future<ResultList<RecordModel>> getAttendanceForMeeting(
    String meetingId, {
    int page = 1,
    int perPage = 100,
    String sort = 'memberName',
  }) async {
    try {
      return await _pocketBase.collection(_attendanceCollection).getList(
            page: page,
            perPage: perPage,
            filter: 'meetingId = "$meetingId"',
            sort: sort,
            expand: 'userId',
          );
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_attendance_failed',
        message: 'Failed to get attendance',
        details: e.toString(),
      );
    }
  }

  /// Get attendance history for a user
  Future<ResultList<RecordModel>> getAttendanceForUser(
    String userId, {
    int page = 1,
    int perPage = 20,
    String sort = '-meetingDate',
  }) async {
    try {
      return await _pocketBase.collection(_attendanceCollection).getList(
            page: page,
            perPage: perPage,
            filter: 'userId = "$userId"',
            sort: sort,
            expand: 'meetingId',
          );
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_user_attendance_failed',
        message: 'Failed to get user attendance',
        details: e.toString(),
      );
    }
  }

  /// Get a specific attendance record
  Future<RecordModel?> getAttendanceRecord(
    String userId,
    String meetingId,
  ) async {
    try {
      final filter = 'userId = "$userId" && meetingId = "$meetingId"';
      final result = await _pocketBase.collection(_attendanceCollection).getList(
            filter: filter,
            perPage: 1,
          );

      if (result.items.isEmpty) {
        return null;
      }

      return result.items.first;
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_attendance_record_failed',
        message: 'Failed to get attendance record',
        details: e.toString(),
      );
    }
  }

  /// Mark attendance for a user at a meeting
  Future<RecordModel> markAttendance({
    required String userId,
    required String memberNumber,
    required String memberName,
    required String meetingId,
    required DateTime meetingDate,
    required String status,
    String? profileImage,
    DateTime? checkInTime,
    String? checkInMethod,
    String? markedBy,
    String? notes,
  }) async {
    try {
      // Check if attendance already exists
      final existing = await getAttendanceRecord(userId, meetingId);

      if (existing != null) {
        // Update existing attendance
        return await _pocketBase.collection(_attendanceCollection).update(
          existing.id,
          body: {
            'status': status,
            if (checkInTime != null) 'checkInTime': checkInTime.toIso8601String(),
            if (checkInMethod != null) 'checkInMethod': checkInMethod,
            if (markedBy != null) 'markedBy': markedBy,
            if (notes != null) 'notes': notes,
          },
        );
      }

      // Create new attendance record
      final data = {
        'userId': userId,
        'memberNumber': memberNumber,
        'memberName': memberName,
        'meetingId': meetingId,
        'meetingDate': meetingDate.toIso8601String().split('T')[0],
        'status': status,
        if (profileImage != null) 'profileImage': profileImage,
        if (checkInTime != null) 'checkInTime': checkInTime.toIso8601String(),
        if (checkInMethod != null) 'checkInMethod': checkInMethod,
        if (markedBy != null) 'markedBy': markedBy,
        if (notes != null) 'notes': notes,
      };

      final record = await _pocketBase.collection(_attendanceCollection).create(
            body: data,
          );

      // Update meeting counts
      await _updateMeetingCounts(meetingId);

      // Update user summary
      await _updateUserSummary(userId);

      return record;
    } catch (e) {
      if (e.toString().contains('duplicate') || e.toString().contains('UNIQUE constraint')) {
        throw const DuplicateAttendanceFailure();
      }
      throw AttendanceFailure(
        code: 'mark_attendance_failed',
        message: 'Failed to mark attendance',
        details: e.toString(),
      );
    }
  }

  /// Update attendance status
  Future<RecordModel> updateAttendance(
    String attendanceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final record = await _pocketBase.collection(_attendanceCollection).update(
            attendanceId,
            body: data,
          );

      // Update meeting counts
      final meetingId = record.data['meetingId'] as String;
      await _updateMeetingCounts(meetingId);

      // Update user summary
      final userId = record.data['userId'] as String;
      await _updateUserSummary(userId);

      return record;
    } catch (e) {
      throw AttendanceFailure(
        code: 'update_attendance_failed',
        message: 'Failed to update attendance',
        details: e.toString(),
      );
    }
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      // Get record first to update counts after deletion
      final record = await _pocketBase.collection(_attendanceCollection).getOne(attendanceId);
      final meetingId = record.data['meetingId'] as String;
      final userId = record.data['userId'] as String;

      await _pocketBase.collection(_attendanceCollection).delete(attendanceId);

      // Update meeting counts
      await _updateMeetingCounts(meetingId);

      // Update user summary
      await _updateUserSummary(userId);
    } catch (e) {
      throw AttendanceFailure(
        code: 'delete_attendance_failed',
        message: 'Failed to delete attendance',
        details: e.toString(),
      );
    }
  }

  // ==================== ATTENDANCE SUMMARY ====================

  /// Get attendance summary for a user
  Future<RecordModel?> getAttendanceSummary(String userId) async {
    try {
      final filter = 'userId = "$userId"';
      final result = await _pocketBase.collection(_attendanceSummaryCollection).getList(
            filter: filter,
            perPage: 1,
          );

      if (result.items.isEmpty) {
        return null;
      }

      return result.items.first;
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_summary_failed',
        message: 'Failed to get attendance summary',
        details: e.toString(),
      );
    }
  }

  /// Get all attendance summaries with optional filter
  Future<ResultList<RecordModel>> getAllSummaries({
    int page = 1,
    int perPage = 50,
    String? filter,
    String sort = '-attendanceRate',
  }) async {
    try {
      return await _pocketBase.collection(_attendanceSummaryCollection).getList(
            page: page,
            perPage: perPage,
            filter: filter,
            sort: sort,
            expand: 'userId',
          );
    } catch (e) {
      throw AttendanceFailure(
        code: 'get_summaries_failed',
        message: 'Failed to get attendance summaries',
        details: e.toString(),
      );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Update meeting attendance counts
  Future<void> _updateMeetingCounts(String meetingId) async {
    try {
      // Get all attendance for this meeting
      final result = await _pocketBase.collection(_attendanceCollection).getList(
            filter: 'meetingId = "$meetingId"',
            perPage: 500, // Assume max 500 members
          );

      var presentCount = 0;
      var lateCount = 0;
      var absentCount = 0;
      var excusedCount = 0;

      for (final record in result.items) {
        final status = record.data['status'] as String;
        switch (status) {
          case 'present':
            presentCount++;
          case 'late':
            lateCount++;
          case 'absent':
            absentCount++;
          case 'excused':
          case 'leave':
            excusedCount++;
        }
      }

      await _pocketBase.collection(_meetingsCollection).update(
        meetingId,
        body: {
          'presentCount': presentCount,
          'lateCount': lateCount,
          'absentCount': absentCount,
          'excusedCount': excusedCount,
        },
      );
    } catch (e) {
      // Log error but don't throw - counts are not critical
      print('Warning: Failed to update meeting counts: $e');
    }
  }

  /// Update user attendance summary
  Future<void> _updateUserSummary(String userId) async {
    try {
      // Get all attendance for this user
      final result = await _pocketBase.collection(_attendanceCollection).getList(
            filter: 'userId = "$userId"',
            perPage: 500, // Assume max 500 meetings
          );

      final totalMeetings = result.items.length;
      var totalPresent = 0;
      var totalLate = 0;
      var totalAbsent = 0;
      var totalExcused = 0;

      for (final record in result.items) {
        final status = record.data['status'] as String;
        switch (status) {
          case 'present':
            totalPresent++;
          case 'late':
            totalLate++;
          case 'absent':
            totalAbsent++;
          case 'excused':
          case 'leave':
            totalExcused++;
        }
      }

      final attendanceRate = totalMeetings > 0 ? ((totalPresent + totalLate) / totalMeetings * 100) : 0.0;

      // Check if summary exists
      final existingSummary = await getAttendanceSummary(userId);

      final summaryData = {
        'userId': userId,
        'totalMeetings': totalMeetings,
        'totalPresent': totalPresent,
        'totalLate': totalLate,
        'totalAbsent': totalAbsent,
        'totalExcused': totalExcused,
        'attendanceRate': attendanceRate,
      };

      if (existingSummary != null) {
        // Update existing summary
        await _pocketBase.collection(_attendanceSummaryCollection).update(
              existingSummary.id,
              body: summaryData,
            );
      } else {
        // Create new summary
        await _pocketBase.collection(_attendanceSummaryCollection).create(
              body: summaryData,
            );
      }
    } catch (e) {
      // Log error but don't throw - summary is not critical
      print('Warning: Failed to update user summary: $e');
    }
  }

  /// Generate a random token for QR codes
  String _generateRandomToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      12,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
