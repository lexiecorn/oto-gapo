import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({Key? key}) : super(key: key);

  @override
  State<PaymentManagementPage> createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _selectedMonth = '';
  List<String> _availableMonths = [];
  bool _showOverview = false; // Toggle between single month and overview

  // New variables for user selection and bulk updates
  Map<String, dynamic>? _selectedUser;
  List<String> _selectedMonthsForBulkUpdate = [];
  bool _showUserSelectionDialog = false;
  bool _showBulkUpdateDialog = false;
  Map<String, bool> _cachedMonthStatus = {}; // Cache for month status data

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUsers();
    await _generateAvailableMonths();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUsers() async {
    try {
      final pocketBaseService = PocketBaseService();
      final pocketBaseUsers = await pocketBaseService.getAllUsers();

      final users = <Map<String, dynamic>>[];
      for (final user in pocketBaseUsers) {
        final userData = user.data;
        userData['id'] = user.id;
        users.add(userData);
      }

      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  Future<void> _generateAvailableMonths() async {
    final now = DateTime.now();
    final months = <String>[];

    // Generate months from January of current year to December of next year
    // This covers current year + next year (24 months total)
    for (int year = now.year; year <= now.year + 1; year++) {
      for (int month = 1; month <= 12; month++) {
        final date = DateTime(year, month, 1);
        final monthKey = DateFormat('yyyy_MM').format(date);
        months.add(monthKey);
      }
    }

    setState(() {
      _availableMonths = months;
      _selectedMonth = months.first;
    });
  }

  Future<void> _markPaymentStatus(String userId, String month, bool status) async {
    try {
      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);

      await pocketBaseService.markPaymentStatus(
        userId: userId,
        month: monthDate,
        isPaid: status,
      );

      // Refresh the data
      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status ? 'Payment marked as paid' : 'Payment marked as unpaid'),
          backgroundColor: status ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('Error updating payment status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating payment status: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _getPaymentStatus(String userId, String month) async {
    try {
      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);
      final monthlyDues = await pocketBaseService.getMonthlyDuesForUserAndMonth(userId, monthDate);

      if (monthlyDues != null) {
        return {
          'status': monthlyDues.isPaid,
          'amount': monthlyDues.amount,
          'payment_date': monthlyDues.paymentDate?.toIso8601String(),
          'updated_at': monthlyDues.updated,
        };
      }
      // Return null if payment record doesn't exist (treated as unpaid)
      return null;
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  // New method to get all months with payment status for a user
  Future<Map<String, bool>> _getUserAllMonthsWithStatus(String userId) async {
    final monthStatus = <String, bool>{};

    for (final month in _availableMonths) {
      final paymentData = await _getPaymentStatus(userId, month);
      // If payment record doesn't exist, consider it as unpaid
      monthStatus[month] = (paymentData?['status'] as bool?) ?? false;
    }

    return monthStatus;
  }

  // New method to bulk update payments for a user
  Future<void> _bulkUpdatePayments(String userId, List<String> months, bool status) async {
    try {
      final pocketBaseService = PocketBaseService();

      for (final month in months) {
        final monthDate = DateFormat('yyyy_MM').parse(month);
        await pocketBaseService.markPaymentStatus(
          userId: userId,
          month: monthDate,
          isPaid: status,
        );
      }

      // Refresh the data
      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully updated ${months.length} payment(s) as ${status ? 'paid' : 'unpaid'}'),
          backgroundColor: status ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('Error bulk updating payments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating payments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to check if a month is in the future
  bool _isFutureMonth(String month) {
    final date = DateFormat('yyyy_MM').parse(month);
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, 1));
  }

  // New method to show user selection dialog
  void _showUserSelection() {
    setState(() {
      _showUserSelectionDialog = true;
    });
  }

  // New method to show bulk update dialog
  void _showBulkUpdate() {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _showBulkUpdateDialog = true;
    });
  }

  // Helper method to get profile image download URL
  Future<String?> _getProfileImageUrl(String userId, String? profileImageUri) async {
    if (profileImageUri == null || profileImageUri.isEmpty) return null;

    try {
      if (profileImageUri.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(profileImageUri);
        return await ref.getDownloadURL();
      }
      return profileImageUri;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
        centerTitle: true,
        actions: [
          // User selection button
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: _showUserSelection,
            tooltip: 'Select User for Bulk Update',
          ),
          // Bulk update button
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: _showBulkUpdate,
            tooltip: 'Bulk Update Payments',
          ),
          // Toggle button for overview/single month view
          IconButton(
            icon: Icon(_showOverview ? Icons.view_list : Icons.table_chart),
            onPressed: () {
              setState(() {
                _showOverview = !_showOverview;
              });
            },
            tooltip: _showOverview ? 'Single Month View' : 'Payment Overview',
          ),
        ],
      ),
      body: Stack(
        children: [
          _showOverview ? _buildOverviewView() : _buildSingleMonthView(),
          // User selection dialog
          if (_showUserSelectionDialog) _buildUserSelectionDialog(),
          // Bulk update dialog
          if (_showBulkUpdateDialog) _buildBulkUpdateDialog(),
        ],
      ),
    );
  }

  Widget _buildSingleMonthView() {
    return Column(
      children: [
        // Month Selector
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _availableMonths.map((month) {
                    final date = DateFormat('yyyy_MM').parse(month);
                    final displayText = DateFormat('MMMM yyyy').format(date);
                    return DropdownMenuItem(
                      value: month,
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        // Summary Card
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Members',
                    _users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getPaidCount(),
                    builder: (context, snapshot) {
                      final paidCount = snapshot.data ?? 0;
                      return _buildSummaryItem(
                        'Paid',
                        paidCount.toString(),
                        Icons.check_circle,
                        Colors.green,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getUnpaidCount(),
                    builder: (context, snapshot) {
                      final unpaidCount = snapshot.data ?? 0;
                      return _buildSummaryItem(
                        'Unpaid',
                        unpaidCount.toString(),
                        Icons.cancel,
                        Colors.red,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Users List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserPaymentCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewView() {
    return Column(
      children: [
        // Overview Header
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Overview (Current Year + Next Year)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing payment status for all members from ${DateTime.now().year} to ${DateTime.now().year + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Overview Summary
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'embers',
                    _users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _getOverviewStats(),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? {'totalPaid': 0, 'totalUnpaid': 0};
                      return _buildSummaryItem(
                        'Paid',
                        stats['totalPaid'].toString(),
                        Icons.check_circle,
                        Colors.green,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _getOverviewStats(),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? {'totalPaid': 0, 'totalUnpaid': 0};
                      return _buildSummaryItem(
                        'Unpaid',
                        stats['totalUnpaid'].toString(),
                        Icons.cancel,
                        Colors.red,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getAdvancePaymentCount(),
                    builder: (context, snapshot) {
                      final advanceCount = snapshot.data ?? 0;
                      return _buildSummaryItem(
                        'Advance',
                        advanceCount.toString(),
                        Icons.schedule,
                        Colors.purple,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Overview Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: _buildOverviewTable(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTable() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Member')),
          ..._availableMonths.map((month) {
            final date = DateFormat('yyyy_MM').parse(month);
            final displayText = DateFormat('MMM yy').format(date);
            return DataColumn(label: Text(displayText));
          }).toList(),
          const DataColumn(label: Text('Total')),
        ],
        rows: _users.map((user) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Member #${user['memberNumber'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ..._availableMonths.map((month) {
                return DataCell(
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getPaymentStatus(user['id'] as String, month),
                    builder: (context, snapshot) {
                      final paymentData = snapshot.data;
                      final isPaid = (paymentData?['status'] as bool?) ?? false;

                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          isPaid ? Icons.check : Icons.close,
                          size: 16,
                          color: isPaid ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              DataCell(
                FutureBuilder<int>(
                  future: _getUserTotalPaid(user['id'] as String),
                  builder: (context, snapshot) {
                    final totalPaid = snapshot.data ?? 0;
                    final now = DateTime.now();
                    final monthsUpToCurrent = _availableMonths.where((month) {
                      final date = DateFormat('yyyy_MM').parse(month);
                      return date.isBefore(DateTime(now.year, now.month + 1, 1));
                    }).length;
                    return Text(
                      '$totalPaid/$monthsUpToCurrent',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<Map<String, int>> _getOverviewStats() async {
    int totalPaid = 0;
    int totalUnpaid = 0;
    final now = DateTime.now();

    for (final user in _users) {
      for (final month in _availableMonths) {
        final date = DateFormat('yyyy_MM').parse(month);

        // Only count months up to current month (not future months)
        if (date.isBefore(DateTime(now.year, now.month + 1, 1))) {
          final paymentData = await _getPaymentStatus(user['id'] as String, month);
          if ((paymentData?['status'] as bool?) == true) {
            totalPaid++;
          } else {
            totalUnpaid++;
          }
        }
      }
    }

    return {'totalPaid': totalPaid, 'totalUnpaid': totalUnpaid};
  }

  Future<int> _getUserTotalPaid(String userId) async {
    int count = 0;
    final now = DateTime.now();

    for (final month in _availableMonths) {
      final date = DateFormat('yyyy_MM').parse(month);

      // Only count months up to current month (not future months)
      if (date.isBefore(DateTime(now.year, now.month + 1, 1))) {
        final paymentData = await _getPaymentStatus(userId, month);
        if ((paymentData?['status'] as bool?) == true) {
          count++;
        }
      }
    }
    return count;
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserPaymentCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: FutureBuilder<String?>(
                    future: _getProfileImageUrl(user['id'] as String, user['profile_image'] as String?),
                    builder: (context, snapshot) {
                      final profileImageUrl = snapshot.data;
                      return profileImageUrl == null
                          ? Text(
                              ((user['firstName'] as String?) ?? '')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            )
                          : Image.network(
                              profileImageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Member #${user['memberNumber'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<Map<String, dynamic>?>(
                  future: _getPaymentStatus(user['id'] as String, _selectedMonth),
                  builder: (context, snapshot) {
                    final paymentData = snapshot.data;
                    final isPaid = (paymentData?['status'] as bool?) ?? false;

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'UNPAID',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱100',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Switch(
                              value: isPaid,
                              onChanged: (value) {
                                _markPaymentStatus(user['id'] as String, _selectedMonth, value);
                              },
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUser = user;
                      _showBulkUpdateDialog = true;
                    });
                  },
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Bulk Update', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getPaidCount() async {
    int count = 0;

    for (final user in _users) {
      final paymentData = await _getPaymentStatus(user['id'] as String, _selectedMonth);
      // Only count as paid if payment record exists and status is explicitly true
      if ((paymentData?['status'] as bool?) == true) {
        count++;
      }
    }
    return count;
  }

  Future<int> _getUnpaidCount() async {
    int count = 0;

    for (final user in _users) {
      final paymentData = await _getPaymentStatus(user['id'] as String, _selectedMonth);
      // Count as unpaid if payment record doesn't exist or status is not true
      if ((paymentData?['status'] as bool?) != true) {
        count++;
      }
    }
    return count;
  }

  // User selection dialog
  Widget _buildUserSelectionDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Select User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showUserSelectionDialog = false;
                            _selectedUser = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = _selectedUser?['id'] == user['id'];

                      return ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: FutureBuilder<String?>(
                            future: _getProfileImageUrl(user['id'] as String, user['profile_image'] as String?),
                            builder: (context, snapshot) {
                              final profileImageUrl = snapshot.data;
                              return profileImageUrl == null
                                  ? Text(
                                      ((user['firstName'] as String?) ?? '')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    )
                                  : Image.network(
                                      profileImageUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    );
                            },
                          ),
                        ),
                        title: Text(
                          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Member #${user['memberNumber'] ?? ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : null,
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                            _showUserSelectionDialog = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: ${user['firstName']} ${user['lastName']}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bulk update dialog
  Widget _buildBulkUpdateDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 550),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.update, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Bulk Update Payments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showBulkUpdateDialog = false;
                            _selectedMonthsForBulkUpdate.clear();
                            _cachedMonthStatus.clear(); // Clear cache when dialog closes
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected User: ${_selectedUser?['firstName'] ?? ''} ${_selectedUser?['lastName'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setDialogState) {
                      if (_cachedMonthStatus.isEmpty && _selectedUser != null) {
                        // Load data only once when dialog opens
                        _getUserAllMonthsWithStatus(_selectedUser!['id'] as String).then((monthStatus) {
                          setDialogState(() {
                            _cachedMonthStatus = monthStatus;
                          });
                        });
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allMonths = _cachedMonthStatus.keys.toList()
                        ..sort((a, b) => a.compareTo(b)); // Sort oldest first

                      if (allMonths.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No months available for this user.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: ListView.builder(
                                itemCount: allMonths.length,
                                itemBuilder: (context, index) {
                                  final month = allMonths[index];
                                  final date = DateFormat('yyyy_MM').parse(month);
                                  final displayText = DateFormat('MMMM yyyy').format(date);
                                  final isPaid = _cachedMonthStatus[month] ?? false;
                                  final isSelected = _selectedMonthsForBulkUpdate.contains(month);

                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      listTileTheme: const ListTileThemeData(
                                        dense: true,
                                        minVerticalPadding: 0,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      title: Text(
                                        displayText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isPaid ? 'Paid' : (_isFutureMonth(month) ? 'Future' : 'Unpaid'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isPaid
                                              ? Colors.green
                                              : (_isFutureMonth(month) ? Colors.blue : Colors.red),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedMonthsForBulkUpdate.add(month);
                                          } else {
                                            _selectedMonthsForBulkUpdate.remove(month);
                                          }
                                        });
                                      },
                                      secondary: Icon(
                                        isPaid
                                            ? Icons.check_circle
                                            : (_isFutureMonth(month) ? Icons.schedule : Icons.cancel),
                                        color:
                                            isPaid ? Colors.green : (_isFutureMonth(month) ? Colors.blue : Colors.red),
                                        size: 18,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMonthsForBulkUpdate = List.from(allMonths);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Select All',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMonthsForBulkUpdate.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Clear All',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedMonthsForBulkUpdate.isEmpty
                                        ? null
                                        : () async {
                                            await _bulkUpdatePayments(
                                              _selectedUser!['id'] as String,
                                              _selectedMonthsForBulkUpdate,
                                              true, // Mark as paid
                                            );
                                            setState(() {
                                              _showBulkUpdateDialog = false;
                                              _selectedMonthsForBulkUpdate.clear();
                                              _cachedMonthStatus.clear(); // Clear cache after update
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Mark as Paid',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedMonthsForBulkUpdate.isEmpty
                                        ? null
                                        : () async {
                                            await _bulkUpdatePayments(
                                              _selectedUser!['id'] as String,
                                              _selectedMonthsForBulkUpdate,
                                              false, // Mark as unpaid
                                            );
                                            setState(() {
                                              _showBulkUpdateDialog = false;
                                              _selectedMonthsForBulkUpdate.clear();
                                              _cachedMonthStatus.clear(); // Clear cache after update
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Mark as Unpaid',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> _getAdvancePaymentCount() async {
    int count = 0;
    final now = DateTime.now();

    for (final user in _users) {
      for (final month in _availableMonths) {
        final date = DateFormat('yyyy_MM').parse(month);

        // Only count future months that have been paid
        if (date.isAfter(DateTime(now.year, now.month, 1))) {
          final paymentData = await _getPaymentStatus(user['id'] as String, month);
          if ((paymentData?['status'] as bool?) == true) {
            count++;
          }
        }
      }
    }
    return count;
  }
}
