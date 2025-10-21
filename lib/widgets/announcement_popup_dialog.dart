import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:local_storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';

/// A beautiful dialog for displaying announcements with images
class AnnouncementPopupDialog extends StatelessWidget {
  const AnnouncementPopupDialog({
    required this.announcement,
    required this.imageUrl,
    super.key,
    this.onDismiss,
  });

  final RecordModel announcement;
  final String? imageUrl;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final type = announcement.data['type'] as String? ?? 'general';
    final title = announcement.data['title'] as String? ?? 'Announcement';
    final content = announcement.data['content'] as String? ?? '';
    final dateString = announcement.data['created'] as String?;
    final date = dateString != null ? DateTime.tryParse(dateString) : null;

    return Dialog(
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: _getTypeColor(type, isDark).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type, isDark),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _getTypeIcon(type),
                      size: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(type, isDark),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Important Announcement',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDismiss?.call();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 24.sp,
                      color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? colorScheme.onSurface : Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    if (date != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14.sp,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            DateFormat('MMMM dd, yyyy • h:mm a').format(date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 20.h),

                    // Image if present
                    if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            height: 200.h,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200.h,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              size: 48.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // Content
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.9) : Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface.withOpacity(0.5) : Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: [
                  // Don't show again checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) async {
                          if (value == true) {
                            await _markAsSeenToday(announcement.id);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              onDismiss?.call();
                            }
                          }
                        },
                        activeColor: colorScheme.primary,
                      ),
                      Expanded(
                        child: Text(
                          "Don't show this again today",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getTypeColor(type, isDark),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Color _getTypeColor(String type, bool isDark) {
    switch (type) {
      case 'general':
        return isDark ? Colors.blue[300]! : Colors.blue[600]!;
      case 'important':
        return isDark ? Colors.orange[300]! : Colors.orange[600]!;
      case 'urgent':
        return isDark ? Colors.red[300]! : Colors.red[600]!;
      case 'event':
        return isDark ? Colors.purple[300]! : Colors.purple[600]!;
      case 'reminder':
        return isDark ? Colors.teal[300]! : Colors.teal[600]!;
      case 'success':
        return isDark ? Colors.green[300]! : Colors.green[600]!;
      default:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'general':
        return Icons.info;
      case 'important':
        return Icons.priority_high;
      case 'urgent':
        return Icons.warning;
      case 'event':
        return Icons.event;
      case 'reminder':
        return Icons.notifications;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  static Future<void> _markAsSeenToday(String announcementId) async {
    final storage = const LocalStorage();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'seen_announcement_${announcementId}_$today';
    await storage.write(key, 'true');
  }

  static Future<bool> hasBeenSeenToday(String announcementId) async {
    final storage = const LocalStorage();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'seen_announcement_${announcementId}_$today';
    final value = await storage.read<String>(key);
    return value == 'true';
  }

  /// Shows all login announcements in sequence
  static Future<void> showLoginAnnouncements(
    BuildContext context,
    List<RecordModel> announcements,
    String Function(RecordModel, {String? thumb}) getImageUrl,
  ) async {
    if (announcements.isEmpty) return;

    // Filter out announcements already seen today
    final unseenAnnouncements = <RecordModel>[];
    for (final announcement in announcements) {
      final seen = await hasBeenSeenToday(announcement.id);
      if (!seen) {
        unseenAnnouncements.add(announcement);
      }
    }

    if (unseenAnnouncements.isEmpty) return;

    // Show announcements one by one
    for (var i = 0; i < unseenAnnouncements.length; i++) {
      final announcement = unseenAnnouncements[i];
      final imageUrl = getImageUrl(announcement, thumb: '600x400t');

      if (!context.mounted) break;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AnnouncementPopupDialog(
          announcement: announcement,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        ),
      );
    }
  }
}
