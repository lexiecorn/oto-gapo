import 'package:attendance_repository/attendance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/attendance.dart';
import 'package:otogapo/models/attendance_summary.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({
    required this.attendanceRepository,
  }) : super(AttendanceState.initial());

  final AttendanceRepository attendanceRepository;

  /// Load attendance records for a meeting
  Future<void> loadMeetingAttendance(
    String meetingId, {
    int page = 1,
  }) async {
    if (page == 1) {
      emit(state.copyWith(status: AttendanceStateStatus.loading));
    }

    try {
      final result = await attendanceRepository.getAttendanceForMeeting(
        meetingId,
        page: page,
        perPage: 100,
      );

      final attendances = result.items.map(Attendance.fromRecord).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            attendances: attendances,
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            attendances: [...state.attendances, ...attendances],
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      }
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load attendance history for a user
  Future<void> loadUserAttendance(
    String userId, {
    int page = 1,
  }) async {
    if (page == 1) {
      emit(state.copyWith(status: AttendanceStateStatus.loading));
    }

    try {
      final result = await attendanceRepository.getAttendanceForUser(
        userId,
        page: page,
        perPage: 20,
      );

      final attendances = result.items.map(Attendance.fromRecord).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            attendances: attendances,
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            attendances: [...state.attendances, ...attendances],
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      }
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load attendance summary for a user
  Future<void> loadAttendanceSummary(String userId) async {
    emit(state.copyWith(status: AttendanceStateStatus.loading));

    try {
      final record = await attendanceRepository.getAttendanceSummary(userId);

      if (record != null) {
        final summary = AttendanceSummary.fromRecord(record);
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            summary: summary,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AttendanceStateStatus.loaded,
            summary: null,
          ),
        );
      }
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Mark attendance (create or update)
  Future<void> markAttendance({
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
    emit(state.copyWith(status: AttendanceStateStatus.submitting));

    try {
      final record = await attendanceRepository.markAttendance(
        userId: userId,
        memberNumber: memberNumber,
        memberName: memberName,
        meetingId: meetingId,
        meetingDate: meetingDate,
        status: status,
        profileImage: profileImage,
        checkInTime: checkInTime ?? DateTime.now(),
        checkInMethod: checkInMethod,
        markedBy: markedBy,
        notes: notes,
      );

      final attendance = Attendance.fromRecord(record);

      // Update or add to list
      final updatedAttendances =
          state.attendances.where((a) => !(a.userId == userId && a.meetingId == meetingId)).toList()..add(attendance);

      emit(
        state.copyWith(
          status: AttendanceStateStatus.success,
          attendances: updatedAttendances,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update attendance status
  Future<void> updateAttendanceStatus(
    String attendanceId,
    String newStatus, {
    String? notes,
  }) async {
    emit(state.copyWith(status: AttendanceStateStatus.submitting));

    try {
      final record = await attendanceRepository.updateAttendance(
        attendanceId,
        {
          'status': newStatus,
          if (notes != null) 'notes': notes,
        },
      );

      final attendance = Attendance.fromRecord(record);

      // Update in list
      final updatedAttendances = state.attendances.map((a) {
        return a.id == attendanceId ? attendance : a;
      }).toList();

      emit(
        state.copyWith(
          status: AttendanceStateStatus.success,
          attendances: updatedAttendances,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    emit(state.copyWith(status: AttendanceStateStatus.submitting));

    try {
      await attendanceRepository.deleteAttendance(attendanceId);

      final updatedAttendances = state.attendances.where((a) => a.id != attendanceId).toList();

      emit(
        state.copyWith(
          status: AttendanceStateStatus.success,
          attendances: updatedAttendances,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Get attendance statistics for current loaded attendances
  AttendanceStats getStats() {
    var presentCount = 0;
    var lateCount = 0;
    var absentCount = 0;
    var excusedCount = 0;

    for (final attendance in state.attendances) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          presentCount++;
        case AttendanceStatus.late:
          lateCount++;
        case AttendanceStatus.absent:
          absentCount++;
        case AttendanceStatus.excused:
        case AttendanceStatus.leave:
          excusedCount++;
      }
    }

    final total = state.attendances.length;
    final attended = presentCount + lateCount;
    final attendanceRate = total > 0 ? (attended / total * 100) : 0.0;

    return AttendanceStats(
      total: total,
      present: presentCount,
      late: lateCount,
      absent: absentCount,
      excused: excusedCount,
      attendanceRate: attendanceRate,
    );
  }

  /// Reset state
  void reset() {
    emit(AttendanceState.initial());
  }
}

/// Helper class for attendance statistics
class AttendanceStats {
  const AttendanceStats({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.excused,
    required this.attendanceRate,
  });

  final int total;
  final int present;
  final int late;
  final int absent;
  final int excused;
  final double attendanceRate;
}
