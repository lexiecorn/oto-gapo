import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class CurrentUserAccountPage extends StatefulWidget {
  const CurrentUserAccountPage({Key? key}) : super(key: key);

  @override
  State<CurrentUserAccountPage> createState() => _CurrentUserAccountPageState();
}

class _CurrentUserAccountPageState extends State<CurrentUserAccountPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;

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
        // User is authenticated with PocketBase, get their data
        final pocketBaseService = PocketBaseService();
        final userRecord = await pocketBaseService.getUser(authState.user!.id);
        final userData = userRecord.data;

        // Get profile image URL if it exists
        String? profileImageUrl;
        if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
          if (userData['profile_image'].toString().startsWith('gs://')) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(userData['profile_image'].toString());
              profileImageUrl = await ref.getDownloadURL();
            } catch (e) {
              profileImageUrl = 'assets/images/alex.png';
            }
          } else if (userData['profile_image'].toString().startsWith('http')) {
            // It's already a full URL
            profileImageUrl = userData['profile_image'].toString();
          } else {
            // It's a filename, construct the PocketBase file URL
            final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
            profileImageUrl = '$pocketbaseUrl/api/files/users/${authState.user!.id}/${userData['profile_image']}';
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
        // No authenticated user, check if there's a Firebase user as fallback
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Try to find user by Firebase UID in PocketBase
          final pocketBaseService = PocketBaseService();
          final userRecord = await pocketBaseService.getUserByFirebaseUid(currentUser.uid);

          if (userRecord != null) {
            final userData = userRecord.data;

            // Get profile image URL if it exists
            String? profileImageUrl;
            if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
              if (userData['profile_image'].toString().startsWith('gs://')) {
                try {
                  final ref = FirebaseStorage.instance.refFromURL(userData['profile_image'].toString());
                  profileImageUrl = await ref.getDownloadURL();
                } catch (e) {
                  profileImageUrl = 'assets/images/alex.png';
                }
              } else if (userData['profile_image'].toString().startsWith('http')) {
                // It's already a full URL
                profileImageUrl = userData['profile_image'].toString();
              } else {
                // It's a filename, construct the PocketBase file URL
                final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
                profileImageUrl = '$pocketbaseUrl/api/files/users/${userRecord.id}/${userData['profile_image']}';
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
            // User doesn't exist in PocketBase, create a basic one
            final basicUserData = {
              'firebaseUid': currentUser.uid,
              'firstName': 'User',
              'lastName': '',
              'email': currentUser.email ?? '',
              'gender': '',
              'memberNumber': '',
              'civilStatus': '',
              'dateOfBirth': DateTime.now().toIso8601String(),
              'birthplace': '',
              'nationality': '',
              'vehicle': <String>[],
              'contactNumber': '',
              'driversLicenseExpirationDate': DateTime.now().toIso8601String(),
              'membership_type': 3,
              'isActive': true,
              'isAdmin': false,
            };

            final createdRecord = await pocketBaseService.createUserWithFirebaseUid(
              firebaseUid: currentUser.uid,
              email: currentUser.email ?? '',
              firstName: currentUser.displayName?.split(' ').first ?? 'User',
              lastName: currentUser.displayName?.split(' ').last ?? '',
              additionalData: basicUserData,
            );
            print('Basic user created in PocketBase');

            final userData = createdRecord.data;

            // Get profile image URL if it exists
            String? profileImageUrl;
            if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
              if (userData['profile_image'].toString().startsWith('gs://')) {
                try {
                  final ref = FirebaseStorage.instance.refFromURL(userData['profile_image'].toString());
                  profileImageUrl = await ref.getDownloadURL();
                } catch (e) {
                  profileImageUrl = 'assets/images/alex.png';
                }
              } else if (userData['profile_image'].toString().startsWith('http')) {
                // It's already a full URL
                profileImageUrl = userData['profile_image'].toString();
              } else {
                // It's a filename, construct the PocketBase file URL
                final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
                profileImageUrl = '$pocketbaseUrl/api/files/users/${createdRecord.id}/${userData['profile_image']}';
              }
            } else {
              profileImageUrl = 'assets/images/alex.png';
            }

            setState(() {
              _userData = userData;
              _profileImageUrl = profileImageUrl;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account Information'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Unable to load account information'),
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
              Colors.white,
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
                      CircleAvatar(
                        radius: 50.sp,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: _profileImageUrl != null && !_profileImageUrl!.startsWith('assets/')
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl != null && _profileImageUrl!.startsWith('assets/')
                            ? Image.asset(
                                _profileImageUrl!,
                                width: 100.sp,
                                height: 100.sp,
                                fit: BoxFit.cover,
                              )
                            : _profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: Colors.white,
                                  )
                                : null,
                      ),
                      SizedBox(height: 16.sp),
                      Text(
                        '${_userData!['firstName'] ?? ''} ${_userData!['lastName'] ?? ''}',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.sp),
                      Text(
                        'Member #${_userData!['memberNumber'] ?? ''}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.grey[600],
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
                  _buildInfoRow('Date of Birth', _formatDate(_userData!['dateOfBirth'])),
                  _buildInfoRow('Birthplace', (_userData!['birthplace'] ?? 'N/A').toString()),
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
                title: 'Driver\'s License Information',
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
                  if (_userData!['createdAt'] != null)
                    _buildInfoRow('Member Since', _formatDate(_userData!['createdAt'])),
                  if (_userData!['updatedAt'] != null)
                    _buildInfoRow('Last Updated', _formatDate(_userData!['updatedAt'])),
                ],
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
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
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.sp),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.sp,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.black87,
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
