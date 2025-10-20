import 'package:equatable/equatable.dart';
import 'package:otogapo/models/attendance.dart';

/// Status of calendar operations
enum CalendarStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Monthly attendance statistics
class MonthlyStats extends Equatable {
  const MonthlyStats({
    this.totalDays = 0,
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
    this.excusedDays = 0,
    this.attendanceRate = 0.0,
  });

  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int excusedDays;
  final double attendanceRate;

  @override
  List<Object?> get props => [
        totalDays,
        presentDays,
        absentDays,
        lateDays,
        excusedDays,
        attendanceRate,
      ];
}

/// Attendance streak information
class AttendanceStreak extends Equatable {
  const AttendanceStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastAttendanceDate,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastAttendanceDate;

  bool get hasActiveStreak => currentStreak > 0;

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastAttendanceDate,
      ];
}

/// State for attendance calendar
class CalendarState extends Equatable {
  const CalendarState({
    this.status = CalendarStatus.initial,
    this.attendanceMap = const {},
    this.selectedDate,
    this.focusedMonth,
    this.monthlyStats = const MonthlyStats(),
    this.streak = const AttendanceStreak(),
    this.errorMessage,
  });

  final CalendarStatus status;
  final Map<DateTime, Attendance> attendanceMap;
  final DateTime? selectedDate;
  final DateTime? focusedMonth;
  final MonthlyStats monthlyStats;
  final AttendanceStreak streak;
  final String? errorMessage;

  bool get isLoading => status == CalendarStatus.loading;
  bool get hasAttendance => attendanceMap.isNotEmpty;

  /// Get attendance for a specific date
  Attendance? getAttendanceForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return attendanceMap[normalizedDate];
  }

  /// Check if date has attendance
  bool hasAttendanceForDate(DateTime date) {
    return getAttendanceForDate(date) != null;
  }

  CalendarState copyWith({
    CalendarStatus? status,
    Map<DateTime, Attendance>? attendanceMap,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    MonthlyStats? monthlyStats,
    AttendanceStreak? streak,
    String? errorMessage,
  }) {
    return CalendarState(
      status: status ?? this.status,
      attendanceMap: attendanceMap ?? this.attendanceMap,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      streak: streak ?? this.streak,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        attendanceMap,
        selectedDate,
        focusedMonth,
        monthlyStats,
        streak,
        errorMessage,
      ];
}
