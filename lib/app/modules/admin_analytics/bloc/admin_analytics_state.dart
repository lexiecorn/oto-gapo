import 'package:equatable/equatable.dart';

/// Status of analytics operations
enum AnalyticsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Dashboard statistics
class DashboardStats extends Equatable {
  const DashboardStats({
    this.totalUsers = 0,
    this.activeToday = 0,
    this.totalMeetings = 0,
    this.upcomingMeetings = 0,
    this.pendingPayments = 0,
    this.totalRevenue = 0.0,
    this.averageAttendance = 0.0,
  });

  final int totalUsers;
  final int activeToday;
  final int totalMeetings;
  final int upcomingMeetings;
  final int pendingPayments;
  final double totalRevenue;
  final double averageAttendance;

  @override
  List<Object?> get props => [
        totalUsers,
        activeToday,
        totalMeetings,
        upcomingMeetings,
        pendingPayments,
        totalRevenue,
        averageAttendance,
      ];
}

/// Chart data point
class ChartDataPoint extends Equatable {
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });

  final String label;
  final double value;
  final DateTime? date;

  @override
  List<Object?> get props => [label, value, date];
}

/// State for admin analytics
class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.dashboardStats = const DashboardStats(),
    this.userGrowthData = const [],
    this.attendanceData = const [],
    this.revenueData = const [],
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final DashboardStats dashboardStats;
  final List<ChartDataPoint> userGrowthData;
  final List<ChartDataPoint> attendanceData;
  final List<ChartDataPoint> revenueData;
  final String? errorMessage;

  bool get isLoading => status == AnalyticsStatus.loading;
  bool get hasData => status == AnalyticsStatus.loaded;

  AdminAnalyticsState copyWith({
    AnalyticsStatus? status,
    DashboardStats? dashboardStats,
    List<ChartDataPoint>? userGrowthData,
    List<ChartDataPoint>? attendanceData,
    List<ChartDataPoint>? revenueData,
    String? errorMessage,
  }) {
    return AdminAnalyticsState(
      status: status ?? this.status,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      attendanceData: attendanceData ?? this.attendanceData,
      revenueData: revenueData ?? this.revenueData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dashboardStats,
        userGrowthData,
        attendanceData,
        revenueData,
        errorMessage,
      ];
}
