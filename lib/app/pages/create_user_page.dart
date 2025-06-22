import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:otogapo/app/pages/create_user_section.dart';

class CreateUserPage extends StatelessWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create New User',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green[600]!,
                  Colors.green[800]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Create New User Account',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Add a new member to the system with complete details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(begin: -0.3, duration: const Duration(milliseconds: 600)),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: CreateUserSection()
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600))
                  .slideY(
                      begin: -0.2,
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.green),
            SizedBox(width: 8.sp),
            Text('Create User Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.person,
              title: 'Personal Information',
              description: 'Fill in the user\'s basic personal details like name, email, and contact information.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.directions_car,
              title: 'Vehicle Information',
              description: 'Add vehicle details including make, model, color, and license plate number.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.photo_camera,
              title: 'Profile & Vehicle Photos',
              description: 'Upload profile picture and vehicle photos for identification purposes.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.security,
              title: 'Account Settings',
              description: 'Set user permissions, membership type, and account status.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.green),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
