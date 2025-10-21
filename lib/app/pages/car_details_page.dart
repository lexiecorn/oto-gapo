import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/utils/car_logo_helper.dart';
import 'package:otogapo/widgets/vehicle_spec_card.dart';
import 'package:otogapo/widgets/awards_trophy_row.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:authentication_repository/authentication_repository.dart';

@RoutePage(name: 'CarDetailsPageRouter')
class CarDetailsPage extends StatefulWidget {
  const CarDetailsPage({required this.vehicle, super.key});

  final Vehicle vehicle;

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<List<String>> _getCarImageUrls() async {
    try {
      final photos = widget.vehicle.photos ?? <String>[];
      if (photos.isEmpty) return [];

      final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      final vehicleId = widget.vehicle.id;

      return photos.where((p) => p.isNotEmpty).map((filename) {
        if (filename.startsWith('http')) {
          return filename;
        }
        return '$pocketbaseUrl/api/files/vehicles/$vehicleId/$filename';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Widget _buildImageCarousel() {
    return FutureBuilder<List<String>>(
      future: _getCarImageUrls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
                height: 300.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1a1e3f), const Color(0xFF2a2f4f)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00d4ff))),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms, color: const Color(0xFF00d4ff).withOpacity(0.3));
        }

        final imageUrls = snapshot.data ?? [];

        if (imageUrls.isEmpty) {
          return Container(
            height: 300.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1a1e3f), const Color(0xFF2a2f4f)],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64.sp, color: const Color(0xFF00d4ff).withOpacity(0.5)),
                  SizedBox(height: 16.h),
                  Text(
                    'No vehicle photos',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00d4ff).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: OpstechExtendedImageNetwork(
                      img: imageUrls[index],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
              // Image indicators
              if (imageUrls.length > 1)
                Positioned(
                  bottom: 16.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageUrls.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index ? const Color(0xFF00d4ff) : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarInfo() {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1e2340).withOpacity(0.8), const Color(0xFF2a2f4f).withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF00d4ff).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Car logo
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: const Color(0xFF00d4ff).withOpacity(0.3), width: 1),
                ),
                padding: EdgeInsets.all(12.sp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: Image.network(
                    CarLogoHelper.getCarLogoSource(widget.vehicle.make),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.directions_car, size: 28.sp, color: const Color(0xFF00d4ff));
                    },
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.vehicle.make} ${widget.vehicle.model}',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${widget.vehicle.year} • ${widget.vehicle.color}',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey[300]),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Plate: ${widget.vehicle.plateNumber}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSpecs() {
    final specs = [
      {
        'icon': Icons.speed,
        'label': 'Max Speed',
        'value': widget.vehicle.maxSpeed != null ? '${widget.vehicle.maxSpeed} km/h' : 'Not specified',
      },
      {'icon': Icons.local_gas_station, 'label': 'Fuel Type', 'value': widget.vehicle.fuelType ?? 'Not specified'},
      {
        'icon': Icons.speed,
        'label': 'Mileage',
        'value': widget.vehicle.mileage != null ? '${widget.vehicle.mileage} km' : 'Not specified',
      },
      {'icon': Icons.settings, 'label': 'Wheel Size', 'value': widget.vehicle.wheelSize ?? 'Not specified'},
      {
        'icon': Icons.settings_outlined,
        'label': 'Transmission',
        'value': widget.vehicle.transmission ?? 'Not specified',
      },
      {
        'icon': Icons.power,
        'label': 'Horsepower',
        'value': widget.vehicle.horsepower != null ? '${widget.vehicle.horsepower} HP' : 'Not specified',
      },
      {'icon': Icons.engineering, 'label': 'Engine', 'value': widget.vehicle.engineDisplacement ?? 'Not specified'},
      {'icon': Icons.category, 'label': 'Type', 'value': widget.vehicle.type},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Specifications',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.3,
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
                .fadeIn(delay: (200 + (index * 100)).ms, duration: 600.ms)
                .slideY(begin: 0.2, delay: (200 + (index * 100)).ms, duration: 600.ms, curve: Curves.easeOutCubic);
          },
        ),
      ],
    );
  }

  Widget _buildAwardsSection() {
    // TODO: Load actual awards when awards system is integrated
    final awardCount = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Awards & Achievements',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        SizedBox(height: 16.h),
        AwardsTrophyRow(
          awardCount: awardCount,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Awards page coming soon!'), backgroundColor: Color(0xFF00d4ff)),
            );
          },
        ),
      ],
    );
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
          'Vehicle Details',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            _buildImageCarousel(),
            SizedBox(height: 20.h),
            // Car info
            _buildCarInfo(),
            SizedBox(height: 24.h),
            // Detailed specs
            _buildDetailedSpecs(),
            SizedBox(height: 24.h),
            // Awards section
            _buildAwardsSection(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
