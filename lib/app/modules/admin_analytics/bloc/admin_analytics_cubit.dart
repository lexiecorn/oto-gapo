import 'package:bloc/bloc.dart';
import 'package:otogapo/app/modules/admin_analytics/bloc/admin_analytics_state.dart';
import 'package:otogapo/services/pocketbase_service.dart';

/// Cubit for managing admin analytics and dashboard
class AdminAnalyticsCubit extends Cubit<AdminAnalyticsState> {
  AdminAnalyticsCubit({
    required PocketBaseService pocketBaseService,
  })  : _pocketBaseService = pocketBaseService,
        super(const AdminAnalyticsState());

  final PocketBaseService _pocketBaseService;

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    try {
      final rawStats = await _pocketBaseService.getAdminDashboardStats();

      // Convert dynamic map to DashboardStats
      final statsMap = rawStats as Map<String, dynamic>;
      final stats = DashboardStats(
        totalUsers: statsMap['totalUsers'] as int? ?? 0,
        activeToday: statsMap['activeToday'] as int? ?? 0,
        totalMeetings: statsMap['totalMeetings'] as int? ?? 0,
        upcomingMeetings: statsMap['upcomingMeetings'] as int? ?? 0,
        pendingPayments: statsMap['pendingPayments'] as int? ?? 0,
        totalRevenue: (statsMap['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        averageAttendance: (statsMap['averageAttendance'] as num?)?.toDouble() ?? 0.0,
      );

      emit(
        state.copyWith(
          status: AnalyticsStatus.loaded,
          dashboardStats: stats,
        ),
      );
    } catch (e) {
      print('AdminAnalyticsCubit - Error loading dashboard stats: $e');
      emit(
        state.copyWith(
          status: AnalyticsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load user growth data for charts
  Future<void> loadUserGrowthData(String period) async {
    try {
      final data = await _pocketBaseService.getUserGrowthData(period);

      // Convert List<dynamic> to List<ChartDataPoint>
      final chartData = data.map((item) {
        final map = item as Map<String, dynamic>;
        return ChartDataPoint(
          label: map['label'] as String,
          value: (map['value'] as num).toDouble(),
        );
      }).toList();

      emit(state.copyWith(userGrowthData: chartData));
    } catch (e) {
      print('AdminAnalyticsCubit - Error loading user growth data: $e');
    }
  }

  /// Load attendance statistics for charts
  Future<void> loadAttendanceData(String period) async {
    try {
      final data = await _pocketBaseService.getAttendanceStatsData(period);

      // Convert List<dynamic> to List<ChartDataPoint>
      final chartData = data.map((item) {
        final map = item as Map<String, dynamic>;
        return ChartDataPoint(
          label: map['label'] as String,
          value: (map['value'] as num).toDouble(),
        );
      }).toList();

      emit(state.copyWith(attendanceData: chartData));
    } catch (e) {
      print('AdminAnalyticsCubit - Error loading attendance data: $e');
    }
  }

  /// Load payment/revenue data for charts
  Future<void> loadRevenueData(String period) async {
    try {
      final data = await _pocketBaseService.getRevenueData(period);

      // Convert List<dynamic> to List<ChartDataPoint>
      final chartData = data.map((item) {
        final map = item as Map<String, dynamic>;
        return ChartDataPoint(
          label: map['label'] as String,
          value: (map['value'] as num).toDouble(),
        );
      }).toList();

      emit(state.copyWith(revenueData: chartData));
    } catch (e) {
      print('AdminAnalyticsCubit - Error loading revenue data: $e');
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAll({String period = 'month'}) async {
    await loadDashboardStats();
    await Future.wait([
      loadUserGrowthData(period),
      loadAttendanceData(period),
      loadRevenueData(period),
    ]);
  }
}
