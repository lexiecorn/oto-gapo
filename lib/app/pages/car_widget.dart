import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo_core/otogapo_core.dart';

class CarWidget extends StatelessWidget {
  const CarWidget({
    required this.state,
    super.key,
  });
  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    // Get the vehicle's primary photo or use a default image
    String vehicleImagePath = 'assets/images/vios.jpg'; // Default fallback
    if (state.user.vehicle.isNotEmpty &&
        state.user.vehicle.first.primaryPhoto != null &&
        state.user.vehicle.first.primaryPhoto!.isNotEmpty) {
      vehicleImagePath = state.user.vehicle.first.primaryPhoto!;
    }

    bool isAssetImage = vehicleImagePath.startsWith('assets/');

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isAssetImage
                    ? Image.asset(
                        vehicleImagePath,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : OpstechExtendedImageNetwork(
                        img: vehicleImagePath,
                        width: 90,
                        height: 90,
                        borderrRadius: 10,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.user.vehicle.isNotEmpty ? state.user.vehicle.first.make : 'No Vehicle'} '
                        '${state.user.vehicle.isNotEmpty ? state.user.vehicle.first.model : ''}',
                        style: OpstechTextTheme.heading2.copyWith(
                          color: Colors.black87,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (state.user.vehicle.isNotEmpty) ...[
                        Text(
                          'Plate Number: ${state.user.vehicle.first.plateNumber}',
                          style: OpstechTextTheme.regular.copyWith(
                            color: Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Color: ${state.user.vehicle.first.color}',
                          style: OpstechTextTheme.regular.copyWith(
                            color: Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Year: ${state.user.vehicle.first.year}',
                          style: OpstechTextTheme.regular.copyWith(
                            color: Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'No vehicle information available',
                          style: OpstechTextTheme.regular.copyWith(
                            color: Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
