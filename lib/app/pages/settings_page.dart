// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _sourceDocIdController = TextEditingController(text: 'TS4E73z29qdpfsyBiBsxnBN10I43');
  bool _isLoading = false;
  String? _message;

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
          _message = 'Using fallback vehicle makes (API error: HTTP ${response.statusCode})';
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
        _message = 'Using fallback vehicle makes (Network error: $e)';
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
          _message = 'Error fetching vehicle models: $e';
        });
      }
    }
  }

  Future<void> _duplicateUser() async {
    final customId = _docIdController.text.trim();
    final sourceId = _sourceDocIdController.text.trim();
    if (customId.isEmpty) {
      setState(() => _message = 'Please enter a custom document ID.');
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final sourceDoc = await FirebaseFirestore.instance.collection('users').doc(sourceId).get();
      if (!sourceDoc.exists) {
        setState(() {
          _isLoading = false;
          _message = 'Source document does not exist.';
        });
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(customId).set(sourceDoc.data()!);
      setState(() {
        _isLoading = false;
        _message = 'User duplicated successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
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
    final vehicleType = _vehicleTypeController.text.trim();
    final vehicleYear = _selectedVehicleYear ?? 0;
    final vehicleMake = _selectedVehicleMake ?? '';
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      setState(() => _createUserMessage = 'Please fill in all fields.');
      return;
    }
    setState(() {
      _isCreatingUser = true;
      _createUserMessage = null;
    });
    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "age": age,
        "birthplace": birthplace,
        "bloodType": bloodType,
        "civilStatus": civilStatus,
        "contactNumber": contactNumber,
        "dateOfBirth": dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
        "driversLicenseExpirationDate":
            driversLicenseExpirationDate != null ? Timestamp.fromDate(driversLicenseExpirationDate) : null,
        "driversLicenseNumber": driversLicenseNumber,
        "driversLicenseRestrictionCode": driversLicenseRestrictionCode,
        "emergencyContactName": emergencyContactName,
        "emergencyContactNumber": emergencyContactNumber,
        "firstName": firstName,
        "gender": '', // Add gender field if needed
        "isActive": isActive,
        "isAdmin": isAdmin,
        "lastName": lastName,
        "memberNumber": memberNumber,
        "membership_type": membershipType,
        "middleName": middleName,
        "nationality": nationality,
        "profile_image": profileImage,
        "religion": religion,
        "spouseContactNumber": spouseContactNumber,
        "spouseContactNumber": spouseContactNumber,
        "spouseName": spouseName,
        "vehicle": [
          {
            "color": vehicleColor,
            "make": vehicleMake,
            "model": vehicleModel,
            "photos": vehiclePhotos,
            "plateNumber": vehiclePlateNumber,
            "primaryPhoto": vehiclePrimaryPhoto,
            "type": vehicleType,
            "year": vehicleYear
          }
        ]
      });
      setState(() {
        _isCreatingUser = false;
        _createUserMessage = 'User created successfully!';
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
        _vehiclePhotosController.clear();
        _vehiclePlateNumberController.clear();
        _vehiclePrimaryPhotoController.clear();
        _vehicleTypeController.clear();
        _selectedVehicleYear = null;
        _selectedVehicleMake = null;
      });
    } catch (e) {
      setState(() {
        _isCreatingUser = false;
        _createUserMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create New User', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_vehicleMakes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle makes not loaded yet!')),
                  );
                  return;
                }

                // Set the vehicle make first
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
                  _vehiclePhotosController.text =
                      'https://imageio.forbes.com/specials-images/imageserve/5d35eacaf1176b0008974b54/2020-Chevrolet-Corvette-Stingray/0x0.jpg, https://imageio.forbes.com/specials-images/imageserve/5d37033a95e0230008f64eb2/2020-Aston-Martin-Rapide-E/0x0.jpg';
                  _vehiclePlateNumberController.text = 'gac9396';
                  _vehiclePrimaryPhotoController.text =
                      'https://www.manilarenatacars.com/wp-content/uploads/2019/12/toyota-yaris.jpg';
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
                          // maxLength: 3,
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
                          // maxLength: 10,
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
                          // maxLength: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _profileImageController,
                    decoration: const InputDecoration(labelText: 'Profile Image URL', border: OutlineInputBorder()),
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
                              _driversLicenseExpirationDateController.text =
                                  '${picked.day}/${picked.month}/${picked.year}';
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
                    decoration: const InputDecoration(
                        labelText: 'Driver License Restriction Code', border: OutlineInputBorder()),
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
                      // Close suggestions when clicking outside
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
                  TextField(
                    controller: _vehiclePhotosController,
                    decoration: const InputDecoration(
                        labelText: 'Vehicle Photos (comma separated URLs)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _vehiclePlateNumberController,
                    decoration: const InputDecoration(labelText: 'Vehicle Plate Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _vehiclePrimaryPhotoController,
                    decoration:
                        const InputDecoration(labelText: 'Vehicle Primary Photo URL', border: OutlineInputBorder()),
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
                          _selectedVehicleYear != null
                              ? 'Vehicle Year: ${_selectedVehicleYear!}'
                              : 'Select Vehicle Year',
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
                child:
                    _isCreatingUser ? const CircularProgressIndicator(color: Colors.white) : const Text('Create User'),
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
        ),
      ),
    );
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
}

class VehicleSelector extends StatefulWidget {
  final List<String> makes;
  final void Function(String) onSelected;

  const VehicleSelector({required this.makes, required this.onSelected, Key? key}) : super(key: key);

  @override
  _VehicleSelectorState createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  List<String> _makes = [];
  List<String> _models = [];
  String? _selectedMake;
  String? _selectedModel;
  bool _loadingMakes = true;
  bool _loadingModels = false;

  final TextEditingController _makeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMakes();
  }

  Future<void> fetchMakes() async {
    setState(() => _loadingMakes = true);
    final response = await http.get(Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetAllMakes?format=json'));
    final data = json.decode(response.body);
    final results = data['Results'] as List;
    setState(() {
      _makes = results.map((e) => e['Make_Name'].toString()).toList();
      _loadingMakes = false;
    });
  }

  Future<void> fetchModels(String make) async {
    setState(() {
      _loadingModels = true;
      _models = [];
      _selectedModel = null;
    });
    final response =
        await http.get(Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/$make?format=json'));
    final data = json.decode(response.body);
    final results = data['Results'] as List;
    setState(() {
      _models = results.map((e) => e['Model_Name'].toString()).toSet().toList(); // remove duplicates
      _loadingModels = false;
    });
  }

  void fillTestData() async {
    // Example: Use "Toyota" and its first model as test data
    final testMake = "Toyota";
    setState(() {
      _selectedMake = testMake;
      _makeController.text = testMake;
      _loadingModels = true;
    });
    await fetchModels(testMake);
    if (_models.isNotEmpty) {
      setState(() {
        _selectedModel = _models.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _loadingMakes
            ? CircularProgressIndicator()
            : Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return widget.makes.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (make) {
                  setState(() {
                    _selectedMake = make;
                    _makeController.text = make;
                  });
                  fetchModels(make);
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  _makeController.value = controller.value;
                  return TextField(
                    controller: _makeController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Search Vehicle Make',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
        if (_selectedMake != null)
          _loadingModels
              ? CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: _selectedModel,
                  items: _models
                      .map((model) => DropdownMenuItem(
                            value: model,
                            child: Text(model),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Model',
                    border: OutlineInputBorder(),
                  ),
                ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: fillTestData,
          child: Text('Test (Auto-fill)'),
        ),
        if (_selectedMake != null && _selectedModel != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('Selected: $_selectedMake $_selectedModel'),
          ),
      ],
    );
  }
}
