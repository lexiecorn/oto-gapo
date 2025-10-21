import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/utils/car_logo_helper.dart';
import 'package:otogapo/widgets/vehicle_spec_card.dart';
import 'package:otogapo/widgets/awards_trophy_row.dart';
import 'package:otogapo_core/otogapo_core.dart';

class CarWidget extends StatefulWidget {
  const CarWidget({required this.state, super.key});
  final ProfileState state;

  @override
  State<CarWidget> createState() => _CarWidgetState();
}

class _CarWidgetState extends State<CarWidget> with TickerProviderStateMixin {
  late AnimationController _carAnimationController;
  late AnimationController _imageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _carAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _imageAnimationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
      ),
    );

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _carAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _carAnimationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildUserDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12.sp, color: Colors.grey[400]),
        SizedBox(width: 6.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[400], fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Builds the car manufacturer logo widget with fallback handling
  Widget _buildCarLogo(String make) {
    final logoUrl = CarLogoHelper.getCarLogoSource(make);

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: const Color(0xFFE61525).withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(8.sp),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.directions_car, size: 24.sp, color: const Color(0xFFE61525));
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE61525)),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String?> _resolvePrimaryPhotoUrl() async {
    try {
      if (widget.state.vehicles.isEmpty) return null;
      final vehicle = widget.state.vehicles.first;
      final primary = vehicle.primaryPhoto;
      if (primary == null || primary.isEmpty) return null;

      if (primary.startsWith('http')) {
        return primary;
      }

      final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      return '$pocketbaseUrl/api/files/vehicles/${vehicle.id}/$primary';
    } catch (_) {
      return null;
    }
  }

  Widget _buildHeroSection() {
    final vehicle = widget.state.vehicles.isNotEmpty ? widget.state.vehicles.first : null;
    final mainImageFuture = _resolvePrimaryPhotoUrl();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 280.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Colors.black, Colors.grey.shade900, Colors.grey.shade800]
              : [Colors.grey.shade100, Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Hero car image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: FutureBuilder<String?>(
                future: mainImageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [Colors.grey.shade900, Colors.grey.shade800]
                                  : [Colors.grey.shade200, Colors.grey.shade300],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE61525)),
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1500.ms, color: const Color(0xFFE61525).withOpacity(0.3));
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    return Stack(
                      children: [
                        OpstechExtendedImageNetwork(
                          img: snapshot.data!,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // Dark gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.3)],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Fallback placeholder
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [Colors.grey.shade900, Colors.grey.shade800]
                            : [Colors.grey.shade200, Colors.grey.shade300],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.directions_car, size: 80.sp, color: const Color(0xFFE61525).withOpacity(0.5)),
                    ),
                  );
                },
              ),
            ),
          ),
          // Car name and details at top left
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle != null ? '${vehicle.make} ${vehicle.model}'.toUpperCase() : 'NO VEHICLE',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                ),
                if (vehicle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${vehicle.year} • ${vehicle.color}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[300],
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2, offset: const Offset(0, 1)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // User details at bottom left
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and member number row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.state.user.firstName} ${widget.state.user.lastName}',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE61525).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE61525), width: 1),
                        ),
                        child: Text(
                          '# ${widget.state.user.memberNumber}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE61525),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Additional user details
                  _buildUserDetailRow(Icons.calendar_today, 'DOB', _formatDate(widget.state.user.birthDate)),
                  SizedBox(height: 4.h),
                  _buildUserDetailRow(Icons.badge, 'License', widget.state.user.driversLicenseNumber ?? 'N/A'),
                ],
              ),
            ),
          ),
          // Car logo in top right
          if (vehicle != null) Positioned(top: 16.h, right: 16.w, child: _buildCarLogo(vehicle.make)),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final vehicle = widget.state.vehicles.isNotEmpty ? widget.state.vehicles.first : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (vehicle == null) {
      return Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey.shade900.withOpacity(0.8), Colors.grey.shade800.withOpacity(0.6)]
                : [Colors.grey.shade100.withOpacity(0.8), Colors.grey.shade200.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE61525).withOpacity(0.3), width: 1),
        ),
        child: Center(
          child: Text(
            'No vehicle specifications available',
            style: TextStyle(fontSize: 16.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      );
    }

    final specs = [
      {
        'icon': Icons.speed,
        'label': 'Max Speed',
        'value': vehicle.maxSpeed != null ? '${vehicle.maxSpeed} km/h' : 'N/A',
      },
      {'icon': Icons.local_gas_station, 'label': 'Fuel Type', 'value': vehicle.fuelType ?? 'N/A'},
      {'icon': Icons.timeline, 'label': 'Mileage', 'value': vehicle.mileage != null ? '${vehicle.mileage} km' : 'N/A'},
      {'icon': Icons.settings, 'label': 'Wheels', 'value': vehicle.wheelSize ?? 'N/A'},
      {'icon': Icons.settings_outlined, 'label': 'Transmission', 'value': vehicle.transmission ?? 'N/A'},
      {'icon': Icons.power, 'label': 'Power', 'value': vehicle.horsepower != null ? '${vehicle.horsepower} HP' : 'N/A'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.4,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return VehicleSpecCard(
              icon: spec['icon'] as IconData,
              label: spec['label'] as String,
              value: spec['value'] as String,
            )
            .animate()
            .fadeIn(delay: (400 + (index * 100)).ms, duration: 600.ms)
            .slideY(begin: 0.2, delay: (400 + (index * 100)).ms, duration: 600.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildAwardsSection() {
    // TODO: Load awards from ProfileState when awards are integrated
    final awardCount = 0; // Placeholder for now

    return AwardsTrophyRow(
      awardCount: awardCount,
      onTap: () {
        // TODO: Navigate to awards page when implemented
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Awards page coming soon!'), backgroundColor: Color(0xFFE61525)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark ? [Colors.black, Colors.grey.shade900] : [Colors.white, Colors.grey.shade100],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section with car image
                  _buildHeroSection(),
                  SizedBox(height: 20.h),
                  // Specs grid
                  Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                  SizedBox(height: 12.h),
                  _buildSpecsGrid(),
                  SizedBox(height: 20.h),
                  // Awards section
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                  SizedBox(height: 12.h),
                  _buildAwardsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
