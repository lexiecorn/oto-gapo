import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:authentication_repository/authentication_repository.dart';

@RoutePage(name: 'VehicleAwardsPageRouter')
class VehicleAwardsPage extends StatefulWidget {
  const VehicleAwardsPage({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  State<VehicleAwardsPage> createState() => _VehicleAwardsPageState();
}

class _VehicleAwardsPageState extends State<VehicleAwardsPage> {
  List<VehicleAward> _awards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAwards();
  }

  Future<void> _loadAwards() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Replace with actual awards loading when repository is integrated
      await Future<void>.delayed(const Duration(seconds: 1));

      // Mock data for now
      final mockAwards = <VehicleAward>[];

      setState(() {
        _awards = mockAwards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildAwardCard(VehicleAward award, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2a1a0e).withOpacity(0.8),
            const Color(0xFF3d2815).withOpacity(0.6)
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFFffd700).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFffd700).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Award header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: const Color(0xFFffd700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: const Color(0xFFffd700).withOpacity(0.4),
                      width: 1),
                ),
                child: Icon(Icons.emoji_events,
                    size: 24.sp, color: const Color(0xFFffd700)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      award.awardName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFffd700),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      award.eventName,
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Award details
          if (award.category != null || award.placement != null)
            Row(
              children: [
                if (award.category != null) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFffd700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: const Color(0xFFffd700).withOpacity(0.4),
                          width: 1),
                    ),
                    child: Text(
                      award.category!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFffd700),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                if (award.placement != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFa855f7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: const Color(0xFFa855f7).withOpacity(0.4),
                          width: 1),
                    ),
                    child: Text(
                      award.placement!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFa855f7),
                      ),
                    ),
                  ),
              ],
            ),
          SizedBox(height: 12.h),
          // Event date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[400]),
              SizedBox(width: 8.w),
              Text(
                _formatDate(award.eventDate),
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              ),
            ],
          ),
          if (award.description != null && award.description!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              award.description!,
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.grey[300], height: 1.4),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (100 + (index * 100)).ms, duration: 600.ms)
        .slideY(
            begin: 0.3,
            delay: (100 + (index * 100)).ms,
            duration: 600.ms,
            curve: Curves.easeOutCubic);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1e2340).withOpacity(0.6),
            const Color(0xFF2a2f4f).withOpacity(0.4)
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[600]!.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 64.sp, color: Colors.grey[500]),
          SizedBox(height: 16.h),
          Text(
            'No Awards Yet',
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start participating in car shows and events to earn your first award!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.sp, color: Colors.grey[500], height: 1.4),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add award page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add award feature coming soon!'),
                    backgroundColor: Color(0xFF00d4ff)),
              );
            },
            icon: Icon(Icons.add, size: 18.sp),
            label: Text('Add Award'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4ff),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(
        begin: const Offset(0.9, 0.9),
        duration: 800.ms,
        curve: Curves.easeOutBack);
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2a1a0e).withOpacity(0.8),
                const Color(0xFF3d2815).withOpacity(0.6)
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: const Color(0xFFffd700).withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12.r)),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          duration: 1500.ms,
                          color: const Color(0xFFffd700).withOpacity(0.3)),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .shimmer(
                                duration: 1500.ms,
                                color:
                                    const Color(0xFFffd700).withOpacity(0.3)),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .shimmer(
                                duration: 1500.ms,
                                color:
                                    const Color(0xFFffd700).withOpacity(0.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.vehicle.make} ${widget.vehicle.model} Awards',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: const Color(0xFF00d4ff), size: 24.sp),
            onPressed: () {
              // TODO: Navigate to add award page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add award feature coming soon!'),
                    backgroundColor: Color(0xFF00d4ff)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64.sp, color: Colors.red[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load awards',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[400]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _loadAwards,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00d4ff),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _awards.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_awards.length} Award${_awards.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[300]),
                          ),
                          SizedBox(height: 16.h),
                          ...List.generate(
                              _awards.length,
                              (index) =>
                                  _buildAwardCard(_awards[index], index)),
                        ],
                      ),
                    ),
    );
  }
}
