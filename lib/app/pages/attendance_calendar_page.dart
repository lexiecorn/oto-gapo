import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/calendar/bloc/calendar_cubit.dart';
import 'package:otogapo/app/modules/calendar/bloc/calendar_state.dart';
import 'package:otogapo/app/widgets/skeleton_loader.dart';
import 'package:otogapo/models/attendance.dart';
import 'package:table_calendar/table_calendar.dart';

@RoutePage(name: 'AttendanceCalendarPageRouter')
class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  State<AttendanceCalendarPage> createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Load initial calendar data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        context.read<CalendarCubit>().loadAttendanceCalendar(
              userId: authState.user!.id,
              month: _focusedDay,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Calendar',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          if (state.isLoading) {
            return _buildLoadingState();
          }

          if (state.status == CalendarStatus.error) {
            return _buildErrorState(state.errorMessage ?? 'Failed to load calendar');
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<CalendarCubit>().loadAttendanceCalendar(
                    userId: userId,
                    month: _focusedDay,
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Streak Card
                  if (state.streak.hasActiveStreak) _buildStreakCard(state.streak),

                  // Calendar
                  _buildCalendar(state, userId),

                  // Monthly Statistics
                  _buildMonthlyStatsCard(state.monthlyStats),

                  // Selected Date Details
                  if (state.selectedDate != null) _buildDateDetails(state),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        SkeletonLoader(
          width: double.infinity,
          height: 400.h,
        ),
        SizedBox(height: 20.h),
        SkeletonLoader(
          width: double.infinity,
          height: 150.h,
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
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
            message,
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState.user != null) {
                context.read<CalendarCubit>().loadAttendanceCalendar(
                      userId: authState.user!.id,
                      month: _focusedDay,
                    );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(AttendanceStreak streak) {
    return Card(
      margin: EdgeInsets.all(16.sp),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(20.sp),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48.sp,
              color: Colors.white,
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: 2000.ms,
                  color: Colors.amber,
                )
                .shake(duration: 500.ms, hz: 2),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${streak.currentStreak} Meeting Streak!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Longest: ${streak.longestStreak} meetings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (streak.lastAttendanceDate != null)
                    Text(
                      'Last attended: ${DateFormat('MMM d, y').format(streak.lastAttendanceDate!)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          duration: 400.ms,
          begin: const Offset(0.9, 0.9),
          curve: Curves.easeOut,
        );
  }

  Widget _buildCalendar(CalendarState state, String userId) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.shade300,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            context.read<CalendarCubit>().selectDate(selectedDay);
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            context.read<CalendarCubit>().changeFocusedMonth(
                  focusedDay,
                  userId,
                );
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final attendance = state.getAttendanceForDate(date);
              if (attendance == null) return null;

              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(attendance.status),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMonthlyStatsCard(MonthlyStats stats) {
    if (stats.totalDays == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Statistics',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Present',
                  stats.presentDays,
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Late',
                  stats.lateDays,
                  Colors.orange,
                  Icons.access_time,
                ),
                _buildStatItem(
                  'Absent',
                  stats.absentDays,
                  Colors.red,
                  Icons.cancel,
                ),
                _buildStatItem(
                  'Excused',
                  stats.excusedDays,
                  Colors.blue,
                  Icons.info,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance Rate',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${stats.attendanceRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 4.h),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDateDetails(CalendarState state) {
    final attendance = state.getAttendanceForDate(state.selectedDate!);

    if (attendance == null) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                Text(
                  'No meeting on ${DateFormat('MMMM d, y').format(state.selectedDate!)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(attendance.status),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(state.selectedDate!),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailRow('Status', _getAttendanceLabel(attendance.status)),
            if (attendance.checkInTime != null)
              _buildDetailRow(
                'Check-in Time',
                DateFormat('h:mm a').format(attendance.checkInTime!),
              ),
            _buildDetailRow('Method', _getCheckInMethodLabel(attendance.checkInMethod ?? CheckInMethod.manual)),
            if (attendance.notes != null && attendance.notes!.isNotEmpty) _buildDetailRow('Notes', attendance.notes!),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
        );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.excused:
      case AttendanceStatus.leave:
        return Colors.blue;
    }
  }

  String _getAttendanceLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.leave:
        return 'On Leave';
    }
  }

  String _getCheckInMethodLabel(CheckInMethod method) {
    switch (method) {
      case CheckInMethod.qrScan:
        return 'QR Code Scan';
      case CheckInMethod.manual:
        return 'Manual Check-in';
      case CheckInMethod.auto:
        return 'Auto Check-in';
    }
  }
}
