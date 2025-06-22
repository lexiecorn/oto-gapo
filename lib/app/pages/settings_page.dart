// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:otogapo/app/pages/admin_page.dart';
import 'package:otogapo/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            // Check if user is Super Admin (1) or Admin (2)
            _isAdmin = userData['membership_type'] == 1 || userData['membership_type'] == 2;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking admin status: $e');
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
              Text('Loading settings...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Account Settings',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account preferences',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Options
            Expanded(
              child: Column(
                children: [
                  // Theme Toggle
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSettingsCard(
                        icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        title: 'Theme',
                        subtitle: themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_isAdmin) ...[
                    _buildSettingsCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Panel',
                      subtitle: 'Access administrative functions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AdminPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSettingsCard(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true && mounted) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final color = title == 'Logout' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
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
