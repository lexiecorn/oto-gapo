import 'dart:io';

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
  Map<String, dynamic>? _vehicleData;
  String? _profileImageUrl;
  String? _vehiclePhotoUrl;
  List<String> _vehiclePhotosUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isUploadingVehiclePhoto = false;
  bool _isUploadingAdditionalPhotos = false;

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
        if (userData['profileImage'] != null &&
            userData['profileImage'].toString().isNotEmpty) {
          if (userData['profileImage'].toString().startsWith('http')) {
            // It's already a full URL
            profileImageUrl = userData['profileImage'].toString();
          } else {
            // It's a filename, construct the PocketBase file URL
            final pocketbaseUrl =
                FlavorConfig.instance.variables['pocketbaseUrl'] as String;
            profileImageUrl =
                '$pocketbaseUrl/api/files/users/${authState.user!.id}/${userData['profileImage']}';
          }
        } else {
          profileImageUrl = 'assets/images/alex.png';
        }

        // Load vehicle data
        final pocketBaseService = PocketBaseService();
        final vehicles =
            await pocketBaseService.getVehiclesByUser(authState.user!.id);

        Map<String, dynamic>? vehicleData;
        String? vehiclePhotoUrl;
        List<String> vehiclePhotosUrls = [];

        if (vehicles.isNotEmpty) {
          vehicleData = vehicles.first.data;
          final pocketbaseUrl =
              FlavorConfig.instance.variables['pocketbaseUrl'] as String;

          // Get primary photo URL if it exists
          if (vehicleData['primaryPhoto'] != null &&
              vehicleData['primaryPhoto'].toString().isNotEmpty) {
            vehiclePhotoUrl =
                '$pocketbaseUrl/api/files/${vehicles.first.collectionId}/${vehicles.first.id}/${vehicleData['primaryPhoto']}';
          }

          // Get additional photos URLs if they exist
          if (vehicleData['photos'] != null) {
            final photos = vehicleData['photos'];
            if (photos is List && photos.isNotEmpty) {
              vehiclePhotosUrls = photos
                  .map((photo) =>
                      '$pocketbaseUrl/api/files/${vehicles.first.collectionId}/${vehicles.first.id}/$photo')
                  .toList()
                  .cast<String>();
            }
          }
        }

        setState(() {
          _userData = userData;
          _profileImageUrl = profileImageUrl;
          _vehicleData = vehicleData;
          _vehiclePhotoUrl = vehiclePhotoUrl;
          _vehiclePhotosUrls = vehiclePhotosUrls;
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, size: 20.sp),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 13.sp),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, size: 20.sp),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 13.sp),
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
      final updatedRecord = await pocketBaseService.updateUser(
        userId,
        {'profileImage': imageFile},
      );

      // Refresh the auth store with updated user data
      // This will trigger the AuthBloc stream to update
      final pocketBaseAuthRepo = context.read<AuthBloc>().pocketBaseAuth;
      final pb = pocketBaseAuthRepo.pocketBase;

      // Manually update the auth store with the new user data
      pb.authStore.save(pb.authStore.token, updatedRecord);

      // Wait a moment for the stream to propagate the update
      await Future<void>.delayed(const Duration(milliseconds: 300));

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

  Future<void> _showVehiclePhotoSourceDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Image Source',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.sp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, size: 20.sp),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 13.sp),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadVehiclePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, size: 20.sp),
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 13.sp),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadVehiclePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadVehiclePhoto(ImageSource source) async {
    try {
      setState(() {
        _isUploadingVehiclePhoto = true;
      });

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isUploadingVehiclePhoto = false;
        });
        return;
      }

      final imageFile = File(pickedFile.path);

      // Get current user's vehicle
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      final pocketBaseService = PocketBaseService();
      final vehicles =
          await pocketBaseService.getVehiclesByUser(authState.user!.id);

      if (vehicles.isEmpty) {
        throw Exception('No vehicle found for this user');
      }

      final vehicleId = vehicles.first.id;

      // Upload image to PocketBase
      final updatedVehicle = await pocketBaseService.updateVehicle(vehicleId, {
        'primaryPhoto': imageFile,
      });

      // Update local vehicle data
      final pocketbaseUrl =
          FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      final vehiclePhotoUrl = updatedVehicle.data['primaryPhoto'] != null
          ? '$pocketbaseUrl/api/files/${updatedVehicle.collectionId}/${updatedVehicle.id}/${updatedVehicle.data['primaryPhoto']}'
          : null;

      setState(() {
        _vehicleData = updatedVehicle.data;
        _vehiclePhotoUrl = vehiclePhotoUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primary photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading vehicle photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating primary photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingVehiclePhoto = false;
        });
      }
    }
  }

  Future<void> _showEditPersonalInfoDialog() async {
    final middleNameController = TextEditingController(
      text: _userData!['middleName']?.toString() ?? '',
    );
    final genderController = TextEditingController(
      text: _userData!['gender']?.toString() ?? '',
    );
    final ageController = TextEditingController(
      text: _userData!['age']?.toString() ?? '',
    );
    final birthDateController = TextEditingController(
      text: _userData!['birthDate']?.toString() ?? '',
    );
    DateTime? selectedBirthDate;
    if (_userData!['birthDate'] != null) {
      try {
        selectedBirthDate = _userData!['birthDate'] is DateTime
            ? _userData!['birthDate'] as DateTime
            : DateTime.tryParse(_userData!['birthDate'].toString());
        if (selectedBirthDate != null) {
          birthDateController.text =
              DateFormat('MMM dd, yyyy').format(selectedBirthDate);
        }
      } catch (e) {
        print('Error parsing birth date: $e');
      }
    }
    final nationalityController = TextEditingController(
      text: _userData!['nationality']?.toString() ?? '',
    );
    final civilStatusController = TextEditingController(
      text: _userData!['civilStatus']?.toString() ?? '',
    );
    final bloodTypeController = TextEditingController(
      text: _userData!['bloodType']?.toString() ?? '',
    );
    final religionController = TextEditingController(
      text: _userData!['religion']?.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Personal Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(24.sp, 20.sp, 24.sp, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note: First name and last name cannot be changed',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Middle Name (Optional)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: middleNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter middle name',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: genderController,
                      decoration: InputDecoration(
                        hintText: 'Enter gender',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Age',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        hintText: 'Enter age',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Birth Date',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: birthDateController,
                      decoration: InputDecoration(
                        hintText: 'Select birth date',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                        suffixIcon: Icon(Icons.calendar_today, size: 18.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedBirthDate = pickedDate;
                            birthDateController.text =
                                DateFormat('MMM dd, yyyy').format(pickedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Nationality',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: nationalityController,
                      decoration: InputDecoration(
                        hintText: 'Enter nationality',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Civil Status',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: civilStatusController,
                      decoration: InputDecoration(
                        hintText: 'Enter civil status',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Blood Type (Optional)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: bloodTypeController,
                      decoration: InputDecoration(
                        hintText: 'Enter blood type',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Religion (Optional)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: religionController,
                      decoration: InputDecoration(
                        hintText: 'Enter religion',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save', style: TextStyle(fontSize: 13.sp)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updating personal information...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Get current user ID
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) {
          throw Exception('User not authenticated');
        }

        final userId = authState.user!.id;

        // Prepare update data
        final updateData = <String, dynamic>{
          'middleName': middleNameController.text.trim(),
          'gender': genderController.text.trim(),
          'nationality': nationalityController.text.trim(),
          'civilStatus': civilStatusController.text.trim(),
          'bloodType': bloodTypeController.text.trim(),
          'religion': religionController.text.trim(),
        };

        // Parse age
        final ageText = ageController.text.trim();
        if (ageText.isNotEmpty) {
          final age = int.tryParse(ageText);
          if (age != null) {
            updateData['age'] = age;
          }
        }

        // Add birth date if selected
        if (selectedBirthDate != null) {
          updateData['birthDate'] = selectedBirthDate!.toIso8601String();
        }

        // Update personal information in PocketBase
        final pocketBaseService = PocketBaseService();
        final updatedRecord =
            await pocketBaseService.updateUser(userId, updateData);

        // Refresh the auth store with updated user data
        final pocketBaseAuthRepo = context.read<AuthBloc>().pocketBaseAuth;
        final pb = pocketBaseAuthRepo.pocketBase;
        pb.authStore.save(pb.authStore.token, updatedRecord);

        // Wait for the stream to propagate the update
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Reload user data
        await _loadCurrentUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal information updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error updating personal information: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating personal information: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Dispose controllers
    middleNameController.dispose();
    genderController.dispose();
    ageController.dispose();
    birthDateController.dispose();
    nationalityController.dispose();
    civilStatusController.dispose();
    bloodTypeController.dispose();
    religionController.dispose();
  }

  Future<void> _showEditContactDialog() async {
    final contactNumberController = TextEditingController(
      text: _userData!['contactNumber']?.toString() ?? '',
    );
    final emergencyNameController = TextEditingController(
      text: _userData!['emergencyContactName']?.toString() ?? '',
    );
    final emergencyNumberController = TextEditingController(
      text: _userData!['emergencyContactNumber']?.toString() ?? '',
    );
    final spouseNameController = TextEditingController(
      text: _userData!['spouseName']?.toString() ?? '',
    );
    final spouseNumberController = TextEditingController(
      text: _userData!['spouseContactNumber']?.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Contact Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(24.sp, 20.sp, 24.sp, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Number',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.sp),
                TextField(
                  controller: contactNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter contact number',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 10.sp),
                  ),
                  style: TextStyle(fontSize: 13.sp),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Emergency Contact Name',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.sp),
                TextField(
                  controller: emergencyNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter emergency contact name',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 10.sp),
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Emergency Contact Number',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.sp),
                TextField(
                  controller: emergencyNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter emergency contact number',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 10.sp),
                  ),
                  style: TextStyle(fontSize: 13.sp),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Spouse Name (Optional)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.sp),
                TextField(
                  controller: spouseNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter spouse name',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 10.sp),
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Spouse Contact Number (Optional)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.sp),
                TextField(
                  controller: spouseNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter spouse contact number',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.sp, vertical: 10.sp),
                  ),
                  style: TextStyle(fontSize: 13.sp),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Save', style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updating contact information...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Get current user ID
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) {
          throw Exception('User not authenticated');
        }

        final userId = authState.user!.id;

        // Update contact information in PocketBase
        final pocketBaseService = PocketBaseService();
        final updatedRecord = await pocketBaseService.updateUser(userId, {
          'contactNumber': contactNumberController.text.trim(),
          'emergencyContactName': emergencyNameController.text.trim(),
          'emergencyContactNumber': emergencyNumberController.text.trim(),
          'spouseName': spouseNameController.text.trim(),
          'spouseContactNumber': spouseNumberController.text.trim(),
        });

        // Refresh the auth store with updated user data
        final pocketBaseAuthRepo = context.read<AuthBloc>().pocketBaseAuth;
        final pb = pocketBaseAuthRepo.pocketBase;
        pb.authStore.save(pb.authStore.token, updatedRecord);

        // Wait for the stream to propagate the update
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Reload user data
        await _loadCurrentUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact information updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error updating contact information: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating contact information: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Dispose controllers
    contactNumberController.dispose();
    emergencyNameController.dispose();
    emergencyNumberController.dispose();
    spouseNameController.dispose();
    spouseNumberController.dispose();
  }

  Future<void> _showEditDriversLicenseDialog() async {
    final licenseNumberController = TextEditingController(
      text: _userData!['driversLicenseNumber']?.toString() ?? '',
    );
    final restrictionCodeController = TextEditingController(
      text: _userData!['driversLicenseRestrictionCode']?.toString() ?? '',
    );
    final expirationDateController = TextEditingController();
    DateTime? selectedExpirationDate;

    if (_userData!['driversLicenseExpirationDate'] != null) {
      try {
        selectedExpirationDate =
            _userData!['driversLicenseExpirationDate'] is DateTime
                ? _userData!['driversLicenseExpirationDate'] as DateTime
                : DateTime.tryParse(
                    _userData!['driversLicenseExpirationDate'].toString());
        if (selectedExpirationDate != null) {
          expirationDateController.text =
              DateFormat('MMM dd, yyyy').format(selectedExpirationDate);
        }
      } catch (e) {
        print('Error parsing expiration date: $e');
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Edit Driver's License Information",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(24.sp, 20.sp, 24.sp, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'License Number',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: licenseNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter license number',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'License Expiration Date',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: expirationDateController,
                      decoration: InputDecoration(
                        hintText: 'Select expiration date',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                        suffixIcon: Icon(Icons.calendar_today, size: 18.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                      readOnly: true,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedExpirationDate ??
                              DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 20)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedExpirationDate = pickedDate;
                            expirationDateController.text =
                                DateFormat('MMM dd, yyyy').format(pickedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Restriction Code (Optional)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    TextField(
                      controller: restrictionCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter restriction code',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.sp, vertical: 10.sp),
                      ),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save', style: TextStyle(fontSize: 13.sp)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Updating driver's license information..."),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Get current user ID
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) {
          throw Exception('User not authenticated');
        }

        final userId = authState.user!.id;

        // Prepare update data
        final updateData = <String, dynamic>{
          'driversLicenseNumber': licenseNumberController.text.trim(),
          'driversLicenseRestrictionCode':
              restrictionCodeController.text.trim(),
        };

        // Add expiration date if selected
        if (selectedExpirationDate != null) {
          updateData['driversLicenseExpirationDate'] =
              selectedExpirationDate!.toIso8601String();
        }

        // Update driver's license information in PocketBase
        final pocketBaseService = PocketBaseService();
        final updatedRecord =
            await pocketBaseService.updateUser(userId, updateData);

        // Refresh the auth store with updated user data
        final pocketBaseAuthRepo = context.read<AuthBloc>().pocketBaseAuth;
        final pb = pocketBaseAuthRepo.pocketBase;
        pb.authStore.save(pb.authStore.token, updatedRecord);

        // Wait for the stream to propagate the update
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Reload user data
        await _loadCurrentUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Driver's license information updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print("Error updating driver's license information: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating driver's license information: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Dispose controllers
    licenseNumberController.dispose();
    expirationDateController.dispose();
    restrictionCodeController.dispose();
  }

  Future<void> _uploadAdditionalVehiclePhotos() async {
    try {
      setState(() {
        _isUploadingAdditionalPhotos = true;
      });

      // Pick multiple images (max 6)
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty) {
        setState(() {
          _isUploadingAdditionalPhotos = false;
        });
        return;
      }

      // Limit to 6 photos
      if (pickedFiles.length > 6) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Maximum 6 photos allowed. Selected ${pickedFiles.length}, uploading first 6.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Convert to File list and take only first 6
      final imageFiles =
          pickedFiles.take(6).map((xFile) => File(xFile.path)).toList();

      // Get current user's vehicle
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      final pocketBaseService = PocketBaseService();
      final vehicles =
          await pocketBaseService.getVehiclesByUser(authState.user!.id);

      if (vehicles.isEmpty) {
        throw Exception('No vehicle found for this user');
      }

      final vehicleId = vehicles.first.id;

      // Upload images to PocketBase
      final updatedVehicle = await pocketBaseService.updateVehicle(vehicleId, {
        'photos': imageFiles,
      });

      // Update local vehicle data
      final pocketbaseUrl =
          FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      final photos = updatedVehicle.data['photos'];
      final vehiclePhotosUrls = photos is List && photos.isNotEmpty
          ? photos
              .map((photo) =>
                  '$pocketbaseUrl/api/files/${updatedVehicle.collectionId}/${updatedVehicle.id}/$photo')
              .toList()
              .cast<String>()
          : <String>[];

      setState(() {
        _vehicleData = updatedVehicle.data;
        _vehiclePhotosUrls = vehiclePhotosUrls;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${imageFiles.length} photo(s) uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading additional vehicle photos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAdditionalPhotos = false;
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.sp),

              // Personal Information Section
              _buildEditableInfoSection(
                title: 'Personal Information',
                icon: Icons.person,
                color: Colors.blue,
                onEdit: _showEditPersonalInfoDialog,
                children: [
                  _buildInfoRow('First Name',
                      (_userData!['firstName'] ?? 'N/A').toString()),
                  _buildInfoRow('Last Name',
                      (_userData!['lastName'] ?? 'N/A').toString()),
                  if (_userData!['middleName'] != null &&
                      _userData!['middleName'].toString().isNotEmpty)
                    _buildInfoRow(
                        'Middle Name', _userData!['middleName'].toString()),
                  _buildInfoRow(
                      'Gender', (_userData!['gender'] ?? 'N/A').toString()),
                  _buildInfoRow(
                      'Age', (_userData!['age']?.toString() ?? 'N/A')),
                  _buildInfoRow(
                      'Birth Date', _formatDate(_userData!['birthDate'])),
                  _buildInfoRow('Nationality',
                      (_userData!['nationality'] ?? 'N/A').toString()),
                  _buildInfoRow('Civil Status',
                      (_userData!['civilStatus'] ?? 'N/A').toString()),
                  if (_userData!['bloodType'] != null &&
                      _userData!['bloodType'].toString().isNotEmpty)
                    _buildInfoRow(
                        'Blood Type', _userData!['bloodType'].toString()),
                  if (_userData!['religion'] != null &&
                      _userData!['religion'].toString().isNotEmpty)
                    _buildInfoRow(
                        'Religion', _userData!['religion'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Contact Information Section
              _buildEditableInfoSection(
                title: 'Contact Information',
                icon: Icons.contact_phone,
                color: Colors.green,
                onEdit: _showEditContactDialog,
                children: [
                  _buildInfoRow('Contact Number',
                      (_userData!['contactNumber'] ?? 'N/A').toString()),
                  _buildInfoRow(
                      'Email', (_userData!['email'] ?? 'N/A').toString()),
                  if (_userData!['emergencyContactName'] != null &&
                      _userData!['emergencyContactName'].toString().isNotEmpty)
                    _buildInfoRow('Emergency Contact Name',
                        _userData!['emergencyContactName'].toString()),
                  if (_userData!['emergencyContactNumber'] != null &&
                      _userData!['emergencyContactNumber']
                          .toString()
                          .isNotEmpty)
                    _buildInfoRow('Emergency Contact Number',
                        _userData!['emergencyContactNumber'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Spouse Information Section (if available)
              if (_userData!['spouseName'] != null &&
                  _userData!['spouseName'].toString().isNotEmpty)
                _buildInfoSection(
                  title: 'Spouse Information',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  children: [
                    _buildInfoRow(
                        'Spouse Name', _userData!['spouseName'].toString()),
                    if (_userData!['spouseContactNumber'] != null &&
                        _userData!['spouseContactNumber'].toString().isNotEmpty)
                      _buildInfoRow('Spouse Contact Number',
                          _userData!['spouseContactNumber'].toString()),
                  ],
                ),
              if (_userData!['spouseName'] != null &&
                  _userData!['spouseName'].toString().isNotEmpty)
                SizedBox(height: 16.sp),

              // Driver's License Information Section
              _buildEditableInfoSection(
                title: "Driver's License Information",
                icon: Icons.drive_eta,
                color: Colors.orange,
                onEdit: _showEditDriversLicenseDialog,
                children: [
                  if (_userData!['driversLicenseNumber'] != null &&
                      _userData!['driversLicenseNumber'].toString().isNotEmpty)
                    _buildInfoRow('License Number',
                        _userData!['driversLicenseNumber'].toString()),
                  _buildInfoRow('License Expiration',
                      _formatDate(_userData!['driversLicenseExpirationDate'])),
                  if (_userData!['driversLicenseRestrictionCode'] != null &&
                      _userData!['driversLicenseRestrictionCode']
                          .toString()
                          .isNotEmpty)
                    _buildInfoRow('Restriction Code',
                        _userData!['driversLicenseRestrictionCode'].toString()),
                ],
              ),
              SizedBox(height: 16.sp),

              // Vehicle Information Section
              if (_vehicleData != null) _buildVehicleSection(),
              if (_vehicleData != null) SizedBox(height: 16.sp),

              // Account Information Section
              _buildInfoSection(
                title: 'Account Information',
                icon: Icons.account_circle,
                color: Colors.purple,
                children: [
                  _buildInfoRow('Member Number',
                      (_userData!['memberNumber'] ?? 'N/A').toString()),
                  _buildInfoRow('Membership Type',
                      _getMembershipTypeText(_userData!['membership_type'])),
                  _buildInfoRow('Account Status',
                      (_userData!['isActive'] == true ? 'Active' : 'Inactive')),
                  if (_userData!['created'] != null)
                    _buildInfoRow(
                        'Member Since', _formatDate(_userData!['created'])),
                  if (_userData!['updated'] != null)
                    _buildInfoRow(
                        'Last Updated', _formatDate(_userData!['updated'])),
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
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[800]!
                      : Theme.of(context).primaryColor,
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
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[800]
                    : Colors.white,
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
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
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

  Widget _buildVehicleSection() {
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
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.teal,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.sp),

            // Vehicle Photo
            Center(
              child: Stack(
                children: [
                  // Vehicle Photo Display
                  _isUploadingVehiclePhoto
                      ? Container(
                          width: 200.sp,
                          height: 150.sp,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : _vehiclePhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _vehiclePhotoUrl!,
                                width: 200.sp,
                                height: 150.sp,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200.sp,
                                    height: 150.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 60.sp,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 200.sp,
                              height: 150.sp,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                size: 60.sp,
                                color: Colors.grey[600],
                              ),
                            ),

                  // Edit button
                  if (!_isUploadingVehiclePhoto)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _showVehiclePhotoSourceDialog,
                        child: Container(
                          padding: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.teal,
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
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.sp),

            // Vehicle Details
            if (_vehicleData!['make'] != null || _vehicleData!['model'] != null)
              _buildInfoRow(
                'Make & Model',
                '${_vehicleData!['make'] ?? ''} ${_vehicleData!['model'] ?? ''}'
                    .trim(),
              ),
            if (_vehicleData!['year'] != null)
              _buildInfoRow('Year', _vehicleData!['year'].toString()),
            if (_vehicleData!['color'] != null &&
                _vehicleData!['color'].toString().isNotEmpty)
              _buildInfoRow('Color', _vehicleData!['color'].toString()),
            if (_vehicleData!['plateNumber'] != null &&
                _vehicleData!['plateNumber'].toString().isNotEmpty)
              _buildInfoRow(
                  'Plate Number', _vehicleData!['plateNumber'].toString()),
            if (_vehicleData!['type'] != null &&
                _vehicleData!['type'].toString().isNotEmpty)
              _buildInfoRow('Type', _vehicleData!['type'].toString()),

            // Additional Photos Section
            SizedBox(height: 16.sp),
            Divider(),
            SizedBox(height: 8.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Photos',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (_vehiclePhotosUrls.isNotEmpty)
                      Text(
                        '${_vehiclePhotosUrls.length}/6 photos',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                if (!_isUploadingAdditionalPhotos)
                  ElevatedButton.icon(
                    onPressed: _uploadAdditionalVehiclePhotos,
                    icon: Icon(Icons.add_photo_alternate, size: 18.sp),
                    label:
                        Text('Add Photos', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.sp, vertical: 8.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.sp),

            // Photos Grid
            if (_isUploadingAdditionalPhotos)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 8.sp),
                    Text('Uploading photos...',
                        style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              )
            else if (_vehiclePhotosUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.sp,
                  mainAxisSpacing: 8.sp,
                  childAspectRatio: 1,
                ),
                itemCount: _vehiclePhotosUrls.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _vehiclePhotosUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.broken_image, color: Colors.grey[600]),
                        );
                      },
                    ),
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.sp),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 48.sp, color: Colors.grey),
                      SizedBox(height: 8.sp),
                      Text(
                        'No additional photos',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 4.sp),
                      Text(
                        'Tap "Add Photos" to upload (max 6)',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    size: 20.sp,
                    color: color,
                  ),
                  tooltip: 'Edit',
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
      if (date is DateTime) {
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
