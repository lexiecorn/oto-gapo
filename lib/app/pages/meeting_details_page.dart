import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart' as meeting_cubit;
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/attendance_card.dart';
import 'package:otogapo/models/meeting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage(name: 'MeetingDetailsPageRouter')
class MeetingDetailsPage extends StatefulWidget {
  const MeetingDetailsPage({
    @PathParam('meetingId') required this.meetingId,
    super.key,
  });

  final String meetingId;

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<meeting_cubit.MeetingCubit>().loadMeeting(widget.meetingId);
      context.read<AttendanceCubit>().loadMeetingAttendance(widget.meetingId);
    });
  }

  Future<void> _exportToCSV() async {
    final attendanceState = context.read<AttendanceCubit>().state;
    if (attendanceState.attendances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No attendance data to export')),
      );
      return;
    }

    try {
      final meetingState = context.read<meeting_cubit.MeetingCubit>().state;
      final meeting = meetingState.selectedMeeting;

      // Prepare CSV data
      final List<List<dynamic>> rows = [
        [
          'Member Number',
          'Member Name',
          'Status',
          'Check-in Time',
          'Check-in Method',
          'Notes',
        ],
      ];

      for (final attendance in attendanceState.attendances) {
        rows.add([
          attendance.memberNumber,
          attendance.memberName,
          attendance.statusDisplay,
          attendance.checkInTime?.toIso8601String() ?? '',
          attendance.checkInMethodDisplay,
          attendance.notes ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'attendance_${meeting?.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Attendance Report - ${meeting?.title}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              final meeting = context.read<meeting_cubit.MeetingCubit>().state.selectedMeeting;
              if (meeting != null) {
                context.router.push(
                  MeetingQRCodePageRouter(meeting: meeting),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportToCSV();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
        builder: (context, meetingState) {
          if (meetingState.status == meeting_cubit.MeetingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final meeting = meetingState.selectedMeeting;
          if (meeting == null) {
            return const Center(child: Text('Meeting not found'));
          }

          return Column(
            children: [
              // Meeting Info Card
              Card(
                margin: EdgeInsets.all(16.w),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8.h),
                      _InfoRow(
                        icon: Icons.category,
                        text: meeting.meetingTypeDisplay,
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        text: meeting.formattedDate,
                      ),
                      if (meeting.location != null)
                        _InfoRow(
                          icon: Icons.location_on,
                          text: meeting.location!,
                        ),
                      if (meeting.description != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          meeting.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      SizedBox(height: 16.h),
                      // Attendance Stats
                      _AttendanceStats(meeting: meeting),
                    ],
                  ),
                ),
              ),

              // Attendance List Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.router.push(
                          MarkAttendancePageRouter(meetingId: meeting.id),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Mark'),
                    ),
                  ],
                ),
              ),

              // Attendance List
              Expanded(
                child: BlocBuilder<AttendanceCubit, AttendanceState>(
                  builder: (context, attendanceState) {
                    if (attendanceState.status == AttendanceStateStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (attendanceState.attendances.isEmpty) {
                      return const Center(
                        child: Text('No attendance records yet'),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: attendanceState.attendances.length,
                      itemBuilder: (context, index) {
                        final attendance = attendanceState.attendances[index];
                        return AttendanceMemberItem(
                          attendance: attendance,
                          onStatusChanged: (newStatus) {
                            context.read<AttendanceCubit>().updateAttendanceStatus(
                                  attendance.id,
                                  newStatus.value,
                                );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
        builder: (context, state) {
          final meeting = state.selectedMeeting;
          if (meeting == null || !meeting.isScheduled) return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: () {
              context.read<meeting_cubit.MeetingCubit>().generateQRCode(meeting.id);
            },
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Start Meeting'),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatChip(
          label: 'Present',
          value: meeting.presentCount,
          color: Colors.green,
        ),
        _StatChip(
          label: 'Late',
          value: meeting.lateCount,
          color: Colors.orange,
        ),
        _StatChip(
          label: 'Absent',
          value: meeting.absentCount,
          color: Colors.red,
        ),
        _StatChip(
          label: 'Excused',
          value: meeting.excusedCount,
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
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
