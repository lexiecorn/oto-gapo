import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CreateUserSection extends StatefulWidget {
  const CreateUserSection({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _fetchVehicleMakes();
  }

  @override
  void dispose() {
    _vehicleMakeController.dispose();
    _vehicleMakeFocusNode.dispose();
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
          'Tesla'
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
        'Tesla'
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
      final ImageSource? source = await showDialog<ImageSource>(
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
      final XFile? pickedFile = await _imagePicker.pickImage(
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
      final ImageSource? source = await showDialog<ImageSource>(
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

      if (source == null) return null;

      // Pick the image
      final XFile? pickedFile = await _imagePicker.pickImage(
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
        break;
      case '1':
        selectedImage = _selectedCarImage1;
        break;
      case '2':
        selectedImage = _selectedCarImage2;
        break;
      case '3':
        selectedImage = _selectedCarImage3;
        break;
      case '4':
        selectedImage = _selectedCarImage4;
        break;
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
          break;
        case '1':
          setState(() {
            _uploadedCarImage1Url = gsUri;
          });
          break;
        case '2':
          setState(() {
            _uploadedCarImage2Url = gsUri;
          });
          break;
        case '3':
          setState(() {
            _uploadedCarImage3Url = gsUri;
          });
          break;
        case '4':
          setState(() {
            _uploadedCarImage4Url = gsUri;
          });
          break;
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
    final vehicleType = _vehicleTypeController.text.trim();
    final vehicleYear = _selectedVehicleYear ?? 0;
    final vehicleMake = _selectedVehicleMake ?? '';
    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      setState(() => _createUserMessage = 'Please fill in all required fields.');
      return;
    }
    setState(() {
      _isCreatingUser = true;
      _createUserMessage = null;
    });
    try {
      // Generate a unique ID for the user instead of using Firebase Auth
      final uid = _generateRandomString(28); // Firebase UIDs are typically 28 characters

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

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "age": age,
        "birthplace": birthplace,
        "bloodType": bloodType,
        "civilStatus": civilStatus,
        "contactNumber": contactNumber,
        "createdAt": FieldValue.serverTimestamp(), // Timestamp when user was created
        "updatedAt": FieldValue.serverTimestamp(), // Timestamp when user was last updated
        "dateOfBirth": dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        "driversLicenseExpirationDate":
            driversLicenseExpirationDate != null ? Timestamp.fromDate(driversLicenseExpirationDate) : null,
        "driversLicenseNumber": driversLicenseNumber,
        "driversLicenseRestrictionCode": driversLicenseRestrictionCode,
        "email": email,
        "emergencyContactName": emergencyContactName,
        "emergencyContactNumber": emergencyContactNumber,
        "firstName": firstName,
        "gender": '', // Add gender field if needed
        "id": uid, // Add the generated ID to the document
        "isActive": isActive,
        "isAdmin": isAdmin,
        "lastName": lastName,
        "memberNumber": memberNumber,
        "membership_type": membershipType,
        "middleName": middleName,
        "nationality": nationality,
        "profile_image": profileImageUrl ?? profileImage, // Use uploaded image URL or fallback to text input
        "religion": religion,
        "spouseContactNumber": spouseContactNumber,
        "spouseName": spouseName,
        "vehicle": [
          {
            "color": vehicleColor,
            "make": vehicleMake,
            "model": vehicleModel,
            "photos": [
              ...vehiclePhotos,
              if (carImage1Url != null) carImage1Url,
              if (carImage2Url != null) carImage2Url,
              if (carImage3Url != null) carImage3Url,
              if (carImage4Url != null) carImage4Url,
            ].where((url) => url.isNotEmpty).toList(),
            "plateNumber": vehiclePlateNumber,
            "primaryPhoto": mainCarImageUrl ?? vehiclePrimaryPhoto,
            "type": vehicleType,
            "year": vehicleYear
          }
        ]
      });
      setState(() {
        _isCreatingUser = false;
        _createUserMessage = 'User record created successfully!';
        _newEmailController.clear();
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
      setState(() {
        _isCreatingUser = false;
        _createUserMessage = 'Error: $e';
      });
    }
  }

  Widget _buildSuggestionsList() {
    final searchText = _vehicleMakeController.text.toLowerCase();
    final filteredMakes = _vehicleMakes.where((make) {
      return make.toLowerCase().contains(searchText);
    }).toList();

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

    // Limit results to first 20 for better performance
    final limitedMakes = filteredMakes.take(20).toList();

    if (limitedMakes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No vehicle makes found',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: limitedMakes.length,
      itemBuilder: (context, index) {
        final make = limitedMakes[index];
        return ListTile(
          title: Text(
            make,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Tap to select',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          leading: const Icon(Icons.directions_car, size: 20),
          onTap: () {
            _vehicleMakeController.text = make;
            _onVehicleMakeChanged(make);
            setState(() {
              _showSuggestions = false;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text('Create New User', style: Theme.of(context).textTheme.titleLarge),
        // const SizedBox(height: 20),
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
            setState(() {
              _newFirstNameController.text = 'alexiestester';
              _newLastNameController.text = 'iglesia';
              _newEmailController.text = 'test${_generateRandomString(2)}@gmail.com';
              _newPasswordController.text = '123456';
              _ageController.text = '33';
              _birthplaceController.text = 'philippines';
              _bloodTypeController.text = 'O+';
              _selectedBloodType = 'O+';
              _civilStatusController.text = 'Single';
              _selectedCivilStatus = 'Single';
              _contactNumberController.text = '09455000923';
              _selectedDateOfBirth = DateTime(1999, 9, 16);
              _dateOfBirthController.text = '16/9/1999';
              _selectedLicenseExpirationDate = DateTime(2026, 7, 12);
              _driversLicenseExpirationDateController.text = '12/7/2026';
              _driversLicenseNumberController.text = '102399328309';
              _driversLicenseRestrictionCodeController.text = '3';
              _emergencyContactNameController.text = '09455000923';
              _emergencyContactNumberController.text = '09455000923';
              _isActive = true;
              _isAdmin = true;
              _memberNumberController.text = '31';
              _membershipTypeController.text = '3';
              _middleNameController.text = 'maguale';
              _nationalityController.text = 'filipino';
              _profileImageController.text =
                  'gs://otogapo-dev.appspot.com/users/TS4E73z29qdpfsyBiBsxnBN10I43/images/profile.png';
              _religionController.text = 'christian';
              _spouseContactNumberController.text = '09455000923';
              _spouseNameController.text = 'charity';
              _vehicleColorController.text = 'white';
              _selectedVehicleColor = Colors.white;
              _vehicleMakeController.text = selectedMake;
              _vehicleModelController.text = _vehicleModels.isNotEmpty ? _vehicleModels.first : 'yaris';
              _selectedVehicleModel = _vehicleModels.isNotEmpty ? _vehicleModels.first : null;
              _vehiclePhotosController.text = '';
              _vehiclePlateNumberController.text = 'gac9396';
              _vehiclePrimaryPhotoController.text = '';
              _vehicleTypeController.text = 'sedan';
              _selectedVehicleYear = 2017;
            });
          },
          child: const Text('Test (Auto-fill All Fields)'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Information', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newFirstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _newLastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        suffixText: 'years',
                        hintText: 'Enter age (1-120)',
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
                      decoration: const InputDecoration(labelText: 'Birthplace', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A+', child: Text('A+')),
                        DropdownMenuItem(value: 'A-', child: Text('A-')),
                        DropdownMenuItem(value: 'B+', child: Text('B+')),
                        DropdownMenuItem(value: 'B-', child: Text('B-')),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                        DropdownMenuItem(value: 'O+', child: Text('O+')),
                        DropdownMenuItem(value: 'O-', child: Text('O-')),
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
                      decoration: const InputDecoration(
                        labelText: 'Civil Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Single', child: Text('Single')),
                        DropdownMenuItem(value: 'Married', child: Text('Married')),
                        DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
                        DropdownMenuItem(value: 'Separated', child: Text('Separated')),
                        DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                        DropdownMenuItem(value: 'Annulled', child: Text('Annulled')),
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
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                  prefixText: '+63 ',
                  hintText: '9XX XXX XXXX',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                buildCounter: (BuildContext context,
                    {required int currentLength, required bool isFocused, required int? maxLength}) {
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
                      style: Theme.of(context).textTheme.bodyLarge,
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
                        initialEntryMode: DatePickerEntryMode.calendar,
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
                      decoration:
                          const InputDecoration(labelText: 'Emergency Contact Name', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact Number',
                        border: OutlineInputBorder(),
                        prefixText: '+63 ',
                        hintText: '9XX XXX XXXX',
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
                      decoration: const InputDecoration(labelText: 'Nationality', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _religionController,
                      decoration: const InputDecoration(labelText: 'Religion', border: OutlineInputBorder()),
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
                      decoration: const InputDecoration(labelText: 'Spouse Name', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _spouseContactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Spouse Contact Number',
                        border: OutlineInputBorder(),
                        prefixText: '+63 ',
                        hintText: '9XX XXX XXXX',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile Image', style: Theme.of(context).textTheme.titleMedium),
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
                                fontSize: 12,
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
                    decoration: const InputDecoration(
                      labelText: 'Profile Image URL (Optional)',
                      border: OutlineInputBorder(),
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
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver\'s License', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextField(
                controller: _driversLicenseNumberController,
                decoration: const InputDecoration(labelText: 'Driver License Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedLicenseExpirationDate != null
                          ? 'License Expiration: ${_selectedLicenseExpirationDate!.day}/${_selectedLicenseExpirationDate!.month}/${_selectedLicenseExpirationDate!.year}'
                          : 'Select License Expiration Date',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedLicenseExpirationDate ?? DateTime(now.year + 1),
                        firstDate: DateTime(now.year),
                        lastDate: DateTime(now.year + 10),
                        helpText: 'Select License Expiration Date',
                        fieldLabelText: 'License Expiration Date',
                        fieldHintText: 'Date',
                        initialEntryMode: DatePickerEntryMode.calendar,
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
                decoration:
                    const InputDecoration(labelText: 'Driver License Restriction Code', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account & Membership', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Is Active',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (bool value) {
                      setState(() {
                        _isActive = value;
                        _isActiveController.text = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Is Admin',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Switch(
                    value: _isAdmin,
                    onChanged: (bool value) {
                      setState(() {
                        _isAdmin = value;
                        _isAdminController.text = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Member #',
                        border: OutlineInputBorder(),
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
                    child: TextField(
                      controller: _membershipTypeController,
                      decoration: const InputDecoration(labelText: 'Membership Type', border: OutlineInputBorder()),
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
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vehicle Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _vehicleColorController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Color (Hex)',
                        border: OutlineInputBorder(),
                        prefixText: '#',
                        hintText: 'FF0000',
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
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: _selectedVehicleColor,
                                onColorChanged: (Color color) {
                                  setState(() {
                                    _selectedVehicleColor = color;
                                    _vehicleColorController.text =
                                        color.value.toRadixString(16).padLeft(8, '0').substring(2);
                                  });
                                },
                                pickerAreaHeightPercent: 0.8,
                                enableAlpha: false,
                                labelTypes: const [],
                                displayThumbColor: true,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Done'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Pick Color'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoadingVehicleMakes)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading vehicle makes...'),
                    ],
                  ),
                ),
              if (_vehicleMakes.isEmpty && !_isLoadingVehicleMakes)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vehicle makes not loaded. Please check your internet connection.',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchVehicleMakes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              if (_message != null && _message!.contains('fallback'))
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchVehicleMakes,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              if (_vehicleMakes.isNotEmpty)
                Text(
                  'Available vehicle makes: ${_vehicleMakes.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  if (_showSuggestions) {
                    setState(() {
                      _showSuggestions = false;
                    });
                    _vehicleMakeFocusNode.unfocus();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _vehicleMakeController,
                      focusNode: _vehicleMakeFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Search Vehicle Make',
                        hintText: 'Type to search (e.g., Toyota, Honda, Ford)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _selectedVehicleMake != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _vehicleMakeController.clear();
                                  _onVehicleMakeChanged(null);
                                  setState(() {
                                    _showSuggestions = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _showSuggestions = value.isNotEmpty;
                        });
                      },
                      onTap: () {
                        setState(() {
                          _showSuggestions = _vehicleMakeController.text.isNotEmpty;
                        });
                      },
                    ),
                    if (_showSuggestions)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildSuggestionsList(),
                      ),
                  ],
                ),
              ),
              if (_selectedVehicleMake != null && _isLoadingVehicleModels)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading vehicle models...'),
                    ],
                  ),
                ),
              if (_selectedVehicleMake != null && _vehicleModels.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleModel,
                  items: [
                    ..._vehicleModels
                        .map((model) => DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            ))
                        .toList(),
                    const DropdownMenuItem(
                      value: 'custom',
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleModel = value;
                      if (value == 'custom') {
                        _showManualModelEntry = true;
                        _vehicleModelController.clear();
                      } else {
                        _showManualModelEntry = false;
                        _vehicleModelController.text = value ?? '';
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Model',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (_showManualModelEntry)
                TextField(
                  controller: _vehicleModelController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Custom Vehicle Model',
                    hintText: 'Type your custom vehicle model',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
              const SizedBox(height: 10),
              // Car Images Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Car Images', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),

                  // Main Car Image
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Primary Car Image',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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

                  // Additional Car Images
                  Text('Additional Car Images (1-4)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  // Grid of additional car images
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
                          break;
                        case 2:
                          selectedImage = _selectedCarImage2;
                          break;
                        case 3:
                          selectedImage = _selectedCarImage3;
                          break;
                        case 4:
                          selectedImage = _selectedCarImage4;
                          break;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Image display
                              selectedImage != null
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
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.directions_car, size: 32, color: Colors.grey),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Car $imageNumber',
                                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              // Image number overlay
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                            break;
                                          case 2:
                                            _selectedCarImage2 = pickedImage;
                                            break;
                                          case 3:
                                            _selectedCarImage3 = pickedImage;
                                            break;
                                          case 4:
                                            _selectedCarImage4 = pickedImage;
                                            break;
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
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _vehiclePlateNumberController,
                decoration: const InputDecoration(labelText: 'Vehicle Plate Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedVehicleYear != null ? 'Vehicle Year: ${_selectedVehicleYear!}' : 'Select Vehicle Year',
                      style: Theme.of(context).textTheme.bodyLarge,
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
                        initialEntryMode: DatePickerEntryMode.calendar,
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
