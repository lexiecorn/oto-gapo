import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/attendance.dart';

/// Card widget displaying attendance record
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    required this.attendance,
    this.onTap,
    this.showMeetingInfo = false,
    super.key,
  });

  final Attendance attendance;
  final VoidCallback? onTap;
  final bool showMeetingInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Validate profile image URL
    final hasValidImage = attendance.profileImage != null &&
        attendance.profileImage!.isNotEmpty &&
        (attendance.profileImage!.startsWith('http://') || attendance.profileImage!.startsWith('https://'));

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Profile Image or Icon
              CircleAvatar(
                radius: 24.r,
                backgroundImage: hasValidImage ? NetworkImage(attendance.profileImage!) : null,
                child: !hasValidImage ? Icon(Icons.person, size: 24.sp) : null,
              ),
              SizedBox(width: 12.w),

              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.memberName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      attendance.memberNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showMeetingInfo) ...[
                      SizedBox(height: 4.h),
                      Text(
                        attendance.formattedMeetingDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(status: attendance.status),
                  if (attendance.checkInTime != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          attendance.formattedCheckInTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (attendance.wasScanned) ...[
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.qr_code_scanner,
                      size: 16.sp,
                      color: theme.brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade700,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = Colors.green.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
        icon = Icons.check_circle;
      case AttendanceStatus.late:
        backgroundColor = Colors.orange.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        icon = Icons.schedule;
      case AttendanceStatus.absent:
        backgroundColor = Colors.red.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
        icon = Icons.cancel;
      case AttendanceStatus.excused:
        backgroundColor = Colors.blue.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
        icon = Icons.info;
      case AttendanceStatus.leave:
        backgroundColor = Colors.purple.withValues(alpha: isDark ? 0.2 : 0.15);
        textColor = isDark ? Colors.purple.shade300 : Colors.purple.shade800;
        icon = Icons.event_busy;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// List item for attendance member in a meeting
class AttendanceMemberItem extends StatelessWidget {
  const AttendanceMemberItem({
    required this.attendance,
    required this.onStatusChanged,
    super.key,
  });

  final Attendance attendance;
  final void Function(AttendanceStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Validate profile image URL
    final hasValidImage = attendance.profileImage != null &&
        attendance.profileImage!.isNotEmpty &&
        (attendance.profileImage!.startsWith('http://') || attendance.profileImage!.startsWith('https://'));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundImage: hasValidImage ? NetworkImage(attendance.profileImage!) : null,
          child: !hasValidImage ? const Icon(Icons.person) : null,
        ),
        title: Text(
          attendance.memberName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(attendance.memberNumber),
        trailing: _StatusChip(status: attendance.status),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: AttendanceStatus.values.map((status) {
                    final isSelected = status == attendance.status;
                    return ActionChip(
                      label: Text(
                        status.displayName,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
                      side: isSelected ? BorderSide(color: theme.colorScheme.primary) : null,
                      onPressed: () => onStatusChanged(status),
                    );
                  }).toList(),
                ),
                if (attendance.checkInTime != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Check-in: ${attendance.formattedCheckInTime} '
                    '(${attendance.checkInMethodDisplay})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Notes: ${attendance.notes}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
