import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class CurrentUserAccountPage extends StatefulWidget {
  const CurrentUserAccountPage({super.key});

  @override
  State<CurrentUserAccountPage> createState() => _CurrentUserAccountPageState();
}

class _CurrentUserAccountPageState extends State<CurrentUserAccountPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      // Get the current authenticated user from AuthBloc
      final authState = context.read<AuthBloc>().state;

      if (authState.user != null) {
        // User is authenticated with PocketBase, use their data directly from authStore
        final userData = authState.user!.data;
        // Get profile image URL if it exists
        String? profileImageUrl;
        if (userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty) {
          if (userData['profileImage'].toString().startsWith('http')) {
            // It's already a full URL
            profileImageUrl = userData['profileImage'].toString();
          } else {
            // It's a filename, construct the PocketBase file URL
            final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
            profileImageUrl = '$pocketbaseUrl/api/files/users/${authState.user!.id}/${userData['profileImage']}';
          }
        } else {
          profileImageUrl = 'assets/images/alex.png';
        }

        setState(() {
          _userData = userData;
          _profileImageUrl = profileImageUrl;
          _isLoading = false;
        });
      } else {
        // No authenticated user
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Image Source',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, size: 24.sp),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 14.sp),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, size: 24.sp),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 14.sp),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadProfileImage(ImageSource source) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Pick image
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      final imageFile = File(pickedFile.path);

      // Get current user ID
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      final userId = authState.user!.id;

      // Upload image to PocketBase
      final pocketBaseService = PocketBaseService();
      await pocketBaseService.updateUser(
        userId,
        {'profileImage': imageFile},
      );

      // Reload user data to get new image URL
      await _loadCurrentUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading account information...'),
            ],
          ),
        ),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            children: [
              // Profile Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: Column(
                    children: [
                      _buildProfileAvatar(),
                      SizedBox(height: 16.sp),
                      Text(
                        '${_userData!['firstName'] ?? ''} ${_userData!['lastName'] ?? ''}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.sp),
                      Text(
                        'Member #${_userData!['memberNumber'] ?? ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.sp),

              // Personal Information Section
              _buildInfoSection(
                title: 'Personal Information',
                icon: Icons.person,
                color: Colors.blue,
                children: [
                  _buildInfoRow('First Name', (_userData!['firstName'] ?? 'N/A').toString()),
                  _buildInfoRow('Last Name', (_userData!['lastName'] ?? 'N/A').toString()),
                  if (_userData!['middleName'] != null && _userData!['middleName'].toString().isNotEmpty)
                    _buildInfoRow('Middle Name', _userData!['middleName'].toString()),
                  _buildInfoRow('Gender', (_userData!['gender'] ?? 'N/A').toString()),
                  _buildInfoRow('Age', (_userData!['age']?.toString() ?? 'N/A')),
                  _buildInfoRow('Birth Date', _formatDate(_userData!['birthDate'])),
                  _buildInfoRow('Nationality', (_userData!['nationality'] ?? 'N/A').toString()),
                  _buildInfoRow('Civil Status', (_userData!['civilStatus'] ?? 'N/A').toString()),
                  if (_userData!['bloodType'] != null && _userData!['bloodType'].toString().isNotEmpty)
                    _buildInfoRow('Blood Type', _userData!['bloodType'].toString()),
                  if (_userData!['religion'] != null && _userData!['religion'].toString().isNotEmpty)
                    _buildInfoRow('Religion', _userData!['religion'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Contact Information Section
              _buildInfoSection(
                title: 'Contact Information',
                icon: Icons.contact_phone,
                color: Colors.green,
                children: [
                  _buildInfoRow('Contact Number', (_userData!['contactNumber'] ?? 'N/A').toString()),
                  _buildInfoRow('Email', (_userData!['email'] ?? 'N/A').toString()),
                  if (_userData!['emergencyContactName'] != null &&
                      _userData!['emergencyContactName'].toString().isNotEmpty)
                    _buildInfoRow('Emergency Contact Name', _userData!['emergencyContactName'].toString()),
                  if (_userData!['emergencyContactNumber'] != null &&
                      _userData!['emergencyContactNumber'].toString().isNotEmpty)
                    _buildInfoRow('Emergency Contact Number', _userData!['emergencyContactNumber'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Spouse Information Section (if available)
              if (_userData!['spouseName'] != null && _userData!['spouseName'].toString().isNotEmpty)
                _buildInfoSection(
                  title: 'Spouse Information',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  children: [
                    _buildInfoRow('Spouse Name', _userData!['spouseName'].toString()),
                    if (_userData!['spouseContactNumber'] != null &&
                        _userData!['spouseContactNumber'].toString().isNotEmpty)
                      _buildInfoRow('Spouse Contact Number', _userData!['spouseContactNumber'].toString()),
                  ],
                ),
              if (_userData!['spouseName'] != null && _userData!['spouseName'].toString().isNotEmpty)
                SizedBox(height: 16.sp),

              // Driver's License Information Section
              _buildInfoSection(
                title: "Driver's License Information",
                icon: Icons.drive_eta,
                color: Colors.orange,
                children: [
                  if (_userData!['driversLicenseNumber'] != null &&
                      _userData!['driversLicenseNumber'].toString().isNotEmpty)
                    _buildInfoRow('License Number', _userData!['driversLicenseNumber'].toString()),
                  _buildInfoRow('License Expiration', _formatDate(_userData!['driversLicenseExpirationDate'])),
                  if (_userData!['driversLicenseRestrictionCode'] != null &&
                      _userData!['driversLicenseRestrictionCode'].toString().isNotEmpty)
                    _buildInfoRow('Restriction Code', _userData!['driversLicenseRestrictionCode'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Account Information Section
              _buildInfoSection(
                title: 'Account Information',
                icon: Icons.account_circle,
                color: Colors.purple,
                children: [
                  _buildInfoRow('Member Number', (_userData!['memberNumber'] ?? 'N/A').toString()),
                  _buildInfoRow('Membership Type', _getMembershipTypeText(_userData!['membership_type'])),
                  _buildInfoRow('Account Status', (_userData!['isActive'] == true ? 'Active' : 'Inactive')),
                  if (_userData!['created'] != null) _buildInfoRow('Member Since', _formatDate(_userData!['created'])),
                  if (_userData!['updated'] != null) _buildInfoRow('Last Updated', _formatDate(_userData!['updated'])),
                ],
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        // Avatar
        _isUploadingImage
            ? CircleAvatar(
                radius: 50.sp,
                backgroundColor: Theme.of(context).primaryColor,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : _buildAvatarImage(),
        // Edit button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _showImageSourceDialog,
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    // Show asset image
    if (_profileImageUrl != null && _profileImageUrl!.startsWith('assets/')) {
      return CircleAvatar(
        radius: 50.sp,
        backgroundColor: Theme.of(context).primaryColor,
        child: ClipOval(
          child: Image.asset(
            _profileImageUrl!,
            width: 100.sp,
            height: 100.sp,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 50.sp,
                color: Colors.white,
              );
            },
          ),
        ),
      );
    }

    // Show network image with error handling
    if (_profileImageUrl != null && !_profileImageUrl!.startsWith('assets/')) {
      return CircleAvatar(
        radius: 50.sp,
        backgroundColor: Theme.of(context).primaryColor,
        child: ClipOval(
          child: Image.network(
            _profileImageUrl!,
            width: 100.sp,
            height: 100.sp,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 50.sp,
                color: Colors.white,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      );
    }

    // Default placeholder (no profile image)
    return CircleAvatar(
      radius: 50.sp,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(
        Icons.person,
        size: 50.sp,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.sp),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.sp,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    try {
      if (date is Timestamp) {
        return DateFormat('MMM dd, yyyy').format(date.toDate());
      } else if (date is DateTime) {
        return DateFormat('MMM dd, yyyy').format(date);
      } else {
        return date.toString();
      }
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMembershipTypeText(dynamic membershipType) {
    switch (membershipType) {
      case 1:
        return 'Super Admin';
      case 2:
        return 'Admin';
      case 3:
        return 'Member';
      default:
        return 'Unknown';
    }
  }
}
