import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/widgets/analytics_stat_card.dart';
import 'package:otogapo/app/widgets/compliance_chart.dart';
import 'package:otogapo/app/widgets/payment_method_pie_chart.dart';
import 'package:otogapo/app/widgets/revenue_trend_chart.dart';
import 'package:otogapo/models/payment_analytics.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:provider/provider.dart';

/// Analytics page showing payment trends and statistics
/// Displays system-wide analytics for admins, personal analytics for members
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isLoading = true;
  PaymentAnalytics? _analytics;
  String? _error;
  String _selectedRange = '6months'; // 6months, 12months, all
  bool _isAdmin = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final profileState = context.read<ProfileCubit>().state;
    final user = profileState.user;

    setState(() {
      _userId = user.uid;
      // Admin membership types are 1 (President) and 2 (Vice President)
      _isAdmin = user.membership_type == 1 || user.membership_type == 2;
    });

    await _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pocketBaseService = PocketBaseService();

      // Calculate date range
      final now = DateTime.now();
      String? startMonth;
      String? endMonth = DateFormat('yyyy-MM').format(now);

      switch (_selectedRange) {
        case '6months':
          startMonth =
              DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 5));
        case '12months':
          startMonth =
              DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 11));
        case 'all':
          startMonth = null;
          endMonth = null;
      }

      // Load analytics based on user role
      final analytics = _isAdmin
          ? await pocketBaseService.getSystemWideAnalytics(
              startMonth: startMonth,
              endMonth: endMonth,
            )
          : await pocketBaseService.getUserAnalytics(
              _userId,
              startMonth: startMonth,
              endMonth: endMonth,
            );

      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdmin ? 'System Analytics' : 'My Payment Analytics',
          style: TextStyle(fontSize: 18.sp),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedRange = value;
              });
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '6months',
                child: Text('Last 6 Months'),
              ),
              const PopupMenuItem(
                value: '12months',
                child: Text('Last 12 Months'),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading analytics...',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error loading analytics',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _loadAnalytics,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_analytics == null || _analytics!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(height: 16.h),
              Text(
                'No analytics data available',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Analytics will appear here once payment transactions are recorded.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              _buildSummaryCards(),
              SizedBox(height: 24.h),

              // Revenue trend chart
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: RevenueTrendChart(
                  monthlyRevenues: _analytics!.monthlyRevenues,
                ),
              ),
              SizedBox(height: 24.h),

              // Compliance chart
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ComplianceChart(
                  complianceRates: _analytics!.complianceRates,
                ),
              ),
              SizedBox(height: 24.h),

              // Payment method pie chart
              if (_analytics!.paymentMethodStats.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: PaymentMethodPieChart(
                    paymentMethodStats: _analytics!.paymentMethodStats,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.4, // Increased to give more height
      children: [
        AnalyticsStatCard(
          title: _isAdmin ? 'Total Revenue' : 'Total Paid',
          value: '₱${_analytics!.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          subtitle: _getRangeName(),
          color: Colors.green,
        ),
        AnalyticsStatCard(
          title: _isAdmin ? 'Total Transactions' : 'Payment Count',
          value: '${_analytics!.totalTransactions}',
          icon: Icons.receipt_long,
          subtitle: _getRangeName(),
          color: Colors.blue,
        ),
        AnalyticsStatCard(
          title: 'Compliance Rate',
          value: '${_analytics!.overallComplianceRate.toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          subtitle: _getComplianceSubtitle(),
          trend: _getComplianceTrend(),
          trendColor: _getComplianceTrendColor(),
          color: _getComplianceColor(),
        ),
        AnalyticsStatCard(
          title: 'Average Payment',
          value: '₱${_analytics!.averagePaymentAmount.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          subtitle: 'Per transaction',
          color: Colors.orange,
        ),
      ],
    );
  }

  String _getRangeName() {
    switch (_selectedRange) {
      case '6months':
        return 'Last 6 months';
      case '12months':
        return 'Last 12 months';
      case 'all':
        return 'All time';
      default:
        return '';
    }
  }

  String _getComplianceSubtitle() {
    final rate = _analytics!.overallComplianceRate;
    if (rate >= 90) return 'Excellent';
    if (rate >= 70) return 'Good';
    return 'Needs improvement';
  }

  String? _getComplianceTrend() {
    final rate = _analytics!.overallComplianceRate;
    if (rate >= 90) return '✓ Excellent';
    if (rate >= 70) return '↗ Good';
    return '↓ Low';
  }

  Color _getComplianceTrendColor() {
    final rate = _analytics!.overallComplianceRate;
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getComplianceColor() {
    final rate = _analytics!.overallComplianceRate;
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }
}
