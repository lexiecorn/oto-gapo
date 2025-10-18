import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage(name: 'UserQRCodePageRouter')
class UserQRCodePage extends StatelessWidget {
  const UserQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.profileStatus == ProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.profileStatus == ProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          if (user.uid.isEmpty) {
            return const Center(
              child: Text('User information not available'),
            );
          }

          // Create QR data with user information
          final qrData = 'USER:${user.uid}:${user.memberNumber}';

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instructions
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Show this QR code to the admin',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'The admin will scan this code to mark your attendance',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // QR Code
                Container(
                  padding: EdgeInsets.all(24.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 280.sp,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        user.memberNumber,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // User Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _InfoRow(
                          label: 'Name',
                          value: '${user.firstName} ${user.lastName}',
                        ),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          label: 'Member Number',
                          value: user.memberNumber,
                        ),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          label: 'Member Type',
                          value: _getMembershipTypeName(user.membership_type?.toInt() ?? 3),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Note
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Keep your screen brightness up for easier scanning',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMembershipTypeName(int membershipType) {
    switch (membershipType) {
      case 1:
        return 'Admin';
      case 2:
        return 'Admin';
      case 3:
        return 'Regular Member';
      case 4:
        return 'Associate Member';
      default:
        return 'Member';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
