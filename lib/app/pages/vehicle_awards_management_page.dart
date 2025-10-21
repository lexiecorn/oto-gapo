import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:otogapo/services/pocketbase_service.dart';

@RoutePage()
class VehicleAwardsManagementPage extends StatefulWidget {
  const VehicleAwardsManagementPage({super.key});

  @override
  State<VehicleAwardsManagementPage> createState() => _VehicleAwardsManagementPageState();
}

class _VehicleAwardsManagementPageState extends State<VehicleAwardsManagementPage> {
  List<VehicleAward> _allAwards = [];
  List<Vehicle> _vehicles = [];
  List<dynamic> _allUsers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedVehicleId;

  late final PocketBaseService _pocketBaseService;

  @override
  void initState() {
    super.initState();
    _pocketBaseService = GetIt.instance<PocketBaseService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all users
      final usersResponse = await _pocketBaseService.pb
          .collection('users')
          .getList(page: 1, perPage: 500, sort: 'firstName');

      _allUsers = usersResponse.items;

      // Load all vehicles
      final vehiclesResponse = await _pocketBaseService.pb
          .collection('vehicles')
          .getList(page: 1, perPage: 500, sort: '-created', expand: 'user');

      _vehicles = vehiclesResponse.items
          .map<Vehicle>((item) => Vehicle.fromJson(item.data as Map<String, Object?>))
          .toList();

      // Load all awards
      final awardsResponse = await _pocketBaseService.pb
          .collection('vehicle_awards')
          .getList(page: 1, perPage: 500, sort: '-event_date', expand: 'vehicle_id,created_by');

      _allAwards = awardsResponse.items
          .map<VehicleAward>((item) => VehicleAward.fromJson(item.data as Map<String, Object?>))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<VehicleAward> get _filteredAwards {
    var filtered = _allAwards;

    if (_selectedVehicleId != null) {
      filtered = filtered.where((award) => award.vehicleId == _selectedVehicleId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (award) =>
                award.awardName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                award.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (award.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (award.placement?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _deleteAward(VehicleAward award) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Delete Award',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${award.awardName}"?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _pocketBaseService.pb.collection('vehicle_awards').delete(award.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Award deleted successfully'), backgroundColor: Colors.green));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete award: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showEditDialog(VehicleAward award) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final blueAccent = isDark ? const Color(0xFF00d4ff) : const Color(0xFF0095c7);

    final awardNameController = TextEditingController(text: award.awardName);
    final eventNameController = TextEditingController(text: award.eventName);
    final categoryController = TextEditingController(text: award.category);
    final placementController = TextEditingController(text: award.placement);
    final descriptionController = TextEditingController(text: award.description);
    DateTime selectedDate = award.eventDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Edit Award',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: awardNameController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Award Name *',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: eventNameController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Event Name *',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Event Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: Icon(Icons.calendar_today, color: blueAccent),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: placementController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Placement',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: colorScheme.onSurface),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: blueAccent),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) return;

    try {
      await _pocketBaseService.pb
          .collection('vehicle_awards')
          .update(
            award.id!,
            body: {
              'award_name': awardNameController.text,
              'event_name': eventNameController.text,
              'event_date': selectedDate.toIso8601String(),
              'category': categoryController.text.isNotEmpty ? categoryController.text : null,
              'placement': placementController.text.isNotEmpty ? placementController.text : null,
              'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
            },
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Award updated successfully'), backgroundColor: Colors.green));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update award: $e'), backgroundColor: Colors.red));
      }
    }
  }

  String _getVehicleName(String vehicleId) {
    try {
      final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);
      return '${vehicle.make} ${vehicle.model} (${vehicle.year})';
    } catch (e) {
      return 'Unknown Vehicle';
    }
  }

  Future<void> _showCreateAwardDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final blueAccent = isDark ? const Color(0xFF00d4ff) : const Color(0xFF0095c7);

    String? selectedUserId;
    String? selectedVehicleId;
    List<Vehicle> userVehicles = [];
    final awardNameController = TextEditingController();
    final eventNameController = TextEditingController();
    final categoryController = TextEditingController();
    final placementController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    String userSearchQuery = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter users based on search
          final filteredUsers = userSearchQuery.isEmpty
              ? _allUsers
              : _allUsers.where((user) {
                  final firstName = (user.data['firstName'] ?? '').toString().toLowerCase();
                  final lastName = (user.data['lastName'] ?? '').toString().toLowerCase();
                  final email = (user.data['email'] ?? '').toString().toLowerCase();
                  final query = userSearchQuery.toLowerCase();
                  return firstName.contains(query) || lastName.contains(query) || email.contains(query);
                }).toList();

          // Update user vehicles when user is selected
          if (selectedUserId != null) {
            userVehicles = _vehicles.where((v) => v.user == selectedUserId).toList();
          }

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              'Create Award',
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User search
                    Text(
                      'Search User',
                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.search, color: blueAccent),
                        filled: true,
                        fillColor: isDark ? colorScheme.background : Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          userSearchQuery = value;
                          selectedUserId = null;
                          selectedVehicleId = null;
                          userVehicles = [];
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // User selection dropdown
                    DropdownButtonFormField<String?>(
                      value: selectedUserId,
                      dropdownColor: colorScheme.surface,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Select User *',
                        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                        filled: true,
                        fillColor: isDark ? colorScheme.background : Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        prefixIcon: Icon(Icons.person, color: blueAccent),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Select a user...')),
                        ...filteredUsers.map((user) {
                          final firstName = user.data['firstName'] ?? '';
                          final lastName = user.data['lastName'] ?? '';
                          final email = user.data['email'] ?? '';
                          return DropdownMenuItem(
                            value: user.id as String,
                            child: Text('$firstName $lastName ($email)'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUserId = value;
                          selectedVehicleId = null;
                          if (value != null) {
                            userVehicles = _vehicles.where((v) => v.user == value).toList();
                          } else {
                            userVehicles = [];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Vehicle selection
                    if (selectedUserId != null) ...[
                      DropdownButtonFormField<String?>(
                        value: selectedVehicleId,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Select Vehicle *',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          filled: true,
                          fillColor: isDark ? colorScheme.background : Colors.grey[100],
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                          prefixIcon: Icon(Icons.directions_car, color: blueAccent),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('Select a vehicle...')),
                          ...userVehicles.map(
                            (vehicle) => DropdownMenuItem(
                              value: vehicle.id,
                              child: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedVehicleId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (userVehicles.isEmpty && selectedUserId != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This user has no vehicles. Please add a vehicle first.',
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Award details
                    if (selectedVehicleId != null) ...[
                      Divider(color: colorScheme.onSurface.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text(
                        'Award Details',
                        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: awardNameController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Award Name *',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: eventNameController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Event Name *',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          selectedDate != null
                              ? 'Event Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Select Event Date *',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        trailing: Icon(Icons.calendar_today, color: blueAccent),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: categoryController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'e.g., Modified, Classic, Best in Show',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: placementController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Placement',
                          hintText: 'e.g., 1st Place, Winner, Champion',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: descriptionController,
                        style: TextStyle(color: colorScheme.onSurface),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blueAccent, width: 2)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed:
                    selectedVehicleId == null ||
                        awardNameController.text.isEmpty ||
                        eventNameController.text.isEmpty ||
                        selectedDate == null
                    ? null
                    : () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: blueAccent),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true || !mounted) return;

    // Validate required fields
    if (selectedVehicleId == null ||
        awardNameController.text.isEmpty ||
        eventNameController.text.isEmpty ||
        selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      await _pocketBaseService.pb
          .collection('vehicle_awards')
          .create(
            body: {
              'vehicle_id': selectedVehicleId,
              'award_name': awardNameController.text,
              'event_name': eventNameController.text,
              'event_date': selectedDate!.toIso8601String(),
              'category': categoryController.text.isNotEmpty ? categoryController.text : null,
              'placement': placementController.text.isNotEmpty ? placementController.text : null,
              'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
              'created_by': _pocketBaseService.pb.authStore.model?.id,
            },
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Award created successfully'), backgroundColor: Colors.green));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create award: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildAwardCard(
    VehicleAward award,
    bool isDark,
    ColorScheme colorScheme,
    Color goldColor,
    Color blueAccent,
    Color purpleAccent,
  ) {
    return Card(
      color: colorScheme.surface,
      elevation: isDark ? 4 : 2,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: goldColor.withOpacity(isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: goldColor.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.emoji_events, color: goldColor, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        award.awardName,
                        style: TextStyle(color: goldColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        award.eventName,
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14.sp),
                      ),
                      Text(
                        _getVehicleName(award.vehicleId),
                        style: TextStyle(color: blueAccent, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withOpacity(0.6)),
                  color: colorScheme.surface,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(award);
                    } else if (value == 'delete') {
                      _deleteAward(award);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: blueAccent),
                          const SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (award.category != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: purpleAccent.withOpacity(isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: purpleAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      award.category!,
                      style: TextStyle(color: purpleAccent, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                if (award.placement != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: blueAccent.withOpacity(isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: blueAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      award.placement!,
                      style: TextStyle(color: blueAccent, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: colorScheme.onSurface.withOpacity(0.6)),
                SizedBox(width: 4.w),
                Text(
                  '${award.eventDate.day}/${award.eventDate.month}/${award.eventDate.year}',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12.sp),
                ),
              ],
            ),
            if (award.description != null && award.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                award.description!,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 12.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Award accent colors (adjusted for light/dark modes)
    final goldColor = isDark ? const Color(0xFFffd700) : const Color(0xFFd4af37);
    final blueAccent = isDark ? const Color(0xFF00d4ff) : const Color(0xFF0095c7);
    final purpleAccent = isDark ? const Color(0xFFa855f7) : const Color(0xFF8b3fc7);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Vehicle Awards Management',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: blueAccent),
            tooltip: 'Create Award',
            onPressed: _showCreateAwardDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(16.sp),
            color: colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search awards...',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: blueAccent),
                    filled: true,
                    fillColor: isDark ? colorScheme.background : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String?>(
                  value: _selectedVehicleId,
                  dropdownColor: colorScheme.surface,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Filter by Vehicle',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    filled: true,
                    fillColor: isDark ? colorScheme.background : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.directions_car, color: blueAccent),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Vehicles')),
                    ..._vehicles.map(
                      (vehicle) => DropdownMenuItem(
                        value: vehicle.id,
                        child: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Stats bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
                bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_allAwards.length}',
                      style: TextStyle(color: goldColor, fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Awards',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12.sp),
                    ),
                  ],
                ),
                Container(width: 1, height: 40.h, color: colorScheme.onSurface.withOpacity(0.2)),
                Column(
                  children: [
                    Text(
                      '${_vehicles.length}',
                      style: TextStyle(color: blueAccent, fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Vehicles',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12.sp),
                    ),
                  ],
                ),
                Container(width: 1, height: 40.h, color: colorScheme.onSurface.withOpacity(0.2)),
                Column(
                  children: [
                    Text(
                      '${_filteredAwards.length}',
                      style: TextStyle(color: purpleAccent, fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Filtered',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Awards list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: blueAccent))
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64.sp, color: colorScheme.error),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading awards',
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _error!,
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(backgroundColor: blueAccent),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredAwards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64.sp, color: colorScheme.onSurface.withOpacity(0.3)),
                        SizedBox(height: 16.h),
                        Text(
                          'No awards found',
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.sp),
                    itemCount: _filteredAwards.length,
                    itemBuilder: (context, index) {
                      final award = _filteredAwards[index];
                      return _buildAwardCard(award, isDark, colorScheme, goldColor, blueAccent, purpleAccent)
                          .animate()
                          .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                          .slideX(begin: 0.2, delay: (50 * index).ms, duration: 300.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
