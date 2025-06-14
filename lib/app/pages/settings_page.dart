// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _civilStatusController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _driversLicenseExpirationDateController = TextEditingController();
  final TextEditingController _driversLicenseNumberController = TextEditingController();
  final TextEditingController _driversLicenseRestrictionCodeController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactNumberController = TextEditingController();
  final TextEditingController _isActiveController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _fetchVehicleMakes();
  }

  Future<void> _fetchVehicleMakes() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('app_data').doc('vehicle_make').get();
      final data = doc.data();
      if (data != null && data['data'] is List) {
        setState(() {
          _vehicleMakes = (data['data'] as List<dynamic>).map((e) => e.toString()).toList();
        });
      } else if (data != null && data['data'] is String) {
        // If stored as a comma-separated string
        setState(() {
          _vehicleMakes = (data['data'] as String).split(',').map((e) => e.trim().replaceAll("'", "")).toList();
        });
      } else {
        setState(() {
          _vehicleMakes = [];
          _message = 'No vehicle makes data found';
        });
      }
    } catch (e) {
      setState(() {
        _vehicleMakes = [];
        _message = 'Error fetching vehicle makes: $e';
      });
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
    final dateOfBirth = _dateOfBirthController.text.trim();
    final driversLicenseExpirationDate = _driversLicenseExpirationDateController.text.trim();
    final driversLicenseNumber = _driversLicenseNumberController.text.trim();
    final driversLicenseRestrictionCode = _driversLicenseRestrictionCodeController.text.trim();
    final emergencyContactName = _emergencyContactNameController.text.trim();
    final emergencyContactNumber = _emergencyContactNumberController.text.trim();
    final isActive = _isActiveController.text.trim().toLowerCase() == 'true';
    final isAdmin = _isAdminController.text.trim().toLowerCase() == 'true';
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
    final vehicleModel = _vehicleModelController.text.trim();
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
        "dateOfBirth": dateOfBirth,
        "driversLicenseExpirationDate": driversLicenseExpirationDate,
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
            Text('Duplicate User', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: _sourceDocIdController,
              decoration: const InputDecoration(
                labelText: 'Source User Document ID',
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _docIdController,
              decoration: const InputDecoration(
                labelText: 'Custom Document ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _duplicateUser,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Duplicate User'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('Error') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const Divider(height: 40),
            Text('Create New User', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _newFirstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newLastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
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
            // Additional fields
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _birthplaceController,
              decoration: const InputDecoration(labelText: 'Birthplace', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bloodTypeController,
              decoration: const InputDecoration(labelText: 'Blood Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _civilStatusController,
              decoration: const InputDecoration(labelText: 'Civil Status', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contactNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _driversLicenseExpirationDateController,
              decoration:
                  const InputDecoration(labelText: 'Driver License Expiration Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _driversLicenseNumberController,
              decoration: const InputDecoration(labelText: 'Driver License Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _driversLicenseRestrictionCodeController,
              decoration:
                  const InputDecoration(labelText: 'Driver License Restriction Code', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emergencyContactNameController,
              decoration: const InputDecoration(labelText: 'Emergency Contact Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emergencyContactNumberController,
              decoration: const InputDecoration(labelText: 'Emergency Contact Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _isActiveController,
              decoration: const InputDecoration(labelText: 'Is Active (true/false)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _isAdminController,
              decoration: const InputDecoration(labelText: 'Is Admin (true/false)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _memberNumberController,
              decoration: const InputDecoration(labelText: 'Member Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _membershipTypeController,
              decoration: const InputDecoration(labelText: 'Membership Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _middleNameController,
              decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nationalityController,
              decoration: const InputDecoration(labelText: 'Nationality', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _profileImageController,
              decoration: const InputDecoration(labelText: 'Profile Image URL', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _religionController,
              decoration: const InputDecoration(labelText: 'Religion', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _spouseContactNumberController,
              decoration: const InputDecoration(labelText: 'Spouse Contact Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _spouseNameController,
              decoration: const InputDecoration(labelText: 'Spouse Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            // Vehicle fields
            Text('Vehicle Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _vehicleColorController,
              decoration: const InputDecoration(labelText: 'Vehicle Color', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedVehicleMake,
              items: _vehicleMakes
                  .map((make) => DropdownMenuItem(
                        value: make,
                        child: Text(make),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleMake = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Vehicle Make',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _vehicleModelController,
              decoration: const InputDecoration(labelText: 'Vehicle Model', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(labelText: 'Vehicle Primary Photo URL', border: OutlineInputBorder()),
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
                    _selectedVehicleYear != null ? 'Vehicle Year: \\${_selectedVehicleYear!}' : 'Select Vehicle Year',
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
}
