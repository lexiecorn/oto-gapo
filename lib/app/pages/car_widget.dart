import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo_core/otogapo_core.dart';

class CarWidget extends StatelessWidget {

  const CarWidget({
    super.key,
    required this.state,
  });
  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 12,
        ),
        width: 100,
        height: 100,
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
                child: Image.asset(
                  'assets/images/vios.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.user.vehicle.first.make} '
                        '${state.user.vehicle.first.model}',
                        style: OpstechTextTheme.heading2.copyWith(
                          color: Colors.black87,
                          fontSize: 44.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Plate Number: ${state.user.vehicle.first.plateNumber}',
                        style: OpstechTextTheme.regular.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Color: ${state.user.vehicle.first.color}',
                        style: OpstechTextTheme.regular.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Year: ${state.user.vehicle.first.year}',
                        style: OpstechTextTheme.regular.copyWith(
                          color: Colors.black54,
                        ),
                      ),
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
