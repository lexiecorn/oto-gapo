import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otogapo/app/pages/user_list_page.dart';

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

  @override
  void initState() {
    super.initState();
    _editedData = Map<String, dynamic>.from(widget.userData);
  }

  @override
  Widget build(BuildContext context) {
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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(_editedData['profile_image'].toString()),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle image loading error
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
                    _buildEditableField('Date of Birth', 'dateOfBirth'),
                    _buildEditableField('Birthplace', 'birthplace'),
                    _buildEditableField('Nationality', 'nationality'),
                    _buildEditableField('Religion', 'religion'),
                    _buildEditableField('Civil Status', 'civilStatus'),
                    _buildEditableField('Gender', 'gender'),
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
                    _buildEditableField('Member Number', 'memberNumber'),
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
                    _buildEditableField('License Expiration Date', 'driversLicenseExpirationDate'),
                    _buildEditableField('License Restriction Code', 'driversLicenseRestrictionCode'),
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
  }

  Widget _buildEditableField(String label, String field, {bool isNumber = false, bool isBoolean = false}) {
    if (_isEditing) {
      if (isBoolean) {
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
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else {
        displayValue = value.toString();
      }
    }

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
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
