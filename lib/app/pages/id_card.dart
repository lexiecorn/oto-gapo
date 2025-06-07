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
    required this.restrictionCode, required this.emergencyContact, this.licenseNumExpr,
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
              horizontal: 70.sp,
              vertical: 20,
            ),
            child: Column(
              children: [
                ClipOval(
                  child: OpstechExtendedImageNetwork(
                    img: imagePath,
                    width: 80,
                    height: 80,
                    borderrRadius: 40,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 5),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '# $membersNum',
                    style: OpstechTextTheme.heading4.copyWith(
                      color: Colors.amber,
                      fontSize: 60.sp,
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
              children: [
                Text(
                  name.toUpperCase(),
                  // ignore: lines_longer_than_80_chars
                  style: OpstechTextTheme.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 54.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                // ignore: lines_longer_than_80_chars
                Text(
                  'License #: $licenseNum',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'DOB: $dob',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                  ),
                ),

                Text(
                  'ID Number: $idNumber',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
                  ),
                ),

                Text(
                  'Joined: December 20, 2023',
                  style: OpstechTextTheme.regular.copyWith(
                    color: Colors.white,
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
