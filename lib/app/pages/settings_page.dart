// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:otogapo/app/pages/create_user_page.dart';
import 'package:otogapo/app/pages/user_list_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Create New User'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateUserPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('User List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 196, 195),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserListPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 196, 195),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Optionally: Navigate to login or splash page if needed
              },
            ),
          ],
        ),
      ),
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
