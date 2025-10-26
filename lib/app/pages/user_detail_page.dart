import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({
    required this.userData,
    super.key,
  });
  final Map<String, dynamic> userData;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isEditing = false;
  late Map<String, dynamic> _editedData;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedLicenseExpirationDate;
  DateTime? _selectedJoinedDate;
  Future<String?>? _profileImageUrlFuture;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  // Car image upload variables
  File? _selectedMainCarImage;
  File? _selectedCarImage1;
  File? _selectedCarImage2;
  File? _selectedCarImage3;
  File? _selectedCarImage4;
  bool _isUploadingCarImage = false;
  String? _uploadedMainCarImageUrl;
  String? _uploadedCarImage1Url;
  String? _uploadedCarImage2Url;
  String? _uploadedCarImage3Url;
  String? _uploadedCarImage4Url;

  @override
  void initState() {
    super.initState();
    _editedData = Map<String, dynamic>.from(widget.userData);

    // Initialize the date of birth from the user data
    if (_editedData['dateOfBirth'] != null) {
      final dateValue = _editedData['dateOfBirth'];
      if (dateValue is DateTime) {
        _selectedDateOfBirth = dateValue;
      } else if (dateValue is String) {
        _selectedDateOfBirth = DateTime.parse(dateValue);
      }
    }

    // Initialize the joined date from the user data
    if (_editedData['joinedDate'] != null) {
      final dateValue = _editedData['joinedDate'];
      if (dateValue is DateTime) {
        _selectedJoinedDate = dateValue;
      } else if (dateValue is String && dateValue.isNotEmpty) {
        _selectedJoinedDate = DateTime.tryParse(dateValue);
      }
    }
    // Initialize the license expiration date from the user data
    if (_editedData['driversLicenseExpirationDate'] != null) {
      final dateValue = _editedData['driversLicenseExpirationDate'];
      if (dateValue is DateTime) {
        _selectedLicenseExpirationDate = dateValue;
      } else if (dateValue is String) {
        _selectedLicenseExpirationDate = DateTime.parse(dateValue);
      }
    }

    // Check for profile image in multiple possible field names
    String? profileImageValue;
    if (_editedData['profileImage'] != null &&
        _editedData['profileImage'].toString().isNotEmpty) {
      profileImageValue = _editedData['profileImage'].toString();
    } else if (_editedData['profile_image'] != null &&
        _editedData['profile_image'].toString().isNotEmpty) {
      profileImageValue = _editedData['profile_image'].toString();
    }

    if (profileImageValue != null) {
      if (profileImageValue.startsWith('http')) {
        // It's already a full URL
        _profileImageUrlFuture = Future.value(profileImageValue);
      } else {
        // It's a PocketBase filename, construct the URL
        final pocketbaseUrl =
            FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        _profileImageUrlFuture = Future.value(
            '$pocketbaseUrl/api/files/users/${_editedData['id']}/$profileImageValue');
      }
    }

    // Ensure createdAt and updatedAt fields exist for backward compatibility
    _ensureTimestampFields();
  }

  void _ensureTimestampFields() {
    // If createdAt doesn't exist, set it to a default timestamp
    if (_editedData['createdAt'] == null) {
      _editedData['createdAt'] = DateTime.now().toIso8601String();
    }

    // If updatedAt doesn't exist, set it to the same as createdAt
    if (_editedData['updatedAt'] == null) {
      _editedData['updatedAt'] = _editedData['createdAt'];
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Show image source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      // Pick the image
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

      // Upload to PocketBase
      final userId = _editedData['id'] as String?;
      if (userId == null) {
        throw Exception('User ID not found in user data');
      }

      final file = File(pickedFile.path);

      // Upload file to PocketBase
      print('UserDetailPage - Starting profile image upload for user: $userId');
      print('UserDetailPage - File path: ${file.path}');
      print('UserDetailPage - File size: ${await file.length()} bytes');

      final pocketBaseService = PocketBaseService();
      final result = await pocketBaseService.updateUser(userId, {
        'profileImage': file,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('UserDetailPage - PocketBase update result: ${result.data}');

      // Get the profile image URL from the result
      final profileImageUrl = result.data['profileImage'] as String?;
      print('UserDetailPage - Profile image URL from result: $profileImageUrl');

      if (profileImageUrl != null) {
        // Construct the full URL
        final pocketbaseUrl =
            FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        final fullImageUrl =
            '$pocketbaseUrl/api/files/users/$userId/$profileImageUrl';
        print('UserDetailPage - Full image URL: $fullImageUrl');

        // Update the user data
        setState(() {
          _editedData['profileImage'] = profileImageUrl;
          _profileImageUrlFuture = Future.value(fullImageUrl);
        });
      } else {
        print(
            'UserDetailPage - Warning: No profile image URL returned from PocketBase');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('UserDetailPage - Error updating profile image: $e');
      print('UserDetailPage - Error type: ${e.runtimeType}');
      print('UserDetailPage - Error details: ${e.toString()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

  Future<File?> _pickCarImage() async {
    try {
      // Show image source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return null;

      // Pick the image
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<String?> _uploadCarImageToStorage(String imageName) async {
    File? selectedImage;

    // Determine which image to upload based on imageName
    switch (imageName) {
      case 'main':
        selectedImage = _selectedMainCarImage;
      case '1':
        selectedImage = _selectedCarImage1;
      case '2':
        selectedImage = _selectedCarImage2;
      case '3':
        selectedImage = _selectedCarImage3;
      case '4':
        selectedImage = _selectedCarImage4;
    }

    if (selectedImage == null) return null;

    try {
      setState(() {
        _isUploadingCarImage = true;
      });

      final userId = _editedData['id'] as String?;
      if (userId == null) {
        throw Exception('User ID not found in user data');
      }

      print('Uploading car image $imageName for user $userId');

      // Upload to PocketBase
      final pocketBaseService = PocketBaseService();
      final result = await pocketBaseService.updateUser(userId, {
        'carImage$imageName': selectedImage,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Get the car image URL from the result
      final carImageUrl = result.data['carImage$imageName'] as String?;
      if (carImageUrl != null) {
        // Construct the full URL
        final pocketbaseUrl =
            FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        final fullImageUrl =
            '$pocketbaseUrl/api/files/users/$userId/$carImageUrl';

        // Update the corresponding URL variable
        switch (imageName) {
          case 'main':
            setState(() {
              _uploadedMainCarImageUrl = fullImageUrl;
            });
          case '1':
            setState(() {
              _uploadedCarImage1Url = fullImageUrl;
            });
          case '2':
            setState(() {
              _uploadedCarImage2Url = fullImageUrl;
            });
          case '3':
            setState(() {
              _uploadedCarImage3Url = fullImageUrl;
            });
          case '4':
            setState(() {
              _uploadedCarImage4Url = fullImageUrl;
            });
        }

        setState(() {
          _isUploadingCarImage = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Car image $imageName uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return fullImageUrl;
      } else {
        throw Exception('Failed to get car image URL from PocketBase');
      }
    } catch (e) {
      print('Error uploading car image $imageName: $e');
      setState(() {
        _isUploadingCarImage = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading car image $imageName: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      throw Exception('Error uploading car image $imageName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authentication Error')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You are not logged in. Please log in again to view user details.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    try {
      // Extract vehicle data (now a single object; keep backward-compat for arrays)
      final rawVehicle = _editedData['vehicle'];
      Map<String, dynamic>? firstVehicle;
      if (rawVehicle is Map<String, dynamic>) {
        firstVehicle = rawVehicle;
      } else if (rawVehicle is List && rawVehicle.isNotEmpty) {
        final v = rawVehicle.first;
        if (v is Map<String, dynamic>) firstVehicle = v;
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                tooltip: 'Edit User',
              ),
            if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveChanges,
                tooltip: 'Save Changes',
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _cancelEdit,
                tooltip: 'Cancel Edit',
              ),
            ],
            // Debug button for testing car images
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _debugCarImages,
              tooltip: 'Debug Car Images',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      if ((_editedData['profileImage'] != null &&
                              _editedData['profileImage']
                                  .toString()
                                  .isNotEmpty) ||
                          (_editedData['profile_image'] != null &&
                              _editedData['profile_image']
                                  .toString()
                                  .isNotEmpty))
                        FutureBuilder<String?>(
                          future: _profileImageUrlFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircleAvatar(
                                  radius: 60,
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.red.shade100,
                                child: Tooltip(
                                  message: snapshot.error.toString(),
                                  child: const Icon(Icons.error,
                                      size: 60, color: Colors.red),
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const CircleAvatar(
                                  radius: 60,
                                  child: Icon(Icons.person, size: 60));
                            }
                            final imageUrl = snapshot.data!;
                            return CircleAvatar(
                              radius: 60,
                              child: ClipOval(
                                child: Image.network(
                                  imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 60);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const CircularProgressIndicator();
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const CircleAvatar(
                            radius: 60, child: Icon(Icons.person, size: 60)),

                      // Edit button overlay (only show when editing)
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _isUploadingImage
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 20),
                                    onPressed: _pickAndUploadImage,
                                    tooltip: 'Change Profile Image',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Section
                _buildSection(
                  'Personal Information',
                  [
                    _buildEditableField('First Name', 'firstName'),
                    _buildEditableField('Middle Name', 'middleName'),
                    _buildEditableField('Last Name', 'lastName'),
                    _buildEditableField('Age', 'age', isNumber: true),
                    _buildEditableField('Date of Birth', 'dateOfBirth',
                        isDate: true),
                    _buildEditableField('Birthplace', 'birthplace'),
                    _buildEditableField('Contact Number', 'contactNumber'),
                    _buildEditableField('Nationality', 'nationality'),
                    _buildEditableField('Religion', 'religion'),
                    _buildEditableField('Civil Status', 'civilStatus'),
                    _buildEditableField(
                      'Gender',
                      'gender',
                      isDropdown: true,
                      dropdownOptions: ['Male', 'Female', 'Other'],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Contact Information Section
                _buildSection(
                  'Emergency Contact ',
                  [
                    _buildEditableField('Contact Name', 'emergencyContactName'),
                    _buildEditableField(
                        'Contact Number', 'emergencyContactNumber'),
                  ],
                ),

                const SizedBox(height: 24),

                // Membership Information Section
                _buildSection(
                  'Membership Information',
                  [
                    _buildEditableField('Member Number', 'memberNumber',
                        isNumber: true),
                    _buildEditableField('Membership Type', 'membership_type'),
                    _buildEditableField('Is Active', 'isActive',
                        isBoolean: true),
                    _buildEditableField('Is Admin', 'isAdmin', isBoolean: true),
                    _buildEditableField('Joined Date', 'joinedDate',
                        isDate: true),
                  ],
                ),

                const SizedBox(height: 24),

                // Driver's License Information Section
                _buildSection(
                  "Driver's License Information",
                  [
                    _buildEditableField(
                        'License Number', 'driversLicenseNumber'),
                    _buildEditableField(
                        'License Exp. Date', 'driversLicenseExpirationDate',
                        isDate: true),
                    _buildEditableField('License Restriction Code',
                        'driversLicenseRestrictionCode',
                        isNumber: true),
                  ],
                ),

                const SizedBox(height: 24),

                // Spouse Information Section
                _buildSection(
                  'Spouse Information',
                  [
                    _buildEditableField('Spouse Name', 'spouseName'),
                    _buildEditableField(
                        'Spouse Contact Number', 'spouseContactNumber'),
                  ],
                ),

                const SizedBox(height: 24),

                // Vehicle Information Section
                if (firstVehicle != null)
                  _buildSection(
                    'Vehicle Information',
                    [
                      _buildDetailRow('Vehicle Make', firstVehicle['make']),
                      _buildDetailRow('Vehicle Model', firstVehicle['model']),
                      _buildDetailRow('Vehicle Year', firstVehicle['year']),
                      _buildDetailRow('Vehicle Color', firstVehicle['color']),
                      _buildDetailRow('Vehicle Type', firstVehicle['type']),
                      _buildDetailRow(
                          'License Plate', firstVehicle['plateNumber']),
                      if (_isEditing) ...[
                        const SizedBox(height: 16),
                        _buildCarImagesUploadSection(),
                      ] else ...[
                        const SizedBox(height: 16),
                        _buildCarImagesDisplaySection(firstVehicle),
                      ],
                    ],
                  ),

                const SizedBox(height: 24),

                // Medical Information Section
                _buildSection(
                  'Medical Information',
                  [
                    _buildEditableField(
                      'Blood Type',
                      'bloodType',
                      isDropdown: true,
                      dropdownOptions: [
                        'A+',
                        'A-',
                        'B+',
                        'B-',
                        'O+',
                        'O-',
                        'AB+',
                        'AB-'
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // System Information Section
                _buildSection(
                  'System Information',
                  [
                    _buildDetailRow('Joined Date', _editedData['joinedDate']),
                    _buildDetailRow('Created At', _editedData['createdAt']),
                    _buildDetailRow('Updated At', _editedData['updatedAt']),
                  ],
                ),

                const SizedBox(height: 32),

                // Delete Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error in UserDetailPage build: $e');
      print('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Error loading user details. Please try again.'),
        ),
      );
    }
  }

  Widget _buildEditableField(
    String label,
    String field, {
    bool isNumber = false,
    bool isBoolean = false,
    bool isDate = false,
    bool isDropdown = false,
    List<String>? dropdownOptions,
  }) {
    try {
      if (_isEditing) {
        if (isDate) {
          // Determine which date variable to use based on the field
          DateTime? selectedDate;
          if (field == 'dateOfBirth') {
            selectedDate = _selectedDateOfBirth;
          } else if (field == 'driversLicenseExpirationDate') {
            selectedDate = _selectedLicenseExpirationDate;
          } else if (field == 'joinedDate') {
            selectedDate = _selectedJoinedDate;
          } else if (_editedData[field] is String &&
              (_editedData[field] as String).isNotEmpty) {
            selectedDate = DateTime.tryParse(_editedData[field] as String);
          } else if (_editedData[field] is DateTime) {
            selectedDate = _editedData[field] as DateTime;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                              : 'Select Date',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          DateTime initialDate;
                          DateTime firstDate;
                          DateTime lastDate;

                          if (field == 'dateOfBirth') {
                            initialDate =
                                _selectedDateOfBirth ?? DateTime(now.year - 18);
                            firstDate = DateTime(1900);
                            lastDate = DateTime(now.year);
                          } else if (field == 'driversLicenseExpirationDate') {
                            initialDate = _selectedLicenseExpirationDate ??
                                DateTime(now.year + 1);
                            firstDate = DateTime(now.year);
                            lastDate = DateTime(now.year + 10);
                          } else if (field == 'joinedDate') {
                            initialDate = _selectedJoinedDate ?? now;
                            firstDate = DateTime(1900);
                            lastDate = DateTime(now.year + 10);
                          } else {
                            initialDate = DateTime(now.year);
                            firstDate = DateTime(1900);
                            lastDate = DateTime(now.year + 10);
                          }

                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            helpText: 'Select $label',
                            fieldLabelText: label,
                            fieldHintText: 'Date',
                          );
                          if (picked != null) {
                            setState(() {
                              if (field == 'dateOfBirth') {
                                _selectedDateOfBirth = picked;
                              } else if (field ==
                                  'driversLicenseExpirationDate') {
                                _selectedLicenseExpirationDate = picked;
                              } else if (field == 'joinedDate') {
                                _selectedJoinedDate = picked;
                              }
                              _editedData[field] = picked;
                            });
                          }
                        },
                        child: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (isDropdown && dropdownOptions != null) {
          final currentValue = _editedData[field]?.toString().trim();
          String? validValue;
          if (currentValue != null && currentValue.isNotEmpty) {
            for (final option in dropdownOptions) {
              if (option.toLowerCase() == currentValue.toLowerCase()) {
                validValue = option;
                break;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: validValue,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    items: dropdownOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _editedData[field] = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (isBoolean) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: (_editedData[field] as bool?) ?? false,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Yes')),
                      DropdownMenuItem(value: false, child: Text('No')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _editedData[field] = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: _editedData[field]?.toString() ?? '',
                    keyboardType:
                        isNumber ? TextInputType.number : TextInputType.text,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (isNumber) {
                          _editedData[field] = int.tryParse(value) ?? value;
                        } else {
                          _editedData[field] = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return _buildDetailRow(label, _editedData[field]);
      }
    } catch (e, stackTrace) {
      print('Error in _buildEditableField for $field: $e');
      print('Stack trace: $stackTrace');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'Error loading field',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Upload car images if selected
        String? mainCarImageUrl;
        String? carImage1Url;
        String? carImage2Url;
        String? carImage3Url;
        String? carImage4Url;

        if (_selectedMainCarImage != null) {
          try {
            mainCarImageUrl = await _uploadCarImageToStorage('main');
          } catch (e) {
            print('Main car image upload failed: $e');
          }
        }

        if (_selectedCarImage1 != null) {
          try {
            carImage1Url = await _uploadCarImageToStorage('1');
          } catch (e) {
            print('Car image 1 upload failed: $e');
          }
        }

        if (_selectedCarImage2 != null) {
          try {
            carImage2Url = await _uploadCarImageToStorage('2');
          } catch (e) {
            print('Car image 2 upload failed: $e');
          }
        }

        if (_selectedCarImage3 != null) {
          try {
            carImage3Url = await _uploadCarImageToStorage('3');
          } catch (e) {
            print('Car image 3 upload failed: $e');
          }
        }

        if (_selectedCarImage4 != null) {
          try {
            carImage4Url = await _uploadCarImageToStorage('4');
          } catch (e) {
            print('Car image 4 upload failed: $e');
          }
        }

        // Update the user in PocketBase
        final userId = _editedData['id']?.toString();
        if (userId != null) {
          // Remove the id field before updating (it's not a document field)
          final updateData = Map<String, dynamic>.from(_editedData);
          updateData.remove('id');

          // Convert DateTime to ISO string for PocketBase
          if (updateData['dateOfBirth'] is DateTime) {
            updateData['dateOfBirth'] =
                (updateData['dateOfBirth'] as DateTime).toIso8601String();
          }
          if (updateData['driversLicenseExpirationDate'] is DateTime) {
            updateData['driversLicenseExpirationDate'] =
                (updateData['driversLicenseExpirationDate'] as DateTime)
                    .toIso8601String();
          }

          // Convert any remaining Timestamp objects to ISO strings
          _convertTimestampsToIso(updateData);

          // Handle vehicle data - always remove first, then add back only if valid
          print(
              'Debug: Vehicle data before processing: ${updateData['vehicle']}');

          // Always remove vehicle field first to avoid validation errors
          updateData.remove('vehicle');

          // Check if we have valid vehicle data to include
          if (_editedData['vehicle'] != null) {
            Map<String, dynamic>? vehicle;
            if (_editedData['vehicle'] is Map<String, dynamic>) {
              vehicle = Map<String, dynamic>.from(
                  _editedData['vehicle'] as Map<String, dynamic>);
            } else if (_editedData['vehicle'] is List &&
                (_editedData['vehicle'] as List).isNotEmpty) {
              final vehicleList = _editedData['vehicle'] as List;
              vehicle = Map<String, dynamic>.from(
                  vehicleList[0] as Map<String, dynamic>);
            }

            if (vehicle != null) {
              // Check if vehicle has required fields before including it
              final hasRequiredFields = vehicle['make'] != null &&
                  vehicle['model'] != null &&
                  vehicle['year'] != null;

              print('Debug: Vehicle has required fields: $hasRequiredFields');
              print(
                  'Debug: Vehicle make: ${vehicle['make']}, model: ${vehicle['model']}, year: ${vehicle['year']}');

              if (hasRequiredFields) {
                final existingPhotos = List<String>.from(
                    (vehicle['photos'] as List<dynamic>?) ?? []);

                // Add new car images to photos array
                if (carImage1Url != null) existingPhotos.add(carImage1Url);
                if (carImage2Url != null) existingPhotos.add(carImage2Url);
                if (carImage3Url != null) existingPhotos.add(carImage3Url);
                if (carImage4Url != null) existingPhotos.add(carImage4Url);

                // Update primary photo if main car image was uploaded
                if (mainCarImageUrl != null) {
                  vehicle['primaryPhoto'] = mainCarImageUrl;
                }

                vehicle['photos'] = existingPhotos;
                // Store as single object
                updateData['vehicle'] = vehicle;
                print('Debug: Added valid vehicle to updateData');
              } else {
                print(
                    'Debug: Vehicle missing required fields, not including in update');
              }
            } else {
              print('Debug: Vehicle is null, not including in update');
            }
          } else {
            print('Debug: No vehicle data in _editedData');
          }

          print(
              'Debug: Final updateData before sending to PocketBase: ${updateData.keys.toList()}');
          print('Debug: Vehicle field in final data: ${updateData['vehicle']}');

          // Update user in PocketBase
          final pocketBaseService = PocketBaseService();
          await pocketBaseService.updateUser(userId, updateData);

          // Close loading dialog
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Exit edit mode
          setState(() {
            _isEditing = false;
            // Clear selected car images after successful save
            _selectedMainCarImage = null;
            _selectedCarImage1 = null;
            _selectedCarImage2 = null;
            _selectedCarImage3 = null;
            _selectedCarImage4 = null;
          });
        }
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _editedData = Map<String, dynamic>.from(widget.userData);
      _isEditing = false;
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    final firstName = _editedData['firstName'] ?? '';
    final lastName = _editedData['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final displayName = name.isNotEmpty ? name : 'this user';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete $displayName? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(BuildContext context) async {
    OverlayEntry? overlayEntry;

    try {
      print('Starting delete process...'); // Debug log

      // Get the user document ID from the userData
      final userId = (_editedData['id'] ?? _editedData['uid'])?.toString();
      // print('User ID to delete: $userId'); // Debug log

      if (userId == null || userId.isEmpty) {
        // Remove loading overlay
        print('User ID not found, returning error result...'); // Debug log
        Navigator.of(context).pop('error: User ID not found');
        print('Error result returned successfully'); // Debug log
        return;
      }

      // Check if trying to delete current user's account
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null && authState.user!.id == userId) {
        // Remove loading overlay
        print(
            'Attempting to delete own account, returning error result...'); // Debug log
        Navigator.of(context).pop('error: Cannot delete your own account');
        print('Error result returned successfully'); // Debug log
        return;
      }

      // Show loading indicator using overlay
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => const ColoredBox(
          color: Colors.black54,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
      overlay.insert(overlayEntry);

      // Delete user data from Firebase Storage
      // print('Deleting user data from Firebase Storage...'); // Debug log
      await _deleteUserStorageData(userId);
      // print('User data deleted from Firebase Storage successfully'); // Debug log

      // Delete the user from PocketBase
      // print('Deleting user from PocketBase...'); // Debug log
      try {
        final pocketBaseService = PocketBaseService();
        await pocketBaseService.deleteUser(userId);
        // print('User deleted from PocketBase successfully'); // Debug log
      } catch (pocketBaseError) {
        print('PocketBase deletion error: $pocketBaseError'); // Debug log
        // Check if it's a permission error
        if (pocketBaseError.toString().contains('permission-denied') ||
            pocketBaseError.toString().contains('permission') ||
            pocketBaseError.toString().contains('PERMISSION_DENIED')) {
          throw Exception(
              'Permission denied: Unable to delete user. Please check your permissions or try again.');
        }
        rethrow; // Re-throw other errors
      }

      // Add a small delay to ensure the deletion is processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove loading overlay
      overlayEntry.remove();
      overlayEntry = null;
      print('Loading overlay removed'); // Debug log

      // Navigate back immediately after successful deletion
      print('Returning result to previous page...'); // Debug log
      Navigator.of(context).pop('deleted');
      print('Result returned successfully'); // Debug log
    } catch (e) {
      print('Error during delete: $e'); // Debug log
      // Remove loading overlay if it exists
      if (overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }

      // Instead of showing error dialog, just return error result
      print('Returning error result to previous page...'); // Debug log
      Navigator.of(context).pop('error: $e');
      print('Error result returned successfully'); // Debug log
    }
  }

  Future<void> _deleteUserStorageData(String userId) async {
    try {
      // Since we're using PocketBase, file deletion is handled automatically
      // when the user record is deleted from PocketBase
      print('File deletion handled by PocketBase when user record is deleted');
    } catch (e) {
      print('Error in storage deletion process: $e');
      // Don't throw the error here, as we still want to delete the user record
      // even if file deletion fails
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    var displayValue = 'Not provided';

    if (value != null) {
      if (value is DateTime) {
        // Format for createdAt and updatedAt fields
        if (label == 'Created At' || label == 'Updated At') {
          final months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
          final month = months[value.month - 1];
          final day = value.day;
          final year = value.year;
          final hour = value.hour;
          final minute = value.minute;
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final displayMinute = minute.toString().padLeft(2, '0');

          displayValue =
              '$month $day, $year $displayHour:$displayMinute $period';
        } else {
          displayValue =
              '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
        }
      } else if (value is String && _isIsoDateString(value)) {
        try {
          final date = DateTime.parse(value);
          // Format for createdAt and updatedAt fields
          if (label == 'Created At' || label == 'Updated At') {
            final months = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December',
            ];
            final month = months[date.month - 1];
            final day = date.day;
            final year = date.year;
            final hour = date.hour;
            final minute = date.minute;
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
            final displayMinute = minute.toString().padLeft(2, '0');

            displayValue =
                '$month $day, $year $displayHour:$displayMinute $period';
          } else {
            displayValue =
                '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
          }
        } catch (e) {
          // If parsing fails, just display as string
          displayValue = value.toString();
        }
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else {
        displayValue = value.toString();
      }
    }

    // Check if this is an image field and has a valid URL
    final isImageField = label.toLowerCase().contains('photo') ||
        label.toLowerCase().contains('image') ||
        label.toLowerCase().contains('picture');

    final hasValidUrl = value is String && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: isImageField && hasValidUrl
                ? FutureBuilder<String?>(
                    future: _getPocketBaseImageUrl(value),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Tooltip(
                          message: snapshot.error.toString(),
                          child: const Row(
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Could not load image'),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Image not found');
                      }
                      final imageUrl = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    'Network image error for $imageUrl: $error');
                                return _buildCarImagePlaceholder(
                                    0, 'Failed', Colors.orange);
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Text(
                    displayValue,
                    style: const TextStyle(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarImagesUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Car Images',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        // Main Car Image
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primary Car Image',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Image Preview
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedMainCarImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedMainCarImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : FutureBuilder<String?>(
                          future: _loadMainCarImageFromStorage(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasData && snapshot.data != null) {
                              // Show existing main car image from Firebase Storage
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        'https://placehold.co/80x80/CCCCCC/666666?text=Main',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.directions_car,
                                              size: 40,
                                              color: Colors.grey);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            }

                            // Show placeholder if no image exists
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://placehold.co/80x80/CCCCCC/666666?text=Main',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.directions_car,
                                      size: 40, color: Colors.grey);
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 16),
                // Upload Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isUploadingCarImage
                            ? null
                            : () async {
                                final image = await _pickCarImage();
                                if (image != null) {
                                  setState(() {
                                    _selectedMainCarImage = image;
                                  });
                                }
                              },
                        icon: _isUploadingCarImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt),
                        label: Text(
                            _isUploadingCarImage ? 'Uploading...' : 'Change'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedMainCarImage != null
                            ? 'Image selected: ${_selectedMainCarImage!.path.split('/').last}'
                            : 'No main image selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Additional Car Images Grid
        Text(
          'Additional Car Images (1-4)',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Grid of car images for editing
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final imageNumber = index + 1;
            File? selectedImage;

            // Determine which image variable to use based on index
            switch (imageNumber) {
              case 1:
                selectedImage = _selectedCarImage1;
              case 2:
                selectedImage = _selectedCarImage2;
              case 3:
                selectedImage = _selectedCarImage3;
              case 4:
                selectedImage =
                    _selectedCarImage4; // 4th car image, separate from main
            }

            // If no locally selected image, try to load from PocketBase
            if (selectedImage == null) {
              final userId = _editedData['id'] as String?;
              if (userId != null) {
                final carImageData =
                    _editedData['carImage$imageNumber'] as String?;
                String? imageUrl;
                if (carImageData != null && carImageData.isNotEmpty) {
                  final pocketbaseUrl = FlavorConfig
                      .instance.variables['pocketbaseUrl'] as String;
                  imageUrl =
                      '$pocketbaseUrl/api/files/users/$userId/$carImageData';
                }

                return FutureBuilder<String?>(
                  future: Future.value(imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    // If image exists in Firebase Storage, show it
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return ColoredBox(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.directions_car,
                                              size: 32, color: Colors.grey),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Car $imageNumber',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Image number overlay
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$imageNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Upload button overlay
                            Positioned(
                              bottom: 4,
                              left: 4,
                              right: 4,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final pickedImage = await _pickCarImage();
                                  if (pickedImage != null) {
                                    setState(() {
                                      switch (imageNumber) {
                                        case 1:
                                          _selectedCarImage1 = pickedImage;
                                        case 2:
                                          _selectedCarImage2 = pickedImage;
                                        case 3:
                                          _selectedCarImage3 = pickedImage;
                                        case 4:
                                          _selectedCarImage4 = pickedImage;
                                      }
                                    });
                                  }
                                },
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text(
                                  'Change',
                                  style: TextStyle(fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: const Size(0, 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // If no image exists, show placeholder
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://placehold.co/300x200/CCCCCC/666666?text=Car+$imageNumber',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.directions_car,
                                            size: 32, color: Colors.grey),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Car $imageNumber',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Image number overlay
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$imageNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Upload button overlay
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 4,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final pickedImage = await _pickCarImage();
                                if (pickedImage != null) {
                                  setState(() {
                                    switch (imageNumber) {
                                      case 1:
                                        _selectedCarImage1 = pickedImage;
                                      case 2:
                                        _selectedCarImage2 = pickedImage;
                                      case 3:
                                        _selectedCarImage3 = pickedImage;
                                      case 4:
                                        _selectedCarImage4 = pickedImage;
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: Text(
                                selectedImage != null ? 'Change' : 'Upload',
                                style: const TextStyle(fontSize: 10),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: const Size(0, 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }

            // If locally selected image exists, show it
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Image or Placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.network(
                            'https://placehold.co/300x200/CCCCCC/666666?text=Car+$imageNumber',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.directions_car,
                                          size: 32, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Car $imageNumber',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Image number overlay
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$imageNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Upload button overlay
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final pickedImage = await _pickCarImage();
                        if (pickedImage != null) {
                          setState(() {
                            switch (imageNumber) {
                              case 1:
                                _selectedCarImage1 = pickedImage;
                              case 2:
                                _selectedCarImage2 = pickedImage;
                              case 3:
                                _selectedCarImage3 = pickedImage;
                              case 4:
                                _selectedCarImage4 = pickedImage;
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: Text(
                        selectedImage != null ? 'Change' : 'Upload',
                        style: const TextStyle(fontSize: 10),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCarImagesDisplaySection(Map<String, dynamic> vehicle) {
    final primaryPhoto = vehicle['primaryPhoto'] as String?;

    // Debug logging
    // print('Vehicle data: $vehicle');
    // print('Primary photo: $primaryPhoto');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Primary Image',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Main car image display
        FutureBuilder<String?>(
          future: _loadMainCarImageFromStorage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Error loading main car image',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              // Show main car image from Firebase Storage
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.grey, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load main car image',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            // Show placeholder if no main image exists
            return Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://placehold.co/400x200/CCCCCC/666666?text=Main+Car+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return ColoredBox(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No main car image',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Additional Car Images Grid (1-4)
        Text('Car Images (1-4)',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // Grid of car images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final imageNumber = index + 1;
            final userId = _editedData['id'] as String?;

            if (userId == null) {
              return _buildCarImagePlaceholder(
                  imageNumber, 'No user ID', Colors.grey);
            }

            // Get car image from PocketBase
            final carImageData = _editedData['carImage$imageNumber'] as String?;
            String? imageUrl;
            if (carImageData != null && carImageData.isNotEmpty) {
              final pocketbaseUrl =
                  FlavorConfig.instance.variables['pocketbaseUrl'] as String;
              imageUrl = '$pocketbaseUrl/api/files/users/$userId/$carImageData';
            }

            return FutureBuilder<String?>(
              future: Future.value(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                // If image is missing (null), use placehold.co
                if (snapshot.data == null) {
                  final placeholderUrl =
                      'https://placehold.co/300x200/CCCCCC/666666?text=Car+$imageNumber';
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            placeholderUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCarImagePlaceholder(
                                  imageNumber, 'Empty', Colors.grey);
                            },
                          ),
                          // Image number overlay
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$imageNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Check if the error is due to missing file (404) vs actual error
                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  // If it's a "not found" error, use placehold.co
                  if (error.contains('not found') ||
                      error.contains('404') ||
                      error.contains('object does not exist')) {
                    final placeholderUrl =
                        'https://placehold.co/300x200/CCCCCC/666666?text=Car+$imageNumber';
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              placeholderUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildCarImagePlaceholder(
                                    imageNumber, 'Empty', Colors.grey);
                              },
                            ),
                            // Image number overlay
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$imageNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // For actual errors, show error state
                  // print('Error loading car image $imageNumber: $error');
                  return _buildCarImagePlaceholder(
                      imageNumber, 'Error', Colors.red);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  final placeholderUrl =
                      'https://placehold.co/300x200/CCCCCC/666666?text=Car+$imageNumber';
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            placeholderUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCarImagePlaceholder(
                                  imageNumber, 'Empty', Colors.grey);
                            },
                          ),
                          // Image number overlay
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$imageNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // print('Successfully loaded car image $imageNumber: ${snapshot.data}');
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            // print('Network image error for $imageNumber: $error');
                            return _buildCarImagePlaceholder(
                                imageNumber, 'Failed', Colors.orange);
                          },
                        ),
                        // Image number overlay
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$imageNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCarImagePlaceholder(
      int imageNumber, String status, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'Empty' ? Icons.directions_car : Icons.error,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              '$status $imageNumber',
              style: TextStyle(color: color, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _loadMainCarImageFromStorage() async {
    final userId = _editedData['id'] as String?;
    if (userId == null) {
      throw Exception('User ID not found in user data');
    }

    // Check if user has car image data
    final carImageData = _editedData['carImagemain'] as String?;
    if (carImageData != null && carImageData.isNotEmpty) {
      final pocketbaseUrl =
          FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      return '$pocketbaseUrl/api/files/users/$userId/$carImageData';
    }

    return null;
  }

  Future<bool> _checkCarImageExists(String imageName) async {
    try {
      final userId = _editedData['id'] as String?;
      if (userId == null) {
        return false;
      }

      // Check if car image data exists in user data
      final carImageData = _editedData['carImage$imageName'] as String?;
      return carImageData != null && carImageData.isNotEmpty;
    } catch (e) {
      // File doesn't exist or other error
      return false;
    }
  }

  Future<void> _debugCarImages() async {
    print('=== Debugging Car Images ===');
    final userId = _editedData['id'] as String?;
    print('User ID: $userId');

    if (userId != null) {
      for (final imageName in ['main', '1', '2', '3', '4']) {
        final exists = await _checkCarImageExists(imageName);
        print('Car image $imageName exists: $exists');

        if (exists) {
          try {
            final carImageData = _editedData['carImage$imageName'] as String?;
            if (carImageData != null) {
              final pocketbaseUrl =
                  FlavorConfig.instance.variables['pocketbaseUrl'] as String;
              final downloadUrl =
                  '$pocketbaseUrl/api/files/users/$userId/$carImageData';
              print('Car image $imageName download URL: $downloadUrl');
            }
          } catch (e) {
            print('Error getting download URL for $imageName: $e');
          }
        }
      }
    }
    print('=== End Debug ===');
  }

  /// Helper method to check if a string is a valid ISO 8601 date string
  bool _isIsoDateString(String value) {
    // Check if the string matches ISO 8601 date format pattern
    // Format: YYYY-MM-DDTHH:MM:SS or variations with timezone
    final isoDateRegex = RegExp(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}',
      caseSensitive: false,
    );
    return isoDateRegex.hasMatch(value);
  }

  void _convertTimestampsToIso(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is DateTime) {
        data[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        _convertTimestampsToIso(value);
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          if (value[i] is DateTime) {
            value[i] = (value[i] as DateTime).toIso8601String();
          } else if (value[i] is Map<String, dynamic>) {
            _convertTimestampsToIso(value[i] as Map<String, dynamic>);
          }
        }
      }
    });
  }

  Future<String?> _getPocketBaseImageUrl(String value) async {
    try {
      if (value.startsWith('http')) {
        // It's already a full URL
        return value;
      } else {
        // It's a PocketBase filename, construct the URL
        final pocketbaseUrl =
            FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        return '$pocketbaseUrl/api/files/users/${_editedData['id']}/$value';
      }
    } catch (e) {
      print('Error getting PocketBase image URL for $value: $e');
      return null;
    }
  }
}
