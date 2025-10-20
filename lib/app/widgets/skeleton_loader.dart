import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader widget with shimmer effect for loading states
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
      ),
    );
  }
}

/// Skeleton for a list item
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 50.w,
            height: 50.h,
            borderRadius: 25.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16.h,
                ),
                SizedBox(height: 8.h),
                SkeletonLoader(
                  width: 200.w,
                  height: 14.h,
                ),
                SizedBox(height: 8.h),
                SkeletonLoader(
                  width: 150.w,
                  height: 12.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a post card
class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SkeletonLoader(
                  width: 40.w,
                  height: 40.h,
                  borderRadius: 20.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 120.w,
                        height: 14.h,
                      ),
                      SizedBox(height: 4.h),
                      SkeletonLoader(
                        width: 80.w,
                        height: 12.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Content
            SkeletonLoader(
              width: double.infinity,
              height: 14.h,
            ),
            SizedBox(height: 8.h),
            SkeletonLoader(
              width: double.infinity,
              height: 14.h,
            ),
            SizedBox(height: 8.h),
            SkeletonLoader(
              width: 200.w,
              height: 14.h,
            ),
            SizedBox(height: 12.h),
            // Image placeholder
            SkeletonLoader(
              width: double.infinity,
              height: 200.h,
            ),
            SizedBox(height: 12.h),
            // Actions
            Row(
              children: [
                SkeletonLoader(
                  width: 60.w,
                  height: 32.h,
                ),
                SizedBox(width: 12.w),
                SkeletonLoader(
                  width: 60.w,
                  height: 32.h,
                ),
                SizedBox(width: 12.w),
                SkeletonLoader(
                  width: 60.w,
                  height: 32.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for profile card
class SkeletonProfileCard extends StatelessWidget {
  const SkeletonProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.sp),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          children: [
            SkeletonLoader(
              width: 100.w,
              height: 100.h,
              borderRadius: 50.r,
            ),
            SizedBox(height: 16.h),
            SkeletonLoader(
              width: 150.w,
              height: 20.h,
            ),
            SizedBox(height: 8.h),
            SkeletonLoader(
              width: 100.w,
              height: 14.h,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    SkeletonLoader(
                      width: 50.w,
                      height: 20.h,
                    ),
                    SizedBox(height: 4.h),
                    SkeletonLoader(
                      width: 60.w,
                      height: 14.h,
                    ),
                  ],
                ),
                Column(
                  children: [
                    SkeletonLoader(
                      width: 50.w,
                      height: 20.h,
                    ),
                    SizedBox(height: 4.h),
                    SkeletonLoader(
                      width: 60.w,
                      height: 14.h,
                    ),
                  ],
                ),
                Column(
                  children: [
                    SkeletonLoader(
                      width: 50.w,
                      height: 20.h,
                    ),
                    SizedBox(height: 4.h),
                    SkeletonLoader(
                      width: 60.w,
                      height: 14.h,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for grid items
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    this.itemCount = 6,
    super.key,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonLoader(
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}
