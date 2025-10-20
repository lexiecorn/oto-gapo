import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';

/// Navigation cards for Otogapo page
class OtogapoNavigationCards extends StatelessWidget {
  const OtogapoNavigationCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactCard(
              context: context,
              icon: Icons.people,
              title: 'Members',
              color: Colors.blue,
              onTap: () {
                context.router.push(const UserListPageRouter());
              },
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildCompactCard(
              context: context,
              icon: Icons.campaign,
              title: 'Announcements',
              color: Colors.orange,
              onTap: () {
                context.router.push(const AnnouncementsListPageRouter());
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  delay: 100.ms,
                  curve: Curves.easeOut,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: color,
                ),
              ),

              SizedBox(height: 8.h),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? colorScheme.onSurface : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
