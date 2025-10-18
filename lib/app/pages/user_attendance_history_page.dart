import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/widgets/attendance_card.dart';
import 'package:otogapo/models/attendance_summary.dart';

@RoutePage(name: 'UserAttendanceHistoryPageRouter')
class UserAttendanceHistoryPage extends StatefulWidget {
  const UserAttendanceHistoryPage({super.key});

  @override
  State<UserAttendanceHistoryPage> createState() => _UserAttendanceHistoryPageState();
}

class _UserAttendanceHistoryPageState extends State<UserAttendanceHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<ProfileCubit>().state.user;
      if (user != null) {
        context.read<AttendanceCubit>().loadUserAttendance(user.uid);
        context.read<AttendanceCubit>().loadAttendanceSummary(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final cubit = context.read<AttendanceCubit>();
      final user = context.read<ProfileCubit>().state.user;

      if (cubit.state.hasMore && cubit.state.status != AttendanceStateStatus.loading && user != null) {
        cubit.loadUserAttendance(
          user.uid,
          page: cubit.state.currentPage + 1,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = context.read<ProfileCubit>().state.user;
              if (user != null) {
                context.read<AttendanceCubit>().loadUserAttendance(user.uid);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          return Column(
            children: [
              // Summary Card
              if (state.summary != null) _SummaryCard(summary: state.summary!),

              // Attendance List
              Expanded(
                child: _buildAttendanceList(state, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttendanceList(AttendanceState state, ThemeData theme) {
    if (state.status == AttendanceStateStatus.loading && state.attendances.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AttendanceStateStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Error loading attendance',
              style: theme.textTheme.titleMedium,
            ),
            if (state.errorMessage != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                final user = context.read<ProfileCubit>().state.user;
                if (user != null) {
                  context.read<AttendanceCubit>().loadUserAttendance(user.uid);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.attendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No attendance records yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<ProfileCubit>().state.user;
        if (user != null) {
          await context.read<AttendanceCubit>().loadUserAttendance(user.uid);
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        itemCount: state.attendances.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.attendances.length) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final attendance = state.attendances[index];
          return AttendanceCard(
            attendance: attendance,
            showMeetingInfo: true,
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Total',
                  value: summary.totalMeetings.toString(),
                  color: theme.colorScheme.primary,
                ),
                _StatColumn(
                  label: 'Present',
                  value: summary.totalPresent.toString(),
                  color: Colors.green,
                ),
                _StatColumn(
                  label: 'Late',
                  value: summary.totalLate.toString(),
                  color: Colors.orange,
                ),
                _StatColumn(
                  label: 'Absent',
                  value: summary.totalAbsent.toString(),
                  color: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _getAttendanceRateColor(summary.attendanceRate).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance Rate',
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    summary.attendanceRateDisplay,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getAttendanceRateColor(summary.attendanceRate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
