import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CarWidget extends StatelessWidget {
  const CarWidget({
    required this.state,
    super.key,
  });
  final ProfileState state;

  Future<String?> _getCarImageUrl() async {
    try {
      final userId = state.user.uid;
      if (userId == null || userId.isEmpty) {
        return null;
      }

      // Try to get the main car image from Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/images/cars/main.png');

      return await storageRef.getDownloadURL();
    } catch (e) {
      // If the image doesn't exist or there's an error, return null
      // This will fall back to the default image
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: FutureBuilder<String?>(
                  future: _getCarImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      // Show the car image from Firebase Storage
                      return OpstechExtendedImageNetwork(
                        img: snapshot.data!,
                        width: 90,
                        height: 90,
                        borderrRadius: 10,
                      );
                    }

                    // Fallback to default image if no car image exists
                    return Image.asset(
                      'assets/images/vios.jpg',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    );
                  },
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
