import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable card widget for displaying analytics statistics
class AnalyticsStatCard extends StatelessWidget {
  const AnalyticsStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.trendColor,
    this.color,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trend;
  final Color? trendColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Container(
      padding: EdgeInsets.all(12.w), // Reduced padding
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: cardColor,
                size: 24.sp,
              ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: (trendColor ?? Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      color: trendColor ?? Colors.green,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp, // Slightly smaller
              color: theme.textTheme.bodySmall?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Flexible(
            // Wrap value in Flexible to prevent overflow
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20.sp, // Reduced font size
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h), // Reduced spacing
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10.sp, // Slightly smaller
                color: theme.textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
