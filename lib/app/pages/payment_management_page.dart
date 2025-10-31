import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

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
  Map<String, bool?> _cachedMonthStatus = {}; // Cache for month status data

  // Loading states for payment toggles
  final Set<String> _loadingPaymentToggles =
      {}; // Track which payment toggles are loading
  bool _isBulkUpdating = false; // Track bulk update loading state

  // Cache for payment status to avoid repeated API calls
  final Map<String, Map<String, dynamic>?> _paymentStatusCache = {};
  final Map<String, DateTime> _cacheTimestamps =
      {}; // Track when cache entries were created

  // Clear all payment status cache
  void _clearAllPaymentStatusCache() {
    _paymentStatusCache.clear();
    _cacheTimestamps.clear();
    print('Payment Management - Cleared all payment status cache');
  }

  // Force cleanup duplicates for a specific user and month
  Future<void> _forceCleanupUserMonth(String userId, String month) async {
    try {
      print('=== FORCE CLEANUP FOR USER/MONTH ===');
      print('User ID: $userId, Month: $month');

      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);

      // This will trigger the duplicate cleanup logic
      final result = await pocketBaseService.getMonthlyDuesForUserAndMonth(
          userId, monthDate,);

      if (result != null) {
        print('Force cleanup - Found record: ${result.id}');
      } else {
        print('Force cleanup - No record found');
      }

      print('=== END FORCE CLEANUP ===');
    } catch (e) {
      print('Error in force cleanup: $e');
    }
  }

  // Debug method to test payment status
  Future<void> _debugPaymentStatus(String userId, String month) async {
    print('=== DEBUG PAYMENT STATUS ===');
    print('User ID: $userId');
    print('Month: $month');

    try {
      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);

      // Test direct database query
      final monthlyDues = await pocketBaseService.getMonthlyDuesForUserAndMonth(
          userId, monthDate,);
      print('Direct query result: ${monthlyDues != null}');

      if (monthlyDues != null) {
        print('Record found:');
        print('  - ID: ${monthlyDues.id}');
        print('  - Amount: ${monthlyDues.amount}');
        print('  - Payment Date: ${monthlyDues.paymentDate}');
        print('  - Payment Date != null: ${monthlyDues.paymentDate != null}');
        print('  - Due For Month: ${monthlyDues.dueForMonth}');

        // Test the status determination logic
        final isPaid = monthlyDues.paymentDate != null;
        print('Is Paid (paymentDate != null): $isPaid');

        // Test the UI status method
        final uiStatus = await _getPaymentStatus(userId, month);
        print('UI Status result: $uiStatus');
        print('UI Status - status field: ${uiStatus?['status']}');
      } else {
        print('No record found in database');
      }
    } catch (e) {
      print('Error in debug: $e');
    }
    print('=== END DEBUG ===');
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUsers();
    await _generateAvailableMonths();
    // Clean up any existing duplicates on initialization
    await _cleanupDuplicates();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _cleanupDuplicates() async {
    try {
      print('Payment Management - Starting duplicate cleanup...');
      final pocketBaseService = PocketBaseService();
      await pocketBaseService.cleanupDuplicateMonthlyDues();
      print('Payment Management - Duplicate cleanup completed');
    } catch (e) {
      print('Error cleaning up duplicates: $e');
      // Don't show error to user as this is a background operation
    }
  }

  Future<void> _manualCleanupDuplicates() async {
    try {
      final pocketBaseService = PocketBaseService();
      await pocketBaseService.cleanupDuplicateMonthlyDues();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duplicate records cleaned up successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error cleaning up duplicates: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning up duplicates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final pocketBaseService = PocketBaseService();
      final pocketBaseUsers = await pocketBaseService.getAllUsers();

      final users = <Map<String, dynamic>>[];
      for (final user in pocketBaseUsers) {
        final userData = user.data;
        userData['id'] = user.id;
        // Only add users that have valid data and are active
        if (userData['isActive'] == true && userData['id'] != null) {
          users.add(userData);
        }
      }

      print(
          'Loaded ${users.length} valid users (filtered out inactive/deleted users)',);
      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _generateAvailableMonths() async {
    final now = DateTime.now();
    final months = <String>[];

    // Generate months from January of current year to December of next year
    // This covers current year + next year (24 months total)
    for (var year = now.year; year <= now.year + 1; year++) {
      for (var month = 1; month <= 12; month++) {
        final date = DateTime(year, month);
        final monthKey = DateFormat('yyyy_MM').format(date);
        months.add(monthKey);
      }
    }

    setState(() {
      _availableMonths = months;
      _selectedMonth = months.first;
    });
  }

  Future<void> _markPaymentStatus(
      String userId, String month, bool status,) async {
    final toggleKey = '${userId}_$month';

    // Add to loading set
    setState(() {
      _loadingPaymentToggles.add(toggleKey);
    });

    try {
      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);

      final result = await pocketBaseService.markPaymentStatus(
        userId: userId,
        month: monthDate,
        isPaid: status,
      );

      // Clear cache for this user/month combination
      final cacheKey = '${userId}_$month';
      _paymentStatusCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);

      // Clear cache for all months for this user to ensure consistency
      _paymentStatusCache
          .removeWhere((key, value) => key.startsWith('${userId}_'));
      _cacheTimestamps
          .removeWhere((key, value) => key.startsWith('${userId}_'));

      print(
          'Payment Management - Cleared cache for user: $userId, month: $month',);
      print(
          'Payment Management - Remaining cache keys: ${_paymentStatusCache.keys.toList()}',);

      // Refresh the data and force UI update
      await _loadUsers();

      // Force a rebuild of the specific user's payment status
      if (mounted) {
        setState(() {
          // This will trigger a rebuild of the payment status widgets
        });
      }

      if (mounted) {
        String message;
        Color backgroundColor;

        if (status) {
          message = result == null
              ? 'Payment record not created'
              : 'Payment marked as paid';
          backgroundColor = result == null ? Colors.red : Colors.green;
        } else {
          message = result == null
              ? 'Payment record deleted'
              : 'Payment marked as unpaid';
          backgroundColor = result == null ? Colors.red : Colors.orange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
      }
    } catch (e) {
      print('Error updating payment status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating payment status: $e')),
        );
      }
    } finally {
      // Remove from loading set
      if (mounted) {
        setState(() {
          _loadingPaymentToggles.remove(toggleKey);
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _getPaymentStatus(
      String userId, String month,) async {
    final cacheKey = '${userId}_$month';

    // Check cache first with expiration (5 minutes)
    if (_paymentStatusCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime).inMinutes < 5) {
        print('_getPaymentStatus - Using cached data for $cacheKey');
        return _paymentStatusCache[cacheKey];
      } else {
        print(
            '_getPaymentStatus - Cache expired for $cacheKey, fetching fresh data',);
        _paymentStatusCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    try {
      final pocketBaseService = PocketBaseService();
      final monthDate = DateFormat('yyyy_MM').parse(month);

      // Get the actual dues record directly
      final monthlyDues = await pocketBaseService.getMonthlyDuesForUserAndMonth(
          userId, monthDate,);

      print(
          '_getPaymentStatus - User: $userId, Month: $month, Record found: ${monthlyDues != null}',);
      if (monthlyDues != null) {
        print('_getPaymentStatus - Record details:');
        print('  - ID: ${monthlyDues.id}');
        print('  - Amount: ${monthlyDues.amount}');
        print('  - Payment Date: ${monthlyDues.paymentDate}');
        print('  - Due For Month: ${monthlyDues.dueForMonth}');
        print('  - Notes: ${monthlyDues.notes}');
        print(
            '  - Is Paid (paymentDate != null): ${monthlyDues.paymentDate != null}',);
      }

      Map<String, dynamic>? result;

      if (monthlyDues == null) {
        // No record exists - check if user was a member during this month
        final userRecord = await pocketBaseService.getUser(userId);
        if (userRecord == null) {
          result = {
            'status': null,
            'amount': 0,
            'payment_date': null,
            'updated_at': null,
          };
        } else {
          final joinedDateString = userRecord.data['joinedDate'] as String?;
          if (joinedDateString == null) {
            result = {
              'status': null,
              'amount': 0,
              'payment_date': null,
              'updated_at': null,
            };
          } else {
            final joinedDate = DateTime.parse(joinedDateString);
            final monthStart = DateTime(monthDate.year, monthDate.month);
            final joinedMonthStart =
                DateTime(joinedDate.year, joinedDate.month);

            // If user joined after this month, not applicable
            if (monthStart.isBefore(joinedMonthStart)) {
              result = {
                'status': null,
                'amount': 0,
                'payment_date': null,
                'updated_at': null,
              };
            } else {
              // User was a member but no payment record - unpaid
              result = {
                'status': false,
                'amount': 100.0,
                'payment_date': null,
                'updated_at': null,
              };
            }
          }
        }
      } else {
        // Record exists - determine if paid
        final isPaid = monthlyDues.paymentDate != null;

        print(
            '_getPaymentStatus - Record found: id=${monthlyDues.id}, paymentDate=${monthlyDues.paymentDate}, isPaid=$isPaid',);

        result = {
          'status': isPaid,
          'amount': monthlyDues.amount,
          'payment_date': monthlyDues.paymentDate?.toIso8601String(),
          'updated_at': monthlyDues.updated,
        };
      }

      // Cache the result with timestamp
      _paymentStatusCache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();
      print(
          '_getPaymentStatus - Cached result for $cacheKey at ${DateTime.now()}',);
      return result;
    } catch (e) {
      // Handle 404 errors gracefully - user might not exist
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        print(
            'User $userId not found or inactive - skipping payment status check',);
        return {
          'status': null,
          'amount': 0,
          'payment_date': null,
          'updated_at': null,
        };
      }
      print('Error getting payment status for user $userId, month $month: $e');
      return null;
    }
  }

  // New method to get all months with payment status for a user
  Future<Map<String, bool?>> _getUserAllMonthsWithStatus(String userId) async {
    final monthStatus = <String, bool?>{};

    for (final month in _availableMonths) {
      try {
        final paymentData = await _getPaymentStatus(userId, month);
        // Store the actual status (null, true, or false)
        monthStatus[month] = paymentData?['status'] as bool?;
      } catch (e) {
        print('Error getting status for user $userId, month $month: $e');
        monthStatus[month] = null; // Default to null for error cases
      }
    }

    return monthStatus;
  }

  // New method to bulk update payments for a user
  Future<void> _bulkUpdatePayments(
      String userId, List<String> months, bool status,) async {
    setState(() {
      _isBulkUpdating = true;
    });

    try {
      print('Bulk Update - Starting update for user: $userId');
      print('Bulk Update - Months to update: $months');
      print('Bulk Update - Status: $status');

      final pocketBaseService = PocketBaseService();

      for (final month in months) {
        print('Bulk Update - Processing month: $month');
        final monthDate = DateFormat('yyyy_MM').parse(month);
        print('Bulk Update - Parsed date: $monthDate');

        final result = await pocketBaseService.markPaymentStatus(
          userId: userId,
          month: monthDate,
          isPaid: status,
        );
        if (result != null) {
          print('Bulk Update - Updated month $month, result ID: ${result.id}');
        } else {
          print('Bulk Update - Deleted record for month $month');
        }
      }

      // Clear all payment status cache since we updated multiple records
      _clearAllPaymentStatusCache();

      // Refresh the data
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status
                ? 'Successfully updated ${months.length} payment(s) as paid'
                : 'Successfully processed ${months.length} payment(s) - records deleted',),
            backgroundColor: status ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error bulk updating payments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating payments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBulkUpdating = false;
        });
      }
    }
  }

  // Helper method to check if a month is in the future
  bool _isFutureMonth(String month) {
    final date = DateFormat('yyyy_MM').parse(month);
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month));
  }

  // Build payment toggle with loading indicator
  Widget _buildPaymentToggle(String userId, String month, bool? status) {
    final toggleKey = '${userId}_$month';
    final isLoading = _loadingPaymentToggles.contains(toggleKey);

    if (isLoading) {
      return Container(
        width: 48,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
      );
    }

    return Switch(
      value: status == true,
      onChanged: status == null
          ? null
          : (value) {
              _markPaymentStatus(userId, month, value);
            },
      activeColor: Colors.green,
    );
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

  // Helper method to get profile image download URL for PocketBase
  Future<String?> _getProfileImageUrl(
      String userId, String? profileImageFileName,) async {
    if (profileImageFileName == null || profileImageFileName.isEmpty) {
      return null;
    }

    try {
      // If it's already a full URL, return it
      if (profileImageFileName.startsWith('http')) {
        return profileImageFileName;
      }

      // Otherwise, construct the PocketBase file URL
      final pocketbaseUrl =
          FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      return '$pocketbaseUrl/api/files/users/$userId/$profileImageFileName';
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
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              // Debug the first user for the current month
              if (_users.isNotEmpty) {
                await _debugPaymentStatus(
                    _users.first['id'] as String, _selectedMonth,);
              }
            },
            tooltip: 'Debug Payment Status',
          ),
          // Force cleanup button
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () async {
              // Force cleanup for the first user
              if (_users.isNotEmpty) {
                await _forceCleanupUserMonth(
                    _users.first['id'] as String, _selectedMonth,);
              }
            },
            tooltip: 'Force Cleanup Duplicates',
          ),
          // Clear cache button
          IconButton(
            icon: const Icon(Icons.cached),
            onPressed: () {
              _clearAllPaymentStatusCache();
              setState(() {
                // Force rebuild to refresh all payment statuses
              });
            },
            tooltip: 'Clear Payment Status Cache',
          ),
          // Cleanup duplicates button
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _manualCleanupDuplicates,
            tooltip: 'Clean Up Duplicate Records',
          ),
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
          if (_showOverview) _buildOverviewView() else _buildSingleMonthView(),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      final stats =
                          snapshot.data ?? {'totalPaid': 0, 'totalUnpaid': 0};
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
                      final stats =
                          snapshot.data ?? {'totalPaid': 0, 'totalUnpaid': 0};
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
          }),
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
                      final status = paymentData?['status'] as bool?;

                      // Handle three states: paid, unpaid, not applicable (before joined)
                      if (status == null) {
                        // Not applicable - before joined date
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 16,
                            color: Colors.grey,
                          ),
                        );
                      } else if (status == true) {
                        // Paid
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.green,
                          ),
                        );
                      } else {
                        // Unpaid
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
              DataCell(
                FutureBuilder<int>(
                  future: _getUserTotalPaid(user['id'] as String),
                  builder: (context, snapshot) {
                    final totalPaid = snapshot.data ?? 0;
                    final now = DateTime.now();
                    final monthsUpToCurrent = _availableMonths.where((month) {
                      final date = DateFormat('yyyy_MM').parse(month);
                      return date.isBefore(DateTime(now.year, now.month + 1));
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
    var totalPaid = 0;
    var totalUnpaid = 0;
    final now = DateTime.now();

    for (final user in _users) {
      for (final month in _availableMonths) {
        final date = DateFormat('yyyy_MM').parse(month);

        // Only count months up to current month (not future months)
        if (date.isBefore(DateTime(now.year, now.month + 1))) {
          final paymentData =
              await _getPaymentStatus(user['id'] as String, month);
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
    var count = 0;
    final now = DateTime.now();

    for (final month in _availableMonths) {
      final date = DateFormat('yyyy_MM').parse(month);

      // Only count months up to current month (not future months)
      if (date.isBefore(DateTime(now.year, now.month + 1))) {
        final paymentData = await _getPaymentStatus(userId, month);
        if ((paymentData?['status'] as bool?) == true) {
          count++;
        }
      }
    }
    return count;
  }

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color,) {
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
                    future: _getProfileImageUrl(
                        user['id'] as String, user['profileImage'] as String?,),
                    builder: (context, snapshot) {
                      final profileImageUrl = snapshot.data;
                      return profileImageUrl == null
                          ? Text(
                              ((user['firstName'] as String?) ?? '')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16,),
                            )
                          : ClipOval(
                              child: Image.network(
                                profileImageUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    ((user['firstName'] as String?) ?? '')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16,),
                                  );
                                },
                              ),
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
                  future:
                      _getPaymentStatus(user['id'] as String, _selectedMonth),
                  builder: (context, snapshot) {
                    final paymentData = snapshot.data;
                    final status = paymentData?['status'] as bool?;

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,),
                          decoration: BoxDecoration(
                            color: status == null
                                ? Colors.grey
                                : (status == true ? Colors.green : Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status == null
                                ? 'N/A'
                                : (status == true ? 'PAID' : 'UNPAID'),
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
                                color: status == null
                                    ? Colors.grey
                                    : (status == true
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildPaymentToggle(
                              user['id'] as String,
                              _selectedMonth,
                              status,
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
                  label:
                      const Text('Bulk Update', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    var count = 0;

    for (final user in _users) {
      final paymentData =
          await _getPaymentStatus(user['id'] as String, _selectedMonth);
      // Only count as paid if payment record exists and status is explicitly true
      if ((paymentData?['status'] as bool?) == true) {
        count++;
      }
    }
    return count;
  }

  Future<int> _getUnpaidCount() async {
    var count = 0;

    for (final user in _users) {
      final paymentData =
          await _getPaymentStatus(user['id'] as String, _selectedMonth);
      // Count as unpaid if status is explicitly false (member but no payment)
      // Don't count if status is null (not a member during this month)
      if ((paymentData?['status'] as bool?) == false) {
        count++;
      }
    }
    return count;
  }

  // User selection dialog
  Widget _buildUserSelectionDialog() {
    return ColoredBox(
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: FutureBuilder<String?>(
                            future: _getProfileImageUrl(user['id'] as String,
                                user['profileImage'] as String?,),
                            builder: (context, snapshot) {
                              final profileImageUrl = snapshot.data;
                              return profileImageUrl == null
                                  ? Text(
                                      ((user['firstName'] as String?) ?? '')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14,),
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        profileImageUrl,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                            ((user['firstName'] as String?) ??
                                                    '')[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,),
                                          );
                                        },
                                      ),
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
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 20,)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                            _showUserSelectionDialog = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Selected: ${user['firstName']} ${user['lastName']}',),
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
    return ColoredBox(
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
                            _cachedMonthStatus
                                .clear(); // Clear cache when dialog closes
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
                        _getUserAllMonthsWithStatus(
                                _selectedUser!['id'] as String,)
                            .then((monthStatus) {
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
                            child: ListView.builder(
                              itemCount: allMonths.length,
                              itemBuilder: (context, index) {
                                final month = allMonths[index];
                                final date = DateFormat('yyyy_MM').parse(month);
                                final displayText =
                                    DateFormat('MMMM yyyy').format(date);
                                final status = _cachedMonthStatus[month];
                                final isSelected = _selectedMonthsForBulkUpdate
                                    .contains(month);

                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    listTileTheme: const ListTileThemeData(
                                      dense: true,
                                      minVerticalPadding: 0,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,),
                                    title: Text(
                                      displayText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      status == null
                                          ? 'Not Applicable'
                                          : (status == true
                                              ? 'Paid'
                                              : (_isFutureMonth(month)
                                                  ? 'Future'
                                                  : 'Unpaid')),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: status == null
                                            ? Colors.grey
                                            : (status == true
                                                ? Colors.green
                                                : (_isFutureMonth(month)
                                                    ? Colors.blue
                                                    : Colors.red)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: status == null ? false : isSelected,
                                    onChanged: status == null
                                        ? null
                                        : (value) {
                                            print(
                                                'Checkbox tapped for month: $month, value: $value',);
                                            setDialogState(() {
                                              if (value == true) {
                                                _selectedMonthsForBulkUpdate
                                                    .add(month);
                                              } else {
                                                _selectedMonthsForBulkUpdate
                                                    .remove(month);
                                              }
                                              print(
                                                  'Selected months: $_selectedMonthsForBulkUpdate',);
                                            });
                                          },
                                    secondary: Icon(
                                      status == null
                                          ? Icons.remove
                                          : (status == true
                                              ? Icons.check_circle
                                              : (_isFutureMonth(month)
                                                  ? Icons.schedule
                                                  : Icons.cancel)),
                                      color: status == null
                                          ? Colors.grey
                                          : (status == true
                                              ? Colors.green
                                              : (_isFutureMonth(month)
                                                  ? Colors.blue
                                                  : Colors.red)),
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        // Only select months that are applicable (not null status)
                                        _selectedMonthsForBulkUpdate = allMonths
                                            .where((month) =>
                                                _cachedMonthStatus[month] !=
                                                null,)
                                            .toList();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8,),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
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
                                      setDialogState(() {
                                        _selectedMonthsForBulkUpdate.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8,),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
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
                                    onPressed: _selectedMonthsForBulkUpdate
                                                .isEmpty ||
                                            _isBulkUpdating
                                        ? null
                                        : () async {
                                            await _bulkUpdatePayments(
                                              _selectedUser!['id'] as String,
                                              _selectedMonthsForBulkUpdate,
                                              true, // Mark as paid
                                            );
                                            setState(() {
                                              _showBulkUpdateDialog = false;
                                              _selectedMonthsForBulkUpdate
                                                  .clear();
                                              _cachedMonthStatus
                                                  .clear(); // Clear cache after update
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8,),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: _isBulkUpdating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white,),
                                            ),
                                          )
                                        : const Text(
                                            'Mark as Paid',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedMonthsForBulkUpdate
                                                .isEmpty ||
                                            _isBulkUpdating
                                        ? null
                                        : () async {
                                            await _bulkUpdatePayments(
                                              _selectedUser!['id'] as String,
                                              _selectedMonthsForBulkUpdate,
                                              false, // Mark as unpaid
                                            );
                                            setState(() {
                                              _showBulkUpdateDialog = false;
                                              _selectedMonthsForBulkUpdate
                                                  .clear();
                                              _cachedMonthStatus
                                                  .clear(); // Clear cache after update
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8,),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: _isBulkUpdating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white,),
                                            ),
                                          )
                                        : const Text(
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
    var count = 0;
    final now = DateTime.now();

    for (final user in _users) {
      for (final month in _availableMonths) {
        final date = DateFormat('yyyy_MM').parse(month);

        // Only count future months that have been paid
        if (date.isAfter(DateTime(now.year, now.month))) {
          final paymentData =
              await _getPaymentStatus(user['id'] as String, month);
          if ((paymentData?['status'] as bool?) == true) {
            count++;
          }
        }
      }
    }
    return count;
  }
}
