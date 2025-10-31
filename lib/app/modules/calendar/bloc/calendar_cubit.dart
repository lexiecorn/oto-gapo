import 'package:bloc/bloc.dart';
import 'package:otogapo/app/modules/calendar/bloc/calendar_state.dart';
import 'package:otogapo/models/attendance.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

/// Cubit for managing attendance calendar
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required PocketBaseService pocketBaseService,
  })  : _pocketBaseService = pocketBaseService,
        super(const CalendarState());

  final PocketBaseService _pocketBaseService;

  /// Load attendance calendar for a specific month
  Future<void> loadAttendanceCalendar({
    required String userId,
    required DateTime month,
  }) async {
    emit(
      state.copyWith(
        status: CalendarStatus.loading,
        focusedMonth: month,
      ),
    );

    try {
      // Get attendance data for the month
      final rawAttendanceMap = await _pocketBaseService.getMonthlyAttendance(
        userId: userId,
        month: month,
      );

      // Convert RecordModels to Attendance objects
      final attendanceMap = <DateTime, Attendance>{};
      for (final entry in rawAttendanceMap.entries) {
        final record = entry.value as RecordModel;
        attendanceMap[entry.key] = Attendance.fromRecord(record);
      }

      // Calculate monthly statistics
      final monthlyStats = _calculateMonthlyStats(attendanceMap);

      // Get streak information
      final rawStreak = await _pocketBaseService.getAttendanceStreak(userId);
      final streak = _convertToAttendanceStreak(rawStreak);

      emit(
        state.copyWith(
          status: CalendarStatus.loaded,
          attendanceMap: attendanceMap,
          monthlyStats: monthlyStats,
          streak: streak,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CalendarStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Select a specific date
  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  /// Change focused month and reload data
  Future<void> changeFocusedMonth(DateTime month, String userId) async {
    await loadAttendanceCalendar(userId: userId, month: month);
  }

  /// Calculate monthly statistics
  MonthlyStats _calculateMonthlyStats(Map<DateTime, Attendance> attendanceMap) {
    if (attendanceMap.isEmpty) {
      return const MonthlyStats();
    }

    var presentDays = 0;
    var absentDays = 0;
    var lateDays = 0;
    var excusedDays = 0;

    for (final attendance in attendanceMap.values) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          presentDays++;
        case AttendanceStatus.absent:
          absentDays++;
        case AttendanceStatus.late:
          lateDays++;
        case AttendanceStatus.excused:
        case AttendanceStatus.leave:
          excusedDays++;
      }
    }

    final totalDays = attendanceMap.length;
    final attendanceRate =
        totalDays > 0 ? (presentDays + lateDays) / totalDays * 100 : 0.0;

    return MonthlyStats(
      totalDays: totalDays,
      presentDays: presentDays,
      absentDays: absentDays,
      lateDays: lateDays,
      excusedDays: excusedDays,
      attendanceRate: attendanceRate,
    );
  }

  /// Get attendance for selected date
  Attendance? get selectedDateAttendance {
    if (state.selectedDate == null) return null;
    return state.getAttendanceForDate(state.selectedDate!);
  }

  /// Convert raw streak data to AttendanceStreak object
  AttendanceStreak _convertToAttendanceStreak(dynamic rawStreak) {
    if (rawStreak == null) return const AttendanceStreak();

    final streakMap = rawStreak as Map<String, dynamic>;
    DateTime? lastDate;

    final lastDateStr = streakMap['lastAttendanceDate'] as String?;
    if (lastDateStr != null && lastDateStr.isNotEmpty) {
      lastDate = DateTime.parse(lastDateStr);
    }

    return AttendanceStreak(
      currentStreak: streakMap['currentStreak'] as int? ?? 0,
      longestStreak: streakMap['longestStreak'] as int? ?? 0,
      lastAttendanceDate: lastDate,
    );
  }
}
