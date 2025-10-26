part of 'attendance_cubit.dart';

enum AttendanceStateStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class AttendanceState extends Equatable {
  const AttendanceState({
    required this.status,
    required this.attendances,
    this.summary,
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 1,
  });

  factory AttendanceState.initial() {
    return const AttendanceState(
      status: AttendanceStateStatus.initial,
      attendances: [],
    );
  }

  final AttendanceStateStatus status;
  final List<Attendance> attendances;
  final AttendanceSummary? summary;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  AttendanceState copyWith({
    AttendanceStateStatus? status,
    List<Attendance>? attendances,
    AttendanceSummary? summary,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      attendances: attendances ?? this.attendances,
      summary: summary,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        attendances,
        summary,
        errorMessage,
        hasMore,
        currentPage,
      ];
}
