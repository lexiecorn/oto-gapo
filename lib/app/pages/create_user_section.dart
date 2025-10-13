import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class CreateUserSection extends StatefulWidget {
  const CreateUserSection({super.key});

  @override
  State<CreateUserSection> createState() => _CreateUserSectionState();
}

class _CreateUserSectionState extends State<CreateUserSection> {
  // Controllers for create user form
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newFirstNameController = TextEditingController();
  final TextEditingController _newLastNameController = TextEditingController();
  // Additional controllers for new fields
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthplaceController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedCivilStatus;
  final TextEditingController _civilStatusController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  final TextEditingController _driversLicenseExpirationDateController = TextEditingController();
  DateTime? _selectedLicenseExpirationDate;
  final TextEditingController _driversLicenseNumberController = TextEditingController();
  final TextEditingController _driversLicenseRestrictionCodeController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactNumberController = TextEditingController();
  final TextEditingController _isActiveController = TextEditingController();
  bool _isActive = true;
  bool _isAdmin = false;
  final TextEditingController _isAdminController = TextEditingController();
  final TextEditingController _memberNumberController = TextEditingController();
  final TextEditingController _membershipTypeController = TextEditingController();
  String? _selectedMembershipType = '3'; // Default to Member
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _spouseContactNumberController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  // Vehicle fields (flat)
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehiclePhotosController = TextEditingController();
  final TextEditingController _vehiclePlateNumberController = TextEditingController();
  final TextEditingController _vehiclePrimaryPhotoController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  String? _selectedVehicleType = 'Sedan'; // Default to Sedan
  int? _selectedVehicleYear;
  bool _isCreatingUser = false;
  String? _createUserMessage;
  List<String> _vehicleMakes = [];
  String? _selectedVehicleMake;
  List<String> _vehicleModels = [];
  String? _selectedVehicleModel;
  bool _isLoadingVehicleModels = false;
  bool _isLoadingVehicleMakes = false;
  bool _showSuggestions = false;
  bool _showManualModelEntry = false;
  final TextEditingController _vehicleMakeController = TextEditingController();
  final FocusNode _vehicleMakeFocusNode = FocusNode();
  Color _selectedVehicleColor = Colors.black;
  String? _message;

  // Debounce timer for vehicle make search
  Timer? _debounceTimer;

  // Profile image upload variables
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedProfileImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

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

  // Helper method to create consistent TextField styling
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    String? prefixText,
    String? suffixText,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.sp),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.sp),
        borderSide: BorderSide(color: isDark ? colorScheme.outline.withOpacity(0.5) : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.sp),
        borderSide: BorderSide(color: isDark ? colorScheme.primary : Colors.blue, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: 14.sp,
        color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
      ),
      hintStyle: TextStyle(
        fontSize: 13.sp,
        color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[400],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.sp,
        vertical: 12.sp,
      ),
    );
  }

  // Helper method to create consistent TextField text style
  TextStyle _buildTextStyle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return TextStyle(
      fontSize: 14.sp,
      color: isDark ? colorScheme.onSurface : Colors.black87,
    );
  }

  // Helper method to create consistent dropdown text style
  TextStyle _buildDropdownTextStyle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return TextStyle(
      fontSize: 14.sp,
      color: isDark ? colorScheme.onSurface : Colors.black87,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchVehicleMakes();
    // Initialize membership type controller with default value (Member = 3)
    _membershipTypeController.text = '3';
    // Initialize vehicle type controller with default value (Sedan)
    _vehicleTypeController.text = 'Sedan';

    // Add focus listener to hide suggestions when focus is lost
    _vehicleMakeFocusNode.addListener(() {
      if (!_vehicleMakeFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _vehicleMakeController.dispose();
    _vehicleMakeFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchVehicleMakes() async {
    setState(() {
      _isLoadingVehicleMakes = true;
    });

    try {
      final response = await http.get(Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetAllMakes?format=json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;
        final makes = results.map((e) => e['Make_Name'].toString()).toList();

        setState(() {
          _vehicleMakes = makes;
          _isLoadingVehicleMakes = false;
          if (!_vehicleMakes.contains(_selectedVehicleMake)) {
            _selectedVehicleMake = null;
          }
        });
      } else {
        // Fallback to common makes if API fails
        final fallbackMakes = [
          'Toyota',
          'Honda',
          'Ford',
          'Chevrolet',
          'Nissan',
          'BMW',
          'Mercedes-Benz',
          'Audi',
          'Volkswagen',
          'Hyundai',
          'Kia',
          'Mazda',
          'Subaru',
          'Lexus',
          'Acura',
          'Infiniti',
          'Buick',
          'Cadillac',
          'Chrysler',
          'Dodge',
          'Jeep',
          'Ram',
          'GMC',
          'Lincoln',
          'Porsche',
          'Volvo',
          'Jaguar',
          'Land Rover',
          'Mini',
          'Fiat',
          'Alfa Romeo',
          'Maserati',
          'Ferrari',
          'Lamborghini',
          'McLaren',
          'Bentley',
          'Rolls-Royce',
          'Aston Martin',
          'Lotus',
          'Tesla',
        ];
        setState(() {
          _vehicleMakes = fallbackMakes;
          _selectedVehicleMake = null;
          _isLoadingVehicleMakes = false;
        });
      }
    } catch (e) {
      // Fallback to common makes if API fails
      final fallbackMakes = [
        'Toyota',
        'Honda',
        'Ford',
        'Chevrolet',
        'Nissan',
        'BMW',
        'Mercedes-Benz',
        'Audi',
        'Volkswagen',
        'Hyundai',
        'Kia',
        'Mazda',
        'Subaru',
        'Lexus',
        'Acura',
        'Infiniti',
        'Buick',
        'Cadillac',
        'Chrysler',
        'Dodge',
        'Jeep',
        'Ram',
        'GMC',
        'Lincoln',
        'Porsche',
        'Volvo',
        'Jaguar',
        'Land Rover',
        'Mini',
        'Fiat',
        'Alfa Romeo',
        'Maserati',
        'Ferrari',
        'Lamborghini',
        'McLaren',
        'Bentley',
        'Rolls-Royce',
        'Aston Martin',
        'Lotus',
        'Tesla',
      ];
      setState(() {
        _vehicleMakes = fallbackMakes;
        _selectedVehicleMake = null;
        _isLoadingVehicleMakes = false;
      });
    }
  }

  Future<List<String>> fetchModelsForMake(String make) async {
    final response =
        await http.get(Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/$make?format=json'));
    final data = json.decode(response.body);
    final results = data['Results'] as List;
    return results.map((e) => e['Model_Name'].toString()).toList();
  }

  Future<void> _onVehicleMakeChanged(String? make) async {
    setState(() {
      _selectedVehicleMake = make;
      _selectedVehicleModel = null;
      _vehicleModels = [];
      _isLoadingVehicleModels = make != null;
      _showSuggestions = false;
      _showManualModelEntry = false;
    });

    // Update the text controller
    _vehicleMakeController.text = make ?? '';

    // Remove focus to close keyboard
    _vehicleMakeFocusNode.unfocus();

    if (make != null) {
      try {
        final models = await fetchModelsForMake(make);
        setState(() {
          _vehicleModels = models;
          _isLoadingVehicleModels = false;
        });
      } catch (e) {
        setState(() {
          _vehicleModels = [];
          _isLoadingVehicleModels = false;
        });
      }
    }
  }

  void _onVehicleMakeTextChanged(String value) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Set a new timer to debounce the search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (value.isEmpty) {
            _showSuggestions = false;
            _selectedVehicleMake = null;
            _selectedVehicleModel = null;
            _vehicleModels = [];
          } else {
            _showSuggestions = true;
          }
        });
      }
    });
  }

  List<String> _getFilteredVehicleMakes() {
    final searchText = _vehicleMakeController.text.toLowerCase().trim();

    // If search text is empty, return empty list
    if (searchText.isEmpty) {
      return [];
    }

    // Use more efficient filtering
    final filteredMakes = <String>[];
    for (final make in _vehicleMakes) {
      if (make.toLowerCase().contains(searchText)) {
        filteredMakes.add(make);
        // Limit to 20 results for performance
        if (filteredMakes.length >= 20) break;
      }
    }

    // Sort results to show exact matches first, then partial matches
    filteredMakes.sort((a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();

      // Exact matches first
      if (aLower == searchText && bLower != searchText) return -1;
      if (bLower == searchText && aLower != searchText) return 1;

      // Starts with matches second
      if (aLower.startsWith(searchText) && !bLower.startsWith(searchText)) return -1;
      if (bLower.startsWith(searchText) && !aLower.startsWith(searchText)) return 1;

      // Alphabetical order for the rest
      return aLower.compareTo(bLower);
    });

    return filteredMakes;
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Show image source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
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

      setState(() {
        _selectedProfileImage = File(pickedFile.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
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

  Future<String?> _uploadProfileImageToStorage(String userId) async {
    if (_selectedProfileImage == null) return null;

    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/images/profile.png');

      await storageRef.putFile(_selectedProfileImage!);

      // Get the gs:// URI
      final gsUri = 'gs://${storageRef.bucket}/${storageRef.fullPath}';

      setState(() {
        _uploadedImageUrl = gsUri;
        _isUploadingImage = false;
      });

      return gsUri;
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      throw Exception('Error uploading profile image: $e');
    }
  }

  Future<File?> _pickCarImage() async {
    try {
      // Show image source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    'Gallery',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(
                    'Camera',
                    style: TextStyle(fontSize: 14.sp),
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

  Future<String?> _uploadCarImageToStorage(String userId, String imageName) async {
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

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/images/cars/$imageName.png');

      await storageRef.putFile(selectedImage);

      // Get the gs:// URI
      final gsUri = 'gs://${storageRef.bucket}/${storageRef.fullPath}';

      // Update the corresponding URL variable
      switch (imageName) {
        case 'main':
          setState(() {
            _uploadedMainCarImageUrl = gsUri;
          });
        case '1':
          setState(() {
            _uploadedCarImage1Url = gsUri;
          });
        case '2':
          setState(() {
            _uploadedCarImage2Url = gsUri;
          });
        case '3':
          setState(() {
            _uploadedCarImage3Url = gsUri;
          });
        case '4':
          setState(() {
            _uploadedCarImage4Url = gsUri;
          });
      }

      setState(() {
        _isUploadingCarImage = false;
      });

      return gsUri;
    } catch (e) {
      setState(() {
        _isUploadingCarImage = false;
      });
      throw Exception('Error uploading car image: $e');
    }
  }

  Future<void> _createUser() async {
    final email = _newEmailController.text.trim();
    final password = _newPasswordController.text.trim();
    final firstName = _newFirstNameController.text.trim();
    final lastName = _newLastNameController.text.trim();
    // Additional fields
    final age = _ageController.text.trim();
    final birthplace = _birthplaceController.text.trim();
    final bloodType = _bloodTypeController.text.trim();
    final civilStatus = _civilStatusController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final dateOfBirth = _selectedDateOfBirth;
    final driversLicenseExpirationDate = _selectedLicenseExpirationDate;
    final driversLicenseNumber = _driversLicenseNumberController.text.trim();
    final driversLicenseRestrictionCode = _driversLicenseRestrictionCodeController.text.trim();
    final emergencyContactName = _emergencyContactNameController.text.trim();
    final emergencyContactNumber = _emergencyContactNumberController.text.trim();
    final isActive = _isActive;
    final isAdmin = _isAdmin;
    final memberNumber = _memberNumberController.text.trim();
    final membershipType = int.tryParse(_membershipTypeController.text.trim()) ?? 3;
    final middleName = _middleNameController.text.trim();
    final nationality = _nationalityController.text.trim();
    final profileImage = _profileImageController.text.trim();
    final religion = _religionController.text.trim();
    final spouseContactNumber = _spouseContactNumberController.text.trim();
    final spouseName = _spouseNameController.text.trim();
    // Vehicle fields
    final vehicleColor = _vehicleColorController.text.trim();
    final vehicleModel =
        _selectedVehicleModel == 'custom' ? _vehicleModelController.text.trim() : (_selectedVehicleModel ?? '');
    final vehiclePhotos =
        _vehiclePhotosController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final vehiclePlateNumber = _vehiclePlateNumberController.text.trim();
    final vehiclePrimaryPhoto = _vehiclePrimaryPhotoController.text.trim();
    final vehicleType = _selectedVehicleType ?? 'Sedan';
    final vehicleYear = _selectedVehicleYear ?? 0;
    final vehicleMake = _selectedVehicleMake ?? '';

    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      setState(
        () => _createUserMessage = 'Please fill in all required fields (email, password, first name, last name).',
      );
      return;
    }

    setState(() {
      _isCreatingUser = true;
      _createUserMessage = null;
    });

    try {
      // Create user in PocketBase
      print('Creating PocketBase user with email: $email');
      final pocketBaseService = PocketBaseService();

      // Create user in PocketBase
      final userRecord = await pocketBaseService.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        additionalData: {
          'joinedDate': DateTime.now().toIso8601String(),
        },
      );

      final uid = userRecord.id;
      print('PocketBase user created successfully with ID: $uid');

      // Upload profile image if selected
      String? profileImageUrl;
      if (_selectedProfileImage != null) {
        try {
          profileImageUrl = await _uploadProfileImageToStorage(uid);
        } catch (e) {
          // Continue with user creation even if image upload fails
          print('Profile image upload failed: $e');
        }
      }

      // Upload car images if selected
      String? mainCarImageUrl;
      String? carImage1Url;
      String? carImage2Url;
      String? carImage3Url;
      String? carImage4Url;

      if (_selectedMainCarImage != null) {
        try {
          mainCarImageUrl = await _uploadCarImageToStorage(uid, 'main');
        } catch (e) {
          print('Main car image upload failed: $e');
        }
      }

      if (_selectedCarImage1 != null) {
        try {
          carImage1Url = await _uploadCarImageToStorage(uid, '1');
        } catch (e) {
          print('Car image 1 upload failed: $e');
        }
      }

      if (_selectedCarImage2 != null) {
        try {
          carImage2Url = await _uploadCarImageToStorage(uid, '2');
        } catch (e) {
          print('Car image 2 upload failed: $e');
        }
      }

      if (_selectedCarImage3 != null) {
        try {
          carImage3Url = await _uploadCarImageToStorage(uid, '3');
        } catch (e) {
          print('Car image 3 upload failed: $e');
        }
      }

      if (_selectedCarImage4 != null) {
        try {
          carImage4Url = await _uploadCarImageToStorage(uid, '4');
        } catch (e) {
          print('Car image 4 upload failed: $e');
        }
      }

      // Update user data in PocketBase
      print('Updating PocketBase user data with ID: $uid');
      final userData = {
        'age': age.isNotEmpty ? double.tryParse(age) : null,
        'birthDate': dateOfBirth?.toIso8601String(), // Schema has birthDate as date field
        'bloodType': bloodType,
        'civilStatus': civilStatus,
        'contactNumber': contactNumber,
        'driversLicenseExpirationDate': driversLicenseExpirationDate?.toIso8601String(),
        'driversLicenseNumber': driversLicenseNumber,
        'driversLicenseRestrictionCode': driversLicenseRestrictionCode,
        'email': email,
        'emergencyContactName': emergencyContactName,
        'emergencyContactNumber': emergencyContactNumber,
        'firstName': firstName,
        'gender': '', // Add gender field if needed
        'id': uid,
        'isActive': isActive,
        'isAdmin': isAdmin,
        'lastName': lastName,
        'memberNumber': memberNumber.isNotEmpty ? double.tryParse(memberNumber) : null,
        'membership_type': membershipType,
        'middleName': middleName,
        'nationality': nationality,
        'profileImage': profileImageUrl ?? profileImage, // Use uploaded image URL or fallback to text input
        'religion': religion,
        'spouseContactNumber': spouseContactNumber,
        'spouseName': spouseName,
      };

      // Update user in PocketBase
      await pocketBaseService.updateUser(uid, userData);
      print('PocketBase user updated successfully');

      // Create vehicle record if vehicle data is provided
      if (vehicleMake.isNotEmpty || vehicleModel.isNotEmpty || vehiclePlateNumber.isNotEmpty) {
        print('Creating vehicle record for user: $uid');
        try {
          final vehiclePhotosUrls = [
            ...vehiclePhotos,
            if (carImage1Url != null) carImage1Url,
            if (carImage2Url != null) carImage2Url,
            if (carImage3Url != null) carImage3Url,
            if (carImage4Url != null) carImage4Url,
          ].where((url) => url.isNotEmpty).toList();

          await pocketBaseService.createVehicle(
            userId: uid,
            color: vehicleColor,
            make: vehicleMake,
            model: vehicleModel,
            plateNumber: vehiclePlateNumber,
            type: vehicleType,
            year: vehicleYear,
            primaryPhoto: mainCarImageUrl ?? vehiclePrimaryPhoto,
            photos: vehiclePhotosUrls.isNotEmpty ? vehiclePhotosUrls : null,
          );
          print('Vehicle record created successfully');
        } catch (e) {
          print('Error creating vehicle record: $e');
          // Continue even if vehicle creation fails
        }
      }

      setState(() {
        _isCreatingUser = false;
        _createUserMessage = 'User created successfully! PocketBase user created with ID: $uid';
        _newEmailController.clear();
        _newPasswordController.clear();
        _newFirstNameController.clear();
        _newLastNameController.clear();
        _ageController.clear();
        _birthplaceController.clear();
        _bloodTypeController.clear();
        _civilStatusController.clear();
        _contactNumberController.clear();
        _dateOfBirthController.clear();
        _driversLicenseExpirationDateController.clear();
        _driversLicenseNumberController.clear();
        _driversLicenseRestrictionCodeController.clear();
        _emergencyContactNameController.clear();
        _emergencyContactNumberController.clear();
        _isActiveController.clear();
        _isAdminController.clear();
        _memberNumberController.clear();
        _membershipTypeController.clear();
        _middleNameController.clear();
        _nationalityController.clear();
        _profileImageController.clear();
        _religionController.clear();
        _spouseContactNumberController.clear();
        _spouseNameController.clear();
        _vehicleColorController.clear();
        _vehicleModelController.clear();
        _vehiclePhotosController.text = '';
        _vehiclePlateNumberController.clear();
        _vehiclePrimaryPhotoController.clear();
        _vehicleTypeController.clear();
        _selectedVehicleType = 'Sedan'; // Reset to default
        _selectedVehicleYear = null;
        _selectedVehicleMake = null;
        // Clear profile image variables
        _selectedProfileImage = null;
        _uploadedImageUrl = null;
        // Clear car image variables
        _selectedMainCarImage = null;
        _selectedCarImage1 = null;
        _selectedCarImage2 = null;
        _selectedCarImage3 = null;
        _selectedCarImage4 = null;
        _uploadedMainCarImageUrl = null;
        _uploadedCarImage1Url = null;
        _uploadedCarImage2Url = null;
        _uploadedCarImage3Url = null;
        _uploadedCarImage4Url = null;
      });
    } catch (e) {
      // Handle PocketBase errors
      var errorMessage = 'Error creating user: ';
      if (e.toString().contains('email') && e.toString().contains('already')) {
        errorMessage += 'An account already exists for that email.';
      } else if (e.toString().contains('password')) {
        errorMessage += 'The password provided is too weak.';
      } else if (e.toString().contains('email')) {
        errorMessage += 'The email address is invalid.';
      } else {
        errorMessage += e.toString();
      }

      setState(() {
        _isCreatingUser = false;
        _createUserMessage = errorMessage;
      });
      print('PocketBase error: $e');
      print('General error during user creation: $e');
    }
  }

  // Helper method to get random item from a list
  String _getRandomItem(List<String> list) {
    return list[Random().nextInt(list.length)];
  }

  // Helper method to get random age between 18 and 65
  int _getRandomAge() {
    return Random().nextInt(48) + 18; // 18 to 65
  }

  // Helper method to get random year between 2010 and 2024
  int _getRandomVehicleYear() {
    return Random().nextInt(15) + 2010; // 2010 to 2024
  }

  // Helper method to get random member number between 1 and 999
  String _getRandomMemberNumber() {
    return (Random().nextInt(999) + 1).toString().padLeft(3, '0');
  }

  // Helper method to get random plate number
  String _getRandomPlateNumber() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final random = Random();

    var plate = '';
    // Add 3 random letters
    for (var i = 0; i < 3; i++) {
      plate += letters[random.nextInt(letters.length)];
    }
    // Add 3 random numbers
    for (var i = 0; i < 3; i++) {
      plate += numbers[random.nextInt(numbers.length)];
    }

    return plate;
  }

  // Helper method to get random phone number
  String _getRandomPhoneNumber() {
    const numbers = '0123456789';
    final random = Random();

    var phone = '09';
    // Add 9 random numbers
    for (var i = 0; i < 9; i++) {
      phone += numbers[random.nextInt(numbers.length)];
    }

    return phone;
  }

  // Helper method to get random date of birth (18-65 years old)
  DateTime _getRandomDateOfBirth() {
    final random = Random();
    final currentYear = DateTime.now().year;
    final year = currentYear - random.nextInt(48) - 18; // 18 to 65 years old
    final month = random.nextInt(12) + 1;
    final day = random.nextInt(28) + 1; // Using 28 to avoid invalid dates
    return DateTime(year, month, day);
  }

  // Helper method to get random license expiration date (1-5 years from now)
  DateTime _getRandomLicenseExpiration() {
    final random = Random();
    final currentYear = DateTime.now().year;
    final year = currentYear + random.nextInt(5) + 1; // 1 to 5 years from now
    final month = random.nextInt(12) + 1;
    final day = random.nextInt(28) + 1;
    return DateTime(year, month, day);
  }

  // Helper method to convert color name to Color object
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'silver':
        return Colors.grey.shade300;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Helper method to create a random test user directly
  Future<void> _createRandomTestUser(String selectedMake) async {
    try {
      // Generate random data
      final randomFirstName = _getRandomItem(_testFirstNames);
      final randomLastName = _getRandomItem(_testLastNames);
      final randomMiddleName = _getRandomItem(_testMiddleNames);
      final randomBirthplace = _getRandomItem(_testBirthplaces);
      final randomBloodType = _getRandomItem(_testBloodTypes);
      final randomCivilStatus = _getRandomItem(_testCivilStatus);
      final randomReligion = _getRandomItem(_testReligions);
      final randomVehicleColor = _getRandomItem(_testVehicleColors);
      final randomVehicleType = _getRandomItem(_testVehicleTypes);
      final randomAge = _getRandomAge();
      final randomMemberNumber = _getRandomMemberNumber();
      final randomPlateNumber = _getRandomPlateNumber();
      final randomPhoneNumber = _getRandomPhoneNumber();
      final randomDateOfBirth = _getRandomDateOfBirth();
      final randomLicenseExpiration = _getRandomLicenseExpiration();
      final randomVehicleYear = _getRandomVehicleYear();
      final randomEmail =
          '${randomFirstName.toLowerCase()}.${randomLastName.toLowerCase()}${_generateRandomString(3)}@gmail.com';

      // Create test user in PocketBase
      print('Creating PocketBase test user with email: $randomEmail');
      final pocketBaseService = PocketBaseService();

      final userRecord = await pocketBaseService.createUser(
        email: randomEmail,
        password: '12345678',
        firstName: randomFirstName,
        lastName: randomLastName,
        additionalData: {
          'passwordConfirm': '12345678',
        },
      );

      final uid = userRecord.id;
      print('PocketBase test user created successfully with ID: $uid');

      // Update user data in PocketBase
      print('Updating PocketBase test user data with ID: $uid');
      final userData = {
        'age': randomAge,
        'birthplace': randomDateOfBirth.toIso8601String(), // Schema has birthplace as date field (birthdate)
        'bloodType': randomBloodType,
        'civilStatus': randomCivilStatus,
        'contactNumber': randomPhoneNumber,
        'driversLicenseExpirationDate': randomLicenseExpiration.toIso8601String(),
        'driversLicenseNumber': _generateRandomString(12),
        'driversLicenseRestrictionCode': (Random().nextInt(9) + 1).toString(),
        'email': randomEmail,
        'emergencyContactName': '${_getRandomItem(_testFirstNames)} ${_getRandomItem(_testLastNames)}',
        'emergencyContactNumber': _getRandomPhoneNumber(),
        'firstName': randomFirstName,
        'gender': Random().nextBool() ? 'Male' : 'Female',
        'id': uid,
        'isActive': true,
        'isAdmin': false, // Regular members for payment testing
        'lastName': randomLastName,
        'memberNumber': randomMemberNumber,
        'membership_type': 3, // Regular member
        'middleName': randomMiddleName,
        'nationality': 'Filipino',
        'profileImage': '',
        'religion': randomReligion,
        'spouseContactNumber': randomCivilStatus == 'Married' ? _getRandomPhoneNumber() : '',
        'spouseName': randomCivilStatus == 'Married'
            ? '${_getRandomItem(_testFirstNames)} ${_getRandomItem(_testLastNames)}'
            : '',
      };

      // Update test user in PocketBase
      await pocketBaseService.updateUser(uid, userData);
      print('PocketBase test user updated successfully');

      // Create vehicle record for test user
      try {
        await pocketBaseService.createVehicle(
          userId: uid,
          color: randomVehicleColor,
          make: selectedMake,
          model: _vehicleModels.isNotEmpty ? _vehicleModels.first : 'Corolla',
          plateNumber: randomPlateNumber,
          type: randomVehicleType,
          year: randomVehicleYear,
        );
        print('Vehicle record created for test user');
      } catch (e) {
        print('Error creating vehicle for test user: $e');
        // Continue even if vehicle creation fails
      }

      // Create random payment records for the last 6 months
      await _createRandomPaymentRecords(uid);

      print('Test user creation completed successfully for ID: $uid');
    } catch (e) {
      // Handle PocketBase errors for test users
      var errorMessage = 'Error creating test user: ';
      if (e.toString().contains('email') && e.toString().contains('already')) {
        errorMessage += 'An account already exists for that email.';
      } else if (e.toString().contains('password')) {
        errorMessage += 'The password provided is too weak.';
      } else if (e.toString().contains('email')) {
        errorMessage += 'The email address is invalid.';
      } else {
        errorMessage += e.toString();
      }

      print('PocketBase error for test user: $e');
      // For test users, we might want to continue with a different email or handle differently
    }
  }

  // Helper method to create random payment records
  Future<void> _createRandomPaymentRecords(String userId) async {
    try {
      final now = DateTime.now();
      final random = Random();
      final pocketBaseService = PocketBaseService();

      // Create payment records for the last 6 months
      for (var i = 0; i < 6; i++) {
        final date = DateTime(now.year, now.month - i);

        // 70% chance of being paid, 30% chance of being unpaid
        final isPaid = random.nextDouble() < 0.7;

        await pocketBaseService.createOrUpdateMonthlyDues(
          userId: userId,
          dueForMonth: date,
          amount: 100,
          paymentDate: isPaid ? DateTime.now() : null,
        );
      }
    } catch (e) {
      print('Error creating payment records: $e');
    }
  }

  // Test data arrays for auto-fill
  final List<String> _testFirstNames = [
    'John',
    'Maria',
    'Carlos',
    'Ana',
    'Michael',
    'Sofia',
    'David',
    'Isabella',
    'James',
    'Camila',
    'Robert',
    'Valentina',
    'William',
    'Gabriela',
    'Richard',
    'Lucia',
    'Joseph',
    'Emma',
    'Thomas',
    'Olivia',
    'Christopher',
    'Ava',
    'Charles',
    'Mia',
    'Daniel',
    'Ella',
    'Matthew',
    'Grace',
    'Anthony',
    'Chloe',
  ];

  final List<String> _testLastNames = [
    'Santos',
    'Garcia',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
    'Perez',
    'Torres',
    'Ramirez',
    'Cruz',
    'Morales',
    'Reyes',
    'Flores',
    'Rivera',
    'Gomez',
    'Diaz',
    'Reyes',
    'Torres',
    'Jimenez',
    'Moreno',
    'Romero',
    'Alvarez',
    'Mendoza',
    'Castillo',
    'Ortiz',
    'Silva',
    'Vargas',
    'Castro',
    'Fernandez',
  ];

  final List<String> _testMiddleNames = [
    'Antonio',
    'Isabella',
    'Miguel',
    'Carmen',
    'Jose',
    'Elena',
    'Francisco',
    'Rosa',
    'Manuel',
    'Teresa',
    'Pedro',
    'Ana',
    'Luis',
    'Maria',
    'Carlos',
    'Josefa',
    'Juan',
    'Dolores',
    'Rafael',
    'Concepcion',
    'Diego',
    'Mercedes',
    'Fernando',
    'Consuelo',
    'Alberto',
    'Guadalupe',
    'Ricardo',
    'Patricia',
    'Eduardo',
    'Monica',
  ];

  final List<String> _testBirthplaces = [
    'Manila',
    'Quezon City',
    'Caloocan',
    'Las Pinas',
    'Makati',
    'Malabon',
    'Mandaluyong',
    'Marikina',
    'Muntinlupa',
    'Navotas',
    'Paranaque',
    'Pasay',
    'Pasig',
    'San Juan',
    'Taguig',
    'Valenzuela',
    'Pateros',
    'Antipolo',
    'Bacoor',
    'Cabuyao',
    'Cainta',
    'Calamba',
    'Dasmarinas',
    'Imus',
    'Laguna',
    'Muntinlupa',
    'San Pedro',
    'Santa Rosa',
    'Taytay',
    'Trece Martires',
  ];

  final List<String> _testBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _testCivilStatus = ['Single', 'Married', 'Widowed', 'Separated', 'Divorced', 'Annulled'];
  final List<String> _testReligions = [
    'Catholic',
    'Protestant',
    'Islam',
    'Buddhism',
    'Hinduism',
    'Atheist',
    'Agnostic',
    'Other',
  ];
  final List<String> _testVehicleColors = [
    'White',
    'Black',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
  ];
  final List<String> _testVehicleTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Coupe',
    'Convertible',
    'Wagon',
    'Van',
    'Truck',
    'Motorcycle',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ExpansionTile(
          title: Text(
            'Test/Developer Tools',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_vehicleMakes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle makes not loaded yet!')),
                  );
                  return;
                }
                final selectedMake = _vehicleMakes.contains('Toyota') ? 'Toyota' : _vehicleMakes.first;
                await _onVehicleMakeChanged(selectedMake);

                // Generate random data
                final randomFirstName = _getRandomItem(_testFirstNames);
                final randomLastName = _getRandomItem(_testLastNames);
                final randomMiddleName = _getRandomItem(_testMiddleNames);
                final randomBirthplace = _getRandomItem(_testBirthplaces);
                final randomBloodType = _getRandomItem(_testBloodTypes);
                final randomCivilStatus = _getRandomItem(_testCivilStatus);
                final randomReligion = _getRandomItem(_testReligions);
                final randomVehicleColor = _getRandomItem(_testVehicleColors);
                final randomVehicleType = _getRandomItem(_testVehicleTypes);
                final randomAge = _getRandomAge();
                final randomMemberNumber = _getRandomMemberNumber();
                final randomPlateNumber = _getRandomPlateNumber();
                final randomPhoneNumber = _getRandomPhoneNumber();
                final randomDateOfBirth = _getRandomDateOfBirth();
                final randomLicenseExpiration = _getRandomLicenseExpiration();
                final randomVehicleYear = _getRandomVehicleYear();

                setState(() {
                  // Personal Information (Required)
                  _newFirstNameController.text = randomFirstName;
                  _newLastNameController.text = randomLastName;
                  _middleNameController.text = randomMiddleName;
                  _newEmailController.text =
                      '${randomFirstName.toLowerCase()}.${randomLastName.toLowerCase()}${_generateRandomString(3)}@gmail.com';
                  _newPasswordController.text = 'TestPass123!'; // Strong password (min 8 chars)

                  // Age and Birth Info
                  _ageController.text = randomAge.toString();
                  _birthplaceController.text = randomBirthplace;
                  _selectedDateOfBirth = randomDateOfBirth;
                  _dateOfBirthController.text =
                      '${randomDateOfBirth.day}/${randomDateOfBirth.month}/${randomDateOfBirth.year}';

                  // Blood Type and Civil Status
                  _bloodTypeController.text = randomBloodType;
                  _selectedBloodType = randomBloodType;
                  _civilStatusController.text = randomCivilStatus;
                  _selectedCivilStatus = randomCivilStatus;

                  // Contact Information (10 digits for Philippine mobile)
                  _contactNumberController.text = randomPhoneNumber.substring(2); // Remove '09' prefix

                  // Emergency Contact
                  _emergencyContactNameController.text =
                      '${_getRandomItem(_testFirstNames)} ${_getRandomItem(_testLastNames)}';
                  _emergencyContactNumberController.text = _getRandomPhoneNumber().substring(2);

                  // Nationality and Religion
                  _nationalityController.text = 'Filipino';
                  _religionController.text = randomReligion;

                  // Spouse Information (only if married)
                  _spouseContactNumberController.text =
                      randomCivilStatus == 'Married' ? _getRandomPhoneNumber().substring(2) : '';
                  _spouseNameController.text = randomCivilStatus == 'Married'
                      ? '${_getRandomItem(_testFirstNames)} ${_getRandomItem(_testLastNames)}'
                      : '';

                  // Driver's License
                  _driversLicenseNumberController.text = _generateRandomString(12).toUpperCase();
                  _selectedLicenseExpirationDate = randomLicenseExpiration;
                  _driversLicenseExpirationDateController.text =
                      '${randomLicenseExpiration.day}/${randomLicenseExpiration.month}/${randomLicenseExpiration.year}';
                  _driversLicenseRestrictionCodeController.text = '${Random().nextInt(9) + 1}';

                  // Account & Membership
                  _isActive = true;
                  _isAdmin = false; // Default to non-admin for test users
                  _memberNumberController.text = randomMemberNumber;
                  _membershipTypeController.text = '3'; // Member
                  _selectedMembershipType = '3';

                  // Profile Image
                  _profileImageController.text = '';

                  // Vehicle Details
                  _vehicleColorController.text = randomVehicleColor.toLowerCase();
                  _selectedVehicleColor = _getColorFromName(randomVehicleColor);
                  _vehicleMakeController.text = selectedMake;
                  _vehicleModelController.text = _vehicleModels.isNotEmpty ? _vehicleModels.first : 'Corolla';
                  _selectedVehicleModel = _vehicleModels.isNotEmpty ? _vehicleModels.first : null;
                  _vehiclePlateNumberController.text = randomPlateNumber;
                  _selectedVehicleType = randomVehicleType;
                  _vehicleTypeController.text = randomVehicleType;
                  _selectedVehicleYear = randomVehicleYear;
                  _vehiclePhotosController.text = '';
                  _vehiclePrimaryPhotoController.text = '';
                });
              },
              child: const Text('Test (Auto-fill All Fields)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_vehicleMakes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle makes not loaded yet!')),
                  );
                  return;
                }

                // Show confirmation dialog
                final shouldProceed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Generate Multiple Test Users',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'This will create 10 test users with random data. Continue?',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Generate',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldProceed != true) return;

                final selectedMake = _vehicleMakes.contains('Toyota') ? 'Toyota' : _vehicleMakes.first;
                await _onVehicleMakeChanged(selectedMake);

                // Generate 10 test users
                for (var i = 0; i < 10; i++) {
                  await _createRandomTestUser(selectedMake);
                  // Small delay between creations
                  await Future.delayed(const Duration(milliseconds: 500));
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully created 10 test users!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate 10 Test Users'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Show confirmation dialog
                final shouldProceed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Clear Test Users',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'This will delete all users with membership_type = 3 (regular members). This action cannot be undone. Continue?',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(
                          'Delete All',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldProceed != true) return;

                try {
                  final pocketBaseService = PocketBaseService();

                  // Get all users with membership_type = 3
                  final pocketBaseUsers = await pocketBaseService.getAllUsers();
                  final testUsers = pocketBaseUsers.where((user) => user.data['membership_type'] == 3).toList();

                  var deletedCount = 0;
                  for (final user in testUsers) {
                    // Get and delete associated monthly dues records
                    final monthlyDues = await pocketBaseService.getMonthlyDuesForUser(user.id);
                    for (final dues in monthlyDues) {
                      await pocketBaseService.deleteMonthlyDues(dues.id);
                    }

                    // Delete the user document
                    await pocketBaseService.pb.collection('users').delete(user.id);

                    deletedCount++;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully deleted $deletedCount test users!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting test users: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All Test Users'),
            ),
            const SizedBox(height: 20),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: Border.all(color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newFirstNameController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _newLastNameController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _middleNameController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Middle Name',
                  hintText: 'Enter your middle name (optional)',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newEmailController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter age (1-120)',
                        suffixText: 'years',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final age = int.tryParse(value);
                          if (age != null && (age < 1 || age > 120)) {
                            _ageController.text = value.substring(0, value.length - 1);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _birthplaceController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Birthplace',
                        hintText: 'Enter your birthplace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      style: _buildDropdownTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Blood Type',
                        hintText: 'Blood type',
                      ),
                      items: [
                        DropdownMenuItem(value: 'A+', child: Text('A+', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'A-', child: Text('A-', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'B+', child: Text('B+', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'B-', child: Text('B-', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'AB-', child: Text('AB-', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'O+', child: Text('O+', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'O-', child: Text('O-', style: TextStyle(fontSize: 14.sp))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value;
                          _bloodTypeController.text = value ?? '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCivilStatus,
                      style: _buildDropdownTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Civil Status',
                        hintText: 'Civil status',
                      ),
                      items: [
                        DropdownMenuItem(value: 'Single', child: Text('Single', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'Married', child: Text('Married', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'Widowed', child: Text('Widowed', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(
                          value: 'Separated',
                          child: Text('Separated', style: TextStyle(fontSize: 14.sp)),
                        ),
                        DropdownMenuItem(value: 'Divorced', child: Text('Divorced', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: 'Annulled', child: Text('Annulled', style: TextStyle(fontSize: 14.sp))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCivilStatus = value;
                          _civilStatusController.text = value ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactNumberController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Contact Number',
                  hintText: '9XX XXX XXXX',
                  prefixText: '+63 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDateOfBirth != null
                          ? 'Date of Birth: ${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select Date of Birth',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateOfBirth ?? DateTime(now.year - 18),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(now.year),
                        helpText: 'Select Date of Birth',
                        fieldLabelText: 'Date of Birth',
                        fieldHintText: 'Date',
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateOfBirth = picked;
                          _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactNameController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Emergency Contact Name',
                        hintText: 'Name',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactNumberController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Number',
                        hintText: '9XX XXX XXXX',
                        prefixText: '+63 ',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nationalityController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Nationality',
                        hintText: 'Enter your nationality',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _religionController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Religion',
                        hintText: 'Enter your religion',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _spouseNameController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Spouse Name',
                        hintText: 'Enter spouse name (if applicable)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _spouseContactNumberController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Spouse Contact Number',
                        hintText: '9XX XXX XXXX',
                        prefixText: '+63 ',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              // Profile Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Image',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      shadows: isDark
                          ? [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2, offset: const Offset(0, 1))]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        child: _selectedProfileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedProfileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      // Upload Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isUploadingImage ? null : _pickAndUploadProfileImage,
                              icon: _isUploadingImage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt),
                              label: Text(_isUploadingImage ? 'Uploading...' : 'Upload Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedProfileImage != null
                                  ? 'Image selected: ${_selectedProfileImage!.path.split('/').last}'
                                  : 'No image selected',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fallback URL field (optional)
                  TextField(
                    controller: _profileImageController,
                    style: _buildTextStyle(),
                    decoration: _buildInputDecoration(
                      labelText: 'Profile Image URL (Optional)',
                      hintText: 'Or enter a URL if you prefer',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: Border.all(color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Driver's License",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _driversLicenseNumberController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Driver License Number',
                  hintText: 'Enter your driver license number',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedLicenseExpirationDate != null
                          ? 'License Expiration: ${_selectedLicenseExpirationDate!.day}/${_selectedLicenseExpirationDate!.month}/${_selectedLicenseExpirationDate!.year}'
                          : 'Select License Expiration Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedLicenseExpirationDate ?? now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 10),
                        helpText: 'Select License Expiration Date',
                        fieldLabelText: 'License Expiration Date',
                        fieldHintText: 'Date',
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedLicenseExpirationDate = picked;
                          _driversLicenseExpirationDateController.text = '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _driversLicenseRestrictionCodeController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Driver License Restriction Code',
                  hintText: 'Enter restriction code (if any)',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: Border.all(color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account & Membership',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberNumberController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Member #',
                        hintText: 'Enter member number',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMembershipType,
                      isExpanded: true,
                      style: _buildDropdownTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Membership Type',
                        hintText: 'Select membership type',
                      ),
                      items: [
                        DropdownMenuItem(value: '2', child: Text('Admin', style: TextStyle(fontSize: 14.sp))),
                        DropdownMenuItem(value: '3', child: Text('Member', style: TextStyle(fontSize: 14.sp))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMembershipType = value;
                          _membershipTypeController.text = value ?? '3';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: Border.all(color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _vehicleColorController,
                      style: _buildTextStyle(),
                      decoration: _buildInputDecoration(
                        labelText: 'Vehicle Color (Hex)',
                        hintText: 'FF0000',
                        prefixText: '#',
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          try {
                            final color = Color(int.parse('FF${value.toUpperCase()}', radix: 16));
                            setState(() {
                              _selectedVehicleColor = color;
                            });
                          } catch (e) {
                            // Invalid hex value, ignore
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedVehicleColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // Expanded(
                  //   child: TextField(
                  //     controller: _vehicleTypeController,
                  //     style: _buildTextStyle(),
                  //     decoration: _buildInputDecoration(
                  //       labelText: 'Vehicle Type',
                  //       hintText: 'e.g., Sedan, SUV, Truck',
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _vehicleMakeController,
                focusNode: _vehicleMakeFocusNode,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Search Vehicle Make',
                  hintText: 'Type to search (e.g., Toyota, Honda, Ford)',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _onVehicleMakeTextChanged,
              ),
              if (_showSuggestions && _vehicleMakes.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _getFilteredVehicleMakes().length,
                    itemBuilder: (context, index) {
                      final make = _getFilteredVehicleMakes()[index];
                      return ListTile(
                        title: Text(
                          make,
                          style: _buildDropdownTextStyle(),
                        ),
                        onTap: () {
                          _onVehicleMakeChanged(make);
                          _vehicleMakeFocusNode.unfocus();
                          setState(() {
                            _showSuggestions = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              if (_selectedVehicleMake != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('Selected Make: $_selectedVehicleMake'),
                    ),
                    TextButton(
                      onPressed: () {
                        _vehicleMakeController.clear();
                        _onVehicleMakeChanged(null);
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleModel,
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleModel = value;
                      _vehicleModelController.text = value ?? '';
                    });
                  },
                  style: _buildDropdownTextStyle(),
                  decoration: _buildInputDecoration(
                    labelText: 'Vehicle Model',
                    hintText: 'Select vehicle model',
                  ),
                  items: _vehicleModels.map((model) {
                    return DropdownMenuItem(
                      value: model,
                      child: Text(
                        model,
                        style: _buildDropdownTextStyle(),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showManualModelEntry = true;
                    });
                  },
                  child: const Text('Or enter custom model'),
                ),
              ],
              if (_showManualModelEntry)
                TextField(
                  controller: _vehicleModelController,
                  style: _buildTextStyle(),
                  decoration: _buildInputDecoration(
                    labelText: 'Enter Custom Vehicle Model',
                    hintText: 'Type your custom vehicle model',
                    prefixIcon: const Icon(Icons.edit),
                  ),
                ),
              // const SizedBox(height: 0),
              TextField(
                controller: _vehiclePlateNumberController,
                style: _buildTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Vehicle Plate Number',
                  hintText: 'Enter vehicle plate number',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                style: _buildDropdownTextStyle(),
                decoration: _buildInputDecoration(
                  labelText: 'Vehicle Type',
                  hintText: 'Select vehicle type',
                ),
                items: _testVehicleTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: _buildDropdownTextStyle(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                    _vehicleTypeController.text = value ?? 'Sedan';
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedVehicleYear != null ? 'Vehicle Year: ${_selectedVehicleYear!}' : 'Select Vehicle Year',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(now.year),
                        firstDate: DateTime(1980),
                        lastDate: DateTime(now.year + 1),
                        helpText: 'Select Vehicle Year',
                        fieldLabelText: 'Vehicle Year',
                        fieldHintText: 'Year',
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedVehicleYear = picked.year;
                        });
                      }
                    },
                    child: const Text('Pick Year'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Car Images Upload Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: Border.all(color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car Images',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
              const SizedBox(height: 20),

              // Main Car Image
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary Car Image',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withOpacity(0.87),
                    ),
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
                            : const Icon(Icons.directions_car, size: 40, color: Colors.grey),
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
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt),
                              label: Text(_isUploadingCarImage ? 'Uploading...' : 'Upload Main Image'),
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
                                fontSize: 12.sp,
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
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.87),
                ),
              ),
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
                      selectedImage = _selectedCarImage4;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Image or placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: selectedImage != null
                              ? Image.file(
                                  selectedImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : ColoredBox(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.directions_car, size: 32, color: Colors.grey),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Car $imageNumber',
                                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        // Image number overlay
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$imageNumber',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreatingUser ? null : _createUser,
            child: _isCreatingUser ? const CircularProgressIndicator(color: Colors.white) : const Text('Create User'),
          ),
        ),
        if (_createUserMessage != null) ...[
          const SizedBox(height: 20),
          Text(
            _createUserMessage!,
            style: TextStyle(
              color: _createUserMessage!.startsWith('Error') ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
