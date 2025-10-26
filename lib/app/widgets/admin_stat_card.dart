import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated stat card for admin dashboard
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.trendValue,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? trend; // 'up', 'down', or null
  final String? trendValue;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.blue.shade600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(12.sp),
        child: Row(
          children: [
            // Icon on the left
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Value and Title on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.forward(),
                      )
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Trend badge (if present)
            if (trend != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: _getTrendColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(),
                      color: Colors.white,
                      size: 12.sp,
                    ),
                    if (trendValue != null) ...[
                      SizedBox(width: 3.w),
                      Text(
                        trendValue!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

  Color _getTrendColor() {
    if (trend == 'up') return Colors.green;
    if (trend == 'down') return Colors.red;
    return Colors.grey;
  }

  IconData _getTrendIcon() {
    if (trend == 'up') return Icons.trending_up;
    if (trend == 'down') return Icons.trending_down;
    return Icons.trending_flat;
  }
}

/// Count-up animation for numbers
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.style,
    super.key,
  });

  final int value;
  final Duration duration;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value.toDouble(),
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toInt().toString(),
          style: widget.style,
        );
      },
    );
  }
}
