import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A widget that displays vehicle awards as trophy icons in a horizontal row
/// with a count badge and tap-to-navigate functionality
class AwardsTrophyRow extends StatelessWidget {
  const AwardsTrophyRow(
      {required this.awardCount,
      this.onTap,
      this.isLoading = false,
      super.key,});

  final int awardCount;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (awardCount == 0) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey.shade900.withOpacity(0.8),
                    Colors.grey.shade800.withOpacity(0.6),
                  ]
                : [
                    Colors.grey.shade100.withOpacity(0.8),
                    Colors.grey.shade200.withOpacity(0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trophy icon with enhanced animations
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
                border:
                    Border.all(color: Colors.grey.withOpacity(0.4)),
              ),
              child: _AnimatedTrophy(
                size: 24.sp,
              ).animate().scale(
                  delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut,),
            ),
            SizedBox(width: 12.w),
            // Awards count and text with staggered animations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$awardCount Award${awardCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(
                      begin: 0.2,
                      delay: 300.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,),
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(
                      begin: 0.1,
                      delay: 500.ms,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,),
                ],
              ),
            ),
            // Arrow icon with bounce animation
            Icon(Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideX(
                    begin: 0.3,
                    delay: 400.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey.shade900.withOpacity(0.8),
                  Colors.grey.shade800.withOpacity(0.6),
                ]
              : [
                  Colors.grey.shade100.withOpacity(0.8),
                  Colors.grey.shade200.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.2),),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8.r),),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 1500.ms,
              color: const Color(0xFF4CAF50).withOpacity(0.3),),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4.r),),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: 1500.ms,
                    color: const Color(0xFF4CAF50).withOpacity(0.3),),
                SizedBox(height: 4.h),
                Container(
                  height: 12.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4.r),),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: 1500.ms,
                    color: const Color(0xFF4CAF50).withOpacity(0.3),),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey.shade900.withOpacity(0.6),
                  Colors.grey.shade800.withOpacity(0.4),
                ]
              : [
                  Colors.grey.shade100.withOpacity(0.6),
                  Colors.grey.shade200.withOpacity(0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[600]!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _AnimatedTrophy(
            size: 24.sp,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No awards yet',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideX(
                begin: 0.2,
                delay: 400.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

/// Custom animated trophy widget with golden color and smooth animations
class _AnimatedTrophy extends StatefulWidget {
  const _AnimatedTrophy({required this.size});

  final double size;

  @override
  State<_AnimatedTrophy> createState() => _AnimatedTrophyState();
}

class _AnimatedTrophyState extends State<_AnimatedTrophy>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),);

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Icon(
              Icons.emoji_events,
              size: widget.size,
              color: const Color(0xFFD4AF37),
            ),
          ),
        );
      },
    );
  }
}
