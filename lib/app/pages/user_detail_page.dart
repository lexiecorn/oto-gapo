import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otogapo/app/pages/user_list_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onUserDeleted;

  const UserDetailPage({
    Key? key,
    required this.userData,
    this.onUserDeleted,
  }) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isEditing = false;
  late Map<String, dynamic> _editedData;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedLicenseExpirationDate;
  Future<String>? _profileImageUrlFuture;

  @override
  void initState() {
    super.initState();
    _editedData = Map<String, dynamic>.from(widget.userData);

    // Initialize the date of birth from the user data
    if (_editedData['dateOfBirth'] != null) {
      final dateValue = _editedData['dateOfBirth'];
      if (dateValue is DateTime) {
        _selectedDateOfBirth = dateValue;
      } else if (dateValue is Timestamp) {
        _selectedDateOfBirth = dateValue.toDate();
      }
    }

    // Initialize the license expiration date from the user data
    if (_editedData['driversLicenseExpirationDate'] != null) {
      final dateValue = _editedData['driversLicenseExpirationDate'];
      if (dateValue is DateTime) {
        _selectedLicenseExpirationDate = dateValue;
      } else if (dateValue is Timestamp) {
        _selectedLicenseExpirationDate = dateValue.toDate();
      }
    }

    if (_editedData['profile_image'] != null && _editedData['profile_image'].toString().isNotEmpty) {
      _profileImageUrlFuture = _getDownloadUrlFromGsUri(_editedData['profile_image'].toString());
    }
  }

  Future<String> _getDownloadUrlFromGsUri(String gsUri) async {
    // Re-throwing the error so the FutureBuilder can catch it
    if (gsUri.startsWith('gs://')) {
      return await FirebaseStorage.instance.refFromURL(gsUri).getDownloadURL();
    }
    return gsUri; // It's already an HTTPS URL
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Authentication Error")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "You are not logged in. Please log in again to view user details.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    try {
      // Extract vehicle data (it's stored as an array)
      final vehicles = _editedData['vehicle'] as List<dynamic>? ?? [];
      final firstVehicle = vehicles.isNotEmpty ? vehicles.first as Map<String, dynamic>? : null;

      return WillPopScope(
        onWillPop: () async {
          // Call the callback when user manually goes back
          if (widget.onUserDeleted != null) {
            widget.onUserDeleted!();
          }
          return true;
        },
        child: Scaffold(
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
                  if (_editedData['profile_image'] != null)
                    Center(
                      child: FutureBuilder<String>(
                        future: _profileImageUrlFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircleAvatar(radius: 60, child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.red.shade100,
                              child: Tooltip(
                                message: snapshot.error.toString(),
                                child: const Icon(Icons.error, size: 60, color: Colors.red),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60));
                          }
                          final imageUrl = snapshot.data!;
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(imageUrl),
                          );
                        },
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
                      _buildEditableField('Date of Birth', 'dateOfBirth', isDate: true),
                      _buildEditableField('Birthplace', 'birthplace'),
                      _buildEditableField('Nationality', 'nationality'),
                      _buildEditableField('Religion', 'religion'),
                      _buildEditableField('Civil Status', 'civilStatus'),
                      _buildEditableField('Gender', 'gender',
                          isDropdown: true, dropdownOptions: ['Male', 'Female', 'Other']),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSection(
                    'Contact Information',
                    [
                      _buildEditableField('Contact Number', 'contactNumber'),
                      _buildEditableField('Emergency Contact Name', 'emergencyContactName'),
                      _buildEditableField('Emergency Contact Number', 'emergencyContactNumber'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Membership Information Section
                  _buildSection(
                    'Membership Information',
                    [
                      _buildEditableField('Member Number', 'memberNumber', isNumber: true),
                      _buildEditableField('Membership Type', 'membership_type'),
                      _buildEditableField('Is Active', 'isActive', isBoolean: true),
                      _buildEditableField('Is Admin', 'isAdmin', isBoolean: true),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Driver's License Information Section
                  _buildSection(
                    'Driver\'s License Information',
                    [
                      _buildEditableField('License Number', 'driversLicenseNumber'),
                      _buildEditableField('License Exp. Date', 'driversLicenseExpirationDate', isDate: true),
                      _buildEditableField('License Restriction Code', 'driversLicenseRestrictionCode', isNumber: true),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Spouse Information Section
                  _buildSection(
                    'Spouse Information',
                    [
                      _buildEditableField('Spouse Name', 'spouseName'),
                      _buildEditableField('Spouse Contact Number', 'spouseContactNumber'),
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
                        _buildDetailRow('License Plate', firstVehicle['plateNumber']),
                        _buildDetailRow('Primary Photo', firstVehicle['primaryPhoto']),
                        _buildDetailRow('Photos Count', firstVehicle['photos']?.length ?? 0),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Medical Information Section
                  _buildSection(
                    'Medical Information',
                    [
                      _buildEditableField('Blood Type', 'bloodType'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // System Information Section
                  _buildSection(
                    'System Information',
                    [
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildEditableField(String label, String field,
      {bool isNumber = false,
      bool isBoolean = false,
      bool isDate = false,
      bool isDropdown = false,
      List<String>? dropdownOptions}) {
    try {
      if (_isEditing) {
        if (isDate) {
          // Determine which date variable to use based on the field
          DateTime? selectedDate;
          if (field == 'dateOfBirth') {
            selectedDate = _selectedDateOfBirth;
          } else if (field == 'driversLicenseExpirationDate') {
            selectedDate = _selectedLicenseExpirationDate;
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
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          DateTime initialDate;
                          DateTime firstDate;
                          DateTime lastDate;

                          if (field == 'dateOfBirth') {
                            initialDate = _selectedDateOfBirth ?? DateTime(now.year - 18);
                            firstDate = DateTime(1900);
                            lastDate = DateTime(now.year);
                          } else if (field == 'driversLicenseExpirationDate') {
                            initialDate = _selectedLicenseExpirationDate ?? DateTime(now.year + 1);
                            firstDate = DateTime(now.year);
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
                            initialEntryMode: DatePickerEntryMode.calendar,
                          );
                          if (picked != null) {
                            setState(() {
                              if (field == 'dateOfBirth') {
                                _selectedDateOfBirth = picked;
                              } else if (field == 'driversLicenseExpirationDate') {
                                _selectedLicenseExpirationDate = picked;
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
          final currentValue = _editedData[field]?.toString();
          final validValue = dropdownOptions.contains(currentValue) ? currentValue : null;

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
                    items: dropdownOptions
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            Expanded(
              child: Text(
                'Error loading field',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Update the document in Firestore
        final userId = _editedData['id']?.toString();
        if (userId != null) {
          // Remove the id field before updating (it's not a document field)
          final updateData = Map<String, dynamic>.from(_editedData);
          updateData.remove('id');

          // Convert DateTime to Timestamp for Firestore
          if (updateData['dateOfBirth'] is DateTime) {
            updateData['dateOfBirth'] = Timestamp.fromDate(updateData['dateOfBirth'] as DateTime);
          }
          if (updateData['driversLicenseExpirationDate'] is DateTime) {
            updateData['driversLicenseExpirationDate'] =
                Timestamp.fromDate(updateData['driversLicenseExpirationDate'] as DateTime);
          }

          updateData['updatedAt'] = FieldValue.serverTimestamp();

          await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);

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
          content: Text('Are you sure you want to delete $displayName? This action cannot be undone.'),
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

      // Show loading indicator using overlay
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
      overlay.insert(overlayEntry);

      // Get the user document ID from the userData
      final userId = (_editedData['id'] ?? _editedData['uid'])?.toString();
      print('User ID to delete: $userId'); // Debug log

      if (userId == null || userId.isEmpty) {
        overlayEntry?.remove(); // Remove loading overlay
        _showErrorDialog(context, 'Error: User ID not found');
        return;
      }

      // Delete the user document from Firestore
      print('Deleting user from Firestore...'); // Debug log
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('User deleted from Firestore successfully'); // Debug log

      // Remove loading overlay
      overlayEntry?.remove();
      print('Loading overlay removed'); // Debug log

      // Call the callback if provided
      if (widget.onUserDeleted != null) {
        print('Calling onUserDeleted callback'); // Debug log
        widget.onUserDeleted!();
      }

      // Return a result to indicate successful deletion
      print('Returning result to previous page...'); // Debug log
      Navigator.of(context).pop('deleted');
      print('Result returned successfully'); // Debug log
    } catch (e) {
      print('Error during delete: $e'); // Debug log
      // Remove loading overlay if it exists
      overlayEntry?.remove();
      _showErrorDialog(context, 'Error deleting user: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
    String displayValue = 'Not provided';

    if (value != null) {
      if (value is DateTime) {
        displayValue = '${value.day}/${value.month}/${value.year}';
      } else if (value is Timestamp) {
        final date = value.toDate();
        displayValue = '${date.day}/${date.month}/${date.year}';
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else {
        displayValue = value.toString();
      }
    }

    // Check if this is an image field and has a valid URL
    bool isImageField = label.toLowerCase().contains('photo') ||
        label.toLowerCase().contains('image') ||
        label.toLowerCase().contains('picture');

    bool hasValidUrl = value is String && value.isNotEmpty;

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
                ? FutureBuilder<String>(
                    future: _getDownloadUrlFromGsUri(value),
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
                                return Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
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
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
