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
  bool _isCreatingUser = false;
  String? _createUserMessage;

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
        "age": 33,
        "birthplace": "philippines",
        "bloodType": "O",
        "civilStatus": "male",
        "contactNumber": "09455000923",
        "dateOfBirth": "16 September 1999 at 00:00:00 UTC+8",
        "driversLicenseExpirationDate": "12 July 2026 at 00:00:00 UTC+8",
        "driversLicenseNumber": "1023993282309",
        "driversLicenseRestrictionCode": "3",
        "emergencyContactName": "09455000923",
        "emergencyContactNumber": "09455000923",
        "firstName": "alexies",
        "gender": "male",
        "isActive": true,
        "isAdmin": true,
        "lastName": "iglesia",
        "memberNumber": "31",
        "membership_type": 3,
        "middleName": "maguale",
        "nationality": "filipino",
        "profile_image": "gs://otogapo-dev.appspot.com/users/TS4E73z29qdpfsyBiBsxnBN10I43/images/profile.png",
        "religion": "christian",
        "spouseContactNumber": "09455000923",
        "spouseName": "charity",
        "vehicle": [
          {
            "color": "white",
            "make": "toyota",
            "model": "yaris",
            "photos": [
              "https://imageio.forbes.com/specials-images/imageserve/5d35ecacf117b60008974b54/2020-Chevrolet-Corvette-Stingray/0x0.jpg",
              "https://imageio.forbes.com/specials-images/imageserve/5d37033a95e0230008f64eb2/2020-Aston-Martin-Rapide-E/0x0.jpg"
            ],
            "plateNumber": "gac9396",
            "primaryPhoto": "https://www.manilarentacars.com/wp-content/uploads/2019/12/toyota-yaris.jpg",
            "type": "sedan",
            "year": 2017
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
