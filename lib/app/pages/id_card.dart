import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

class IdCard extends StatelessWidget {
  const IdCard({
    required this.imagePath,
    required this.name,
    required this.dob,
    required this.idNumber,
    required this.car,
    required this.membersNum,
    required this.licenseNum,
    required this.restrictionCode,
    required this.emergencyContact,
    this.licenseNumExpr,
    super.key,
  });
  final String imagePath;
  final String name;
  final String dob;
  final String idNumber;
  final String car;
  final String membersNum;
  final String licenseNum;
  final Timestamp? licenseNumExpr;
  final String? restrictionCode;
  final String? emergencyContact;

  bool get _isAssetImage => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.redAccent.shade700,
      // border black
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      // shadow
      elevation: 10,

      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 20.h,
            ),
            child: Column(
              children: [
                ClipOval(
                  child: _isAssetImage
                      ? OpstechExtendedImageAsset(
                          img: imagePath,
                          width: 80.w,
                          height: 80.w,
                          borderrRadius: 40.r,
                        )
                      : OpstechExtendedImageNetwork(
                          img: imagePath,
                          width: 80.w,
                          height: 80.w,
                          borderrRadius: 40.r,
                        ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '# $membersNum',
                    style: OpstechTextTheme.heading4.copyWith(
                      color: Colors.amber,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.toUpperCase(),
                  style: OpstechTextTheme.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'License #: $licenseNum',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  'DOB: $dob',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  'ID Number: $idNumber',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  'Joined: December 20, 2023',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
