import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/meeting.dart';

/// Card widget displaying meeting information
class MeetingCard extends StatelessWidget {
  const MeetingCard({
    required this.meeting,
    this.onTap,
    super.key,
  });

  final Meeting meeting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _StatusChip(status: meeting.status),
                ],
              ),
              SizedBox(height: 8.h),

              // Meeting Type
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16.sp,
                    color: theme.brightness == Brightness.light
                        ? Colors.blue.shade700
                        : Colors.blue.shade300,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    meeting.meetingTypeDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.blue.shade700
                          : Colors.blue.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Date and Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    meeting.formattedDate,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (meeting.startTime != null) ...[
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${meeting.startTime!.hour.toString().padLeft(2, '0')}:'
                      '${meeting.startTime!.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),

              // Location
              if (meeting.location != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        meeting.location!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Attendance Stats (if completed or ongoing)
              if (meeting.isOngoing || meeting.isCompleted) ...[
                SizedBox(height: 12.h),
                _AttendanceStats(meeting: meeting),
              ],

              // QR Code Indicator
              if (meeting.isQRCodeValid) ...[
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(
                        alpha:
                            theme.brightness == Brightness.dark ? 0.2 : 0.15,),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 16.sp,
                        color: theme.brightness == Brightness.dark
                            ? Colors.green.shade300
                            : Colors.green.shade700,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'QR Code Active',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? Colors.green.shade300
                              : Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final MeetingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case MeetingStatus.scheduled:
        backgroundColor = Colors.blue.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
      case MeetingStatus.ongoing:
        backgroundColor = Colors.green.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
      case MeetingStatus.completed:
        backgroundColor = Colors.grey.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
      case MeetingStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = meeting.totalAttendance;

    if (total == 0) {
      return Text(
        'No attendance records yet',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _StatItem(
          label: 'Present',
          value: meeting.presentCount,
          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        ),
        SizedBox(width: 12.w),
        _StatItem(
          label: 'Late',
          value: meeting.lateCount,
          color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
        ),
        SizedBox(width: 12.w),
        _StatItem(
          label: 'Absent',
          value: meeting.absentCount,
          color: isDark ? Colors.red.shade300 : Colors.red.shade700,
        ),
        const Spacer(),
        if (meeting.totalExpectedMembers != null)
          Text(
            '${meeting.attendanceRate.toStringAsFixed(0)}%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
