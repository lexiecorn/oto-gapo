import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable card widget for displaying vehicle specifications
/// with dark theme and glowing effects
class VehicleSpecCard extends StatelessWidget {
  const VehicleSpecCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isLoading = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey.shade900.withOpacity(0.8), Colors.grey.shade800.withOpacity(0.6)]
                : [Colors.grey.shade100.withOpacity(0.8), Colors.grey.shade200.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE61525).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3), 
              blurRadius: 8, 
              spreadRadius: 0, 
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and label row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE61525).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE61525).withOpacity(0.4), width: 1),
                  ),
                  child: Icon(icon, size: 16.sp, color: const Color(0xFFE61525)),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Value
            if (isLoading)
              Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(4.r)),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE61525).withOpacity(0.3)),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms, color: const Color(0xFFE61525).withOpacity(0.3))
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
