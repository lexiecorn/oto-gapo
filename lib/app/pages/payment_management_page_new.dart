import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/models/payment_transaction.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

class PaymentManagementPageNew extends StatefulWidget {
  const PaymentManagementPageNew({super.key});

  @override
  State<PaymentManagementPageNew> createState() => _PaymentManagementPageNewState();
}

class _PaymentManagementPageNewState extends State<PaymentManagementPageNew> {
  bool _isLoading = true;
  List<RecordModel> _users = [];
  String _selectedMonth = '';
  List<String> _availableMonths = [];
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, paid, pending, overdue

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
      print('=== Loading all users ===');
      final pocketBaseService = PocketBaseService();
      final users = await pocketBaseService.getAllUsers();
      print('Total users loaded: ${users.length}');

      final activeUsers = users.where((user) => user.data['isActive'] == true).toList();
      print('Active users: ${activeUsers.length}');

      // Log a few user IDs for debugging
      if (activeUsers.isNotEmpty) {
        print('Sample user IDs:');
        for (var i = 0; i < activeUsers.length.clamp(0, 3); i++) {
          final user = activeUsers[i];
          print('  - ${user.data['email']}: ${user.id}');
        }
      }

      setState(() {
        _users = activeUsers;
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

    // Generate months from 12 months ago to 3 months in future
    for (var i = -12; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i);
      final monthKey = DateFormat('yyyy-MM').format(date);
      months.add(monthKey);
    }

    setState(() {
      _availableMonths = months.reversed.toList(); // Most recent first
      _selectedMonth = DateFormat('yyyy-MM').format(now);
    });
  }

  void _showPaymentDialog({
    required String userId,
    required String userName,
    required String month,
    PaymentTransaction? existingTransaction,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => _BulkPaymentDialog(
        userId: userId,
        userName: userName,
        initialMonth: month,
        onPaymentsUpdated: () {
          setState(() {}); // Refresh the list
        },
      ),
    );
  }

  List<RecordModel> _getFilteredUsers() {
    var filtered = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final firstName = (user.data['firstName'] as String?)?.toLowerCase() ?? '';
        final lastName = (user.data['lastName'] as String?)?.toLowerCase() ?? '';
        final memberNumber = user.data['memberNumber']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return firstName.contains(query) || lastName.contains(query) || memberNumber.contains(query);
      }).toList();
    }

    return filtered;
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControls(),
          _buildSummaryCard(),
          SizedBox(height: 16.h),
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Text('Select Month', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: TextStyle(fontSize: 12.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
              dropdownColor: Theme.of(context).cardColor,
              items: _availableMonths.map((month) {
                final date = DateTime.parse('$month-01');
                final displayText = DateFormat('MMMM yyyy').format(date);
                return DropdownMenuItem(
                  value: month,
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Search
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Search by name or member number...',
                prefixIcon: const Icon(Icons.search),
                hintStyle: TextStyle(fontSize: 11.sp),
              ),
              style: TextStyle(fontSize: 12.sp),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Status filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Paid', 'paid'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Pending', 'pending'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Overdue', 'overdue'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11.sp)),
      selected: _statusFilter == value,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  Widget _buildSummaryCard() {
    return FutureBuilder<Map<String, int>>(
      future: _getMonthSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final summary = snapshot.data!;
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total',
                    _getFilteredUsers().length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Paid',
                    summary['paid'].toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pending',
                    summary['pending'].toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Overdue',
                    summary['overdue'].toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // add vertical space

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
      ],
    );
  }

  Future<Map<String, int>> _getMonthSummary() async {
    var paidCount = 0;
    var pendingCount = 0;
    var overdueCount = 0;

    final pocketBaseService = PocketBaseService();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final selectedMonthDate = DateTime.parse('$_selectedMonth-01');
    final isOverdueMonth = selectedMonthDate.isBefore(currentMonth);

    for (final user in _getFilteredUsers()) {
      final transaction = await pocketBaseService.getPaymentTransaction(
        user.id,
        _selectedMonth,
      );

      if (transaction == null) {
        pendingCount++;
        if (isOverdueMonth) overdueCount++;
      } else if (transaction.isPaid) {
        paidCount++;
      } else if (transaction.isPending) {
        pendingCount++;
        if (isOverdueMonth) overdueCount++;
      }
    }

    return {'paid': paidCount, 'pending': pendingCount, 'overdue': overdueCount};
  }

  Widget _buildUsersList() {
    final filteredUsers = _getFilteredUsers();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(RecordModel user) {
    final userData = user.data;
    final userId = user.id;
    final userName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    final memberNumber = userData['memberNumber']?.toString() ?? '';

    return FutureBuilder<PaymentTransaction?>(
      future: PocketBaseService().getPaymentTransaction(userId, _selectedMonth),
      builder: (context, snapshot) {
        final transaction = snapshot.data;
        final isPaid = transaction?.isPaid ?? false;
        final isWaived = transaction?.isWaived ?? false;

        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final selectedMonthDate = DateTime.parse('$_selectedMonth-01');
        final isOverdue = !isPaid && !isWaived && selectedMonthDate.isBefore(currentMonth);

        // Apply status filter
        if (_statusFilter == 'paid' && !isPaid) return const SizedBox.shrink();
        if (_statusFilter == 'pending' && (isPaid || isWaived)) return const SizedBox.shrink();
        if (_statusFilter == 'overdue' && !isOverdue) return const SizedBox.shrink();

        final statusColor = isPaid
            ? Colors.green
            : isWaived
                ? Colors.grey
                : isOverdue
                    ? Colors.red
                    : Colors.orange;

        final statusText = isPaid
            ? 'PAID'
            : isWaived
                ? 'WAIVED'
                : isOverdue
                    ? 'OVERDUE'
                    : 'PENDING';

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: _buildUserAvatar(
              userData: userData,
              userId: userId,
              userName: userName,
              statusColor: statusColor,
            ),
            title: Text(
              userName,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Member #$memberNumber',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              print('=== User card tapped ===');
              print('User ID: $userId');
              print('User name: $userName');
              print('Member number: $memberNumber');
              print('User data keys: ${userData.keys.toList()}');

              _showPaymentDialog(
                userId: userId,
                userName: userName,
                month: _selectedMonth,
                existingTransaction: transaction,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar({
    required Map<String, dynamic> userData,
    required String userId,
    required String userName,
    required Color statusColor,
  }) {
    // Get profile image filename
    String? profileImageFileName;
    if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
      profileImageFileName = userData['profile_image'].toString();
    } else if (userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty) {
      profileImageFileName = userData['profileImage'].toString();
    }

    // Build profile image URL if we have a filename
    String? profileImageUrl;
    if (profileImageFileName != null) {
      if (profileImageFileName.startsWith('http')) {
        // It's already a full URL
        profileImageUrl = profileImageFileName;
      } else {
        // It's a PocketBase filename, construct the URL
        final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        profileImageUrl = '$pocketbaseUrl/api/files/users/$userId/$profileImageFileName';
      }
    }

    return CircleAvatar(
      backgroundColor: statusColor.withOpacity(0.2),
      child: profileImageUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profileImageUrl,
                fit: BoxFit.cover,
                width: 40.sp,
                height: 40.sp,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

/// Bulk Payment Dialog for selecting and paying multiple months at once
class _BulkPaymentDialog extends StatefulWidget {
  const _BulkPaymentDialog({
    required this.userId,
    required this.userName,
    required this.initialMonth,
    required this.onPaymentsUpdated,
  });

  final String userId;
  final String userName;
  final String initialMonth;
  final VoidCallback onPaymentsUpdated;

  @override
  State<_BulkPaymentDialog> createState() => _BulkPaymentDialogState();
}

class _BulkPaymentDialogState extends State<_BulkPaymentDialog> {
  bool _isLoading = true;
  List<String> _availableMonths = [];
  Map<String, PaymentTransaction?> _transactions = {};
  Set<String> _selectedMonths = {};
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserPayments();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String? _errorMessage;

  Future<void> _loadUserPayments() async {
    try {
      print('=== Loading payments for user ${widget.userId} ===');
      print('User name: ${widget.userName}');

      final pocketBaseService = PocketBaseService();

      // Ensure authentication before attempting to get user
      print('Ensuring authentication...');
      try {
        await pocketBaseService.pb.collection('users').getList(perPage: 1);
        print('Authentication confirmed');
      } catch (authError) {
        print('Authentication check failed: $authError');
        if (mounted) {
          setState(() {
            _errorMessage = 'Authentication error. Please try logging out and back in.';
            _isLoading = false;
          });
        }
        return;
      }

      // Get user to find join date
      print('Fetching user record for ID: ${widget.userId}');
      final userRecord = await pocketBaseService.getUser(widget.userId);
      if (userRecord == null) {
        print('Error: User record not found for userId: ${widget.userId}');
        print('This user may have been deleted or the ID is incorrect');
        if (mounted) {
          setState(() {
            _errorMessage =
                'User record not found (ID: ${widget.userId.substring(0, 8)}...). The user may have been deleted.';
            _isLoading = false;
          });
        }
        return;
      }

      print('User record found: ${userRecord.data['email']}');

      final joinedDateString = userRecord.data['joinedDate'] as String?;
      if (joinedDateString == null || joinedDateString.isEmpty) {
        print('Error: User ${widget.userId} has no joinedDate field');
        if (mounted) {
          setState(() {
            _errorMessage = 'User join date is not set. Please contact an administrator to update the user profile.';
            _isLoading = false;
          });
        }
        return;
      }

      final joinedDate = DateTime.parse(joinedDateString);
      print('Loading payments for user ${widget.userId}, joined: $joinedDateString');

      final expectedMonths = pocketBaseService.getExpectedMonths(joinedDate);
      print('Expected months from join date: ${expectedMonths.length} months');

      // Add next 3 months for advance payments
      final now = DateTime.now();
      for (var i = 1; i <= 3; i++) {
        final futureDate = DateTime(now.year, now.month + i);
        final futureMonth = DateFormat('yyyy-MM').format(futureDate);
        if (!expectedMonths.contains(futureMonth)) {
          expectedMonths.add(futureMonth);
        }
      }

      print('Total available months (including future): ${expectedMonths.length}');

      // Get all transactions for the user
      final transactions = await pocketBaseService.getPaymentTransactions(widget.userId);
      print('Found ${transactions.length} existing payment transactions');

      final transactionMap = {for (var t in transactions) t.month: t};

      if (expectedMonths.isEmpty) {
        print('Warning: No expected months generated for user ${widget.userId}');
        if (mounted) {
          setState(() {
            _errorMessage = 'No payment months available for this user. This may indicate an issue with the join date.';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _availableMonths = expectedMonths;
          _transactions = transactionMap;
          _selectedMonths = {widget.initialMonth}; // Pre-select the initial month
          _errorMessage = null;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading user payments: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load payment information: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processPayments() async {
    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one month'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final pocketBaseService = PocketBaseService();
      final currentAdminId = context.read<AuthBloc>().state.user?.id;

      for (final month in _selectedMonths) {
        await pocketBaseService.updatePaymentTransaction(
          userId: widget.userId,
          month: month,
          status: PaymentStatus.paid,
          paymentDate: DateTime.now(),
          paymentMethod: _selectedMethod,
          notes: _notesController.text,
          recordedBy: currentAdminId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentsUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully recorded ${_selectedMonths.length} payment(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error processing payments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _selectUnpaidMonths() {
    final unpaidMonths = _availableMonths.where((month) {
      final transaction = _transactions[month];
      return transaction == null || !transaction.isPaid;
    }).toSet();

    setState(() {
      _selectedMonths = unpaidMonths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(Icons.payment, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Payments',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.userName,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            if (_isLoading)
              Expanded(
                child: Center(child: const CircularProgressIndicator()),
              )
            else if (_errorMessage != null) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Unable to Load Months',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else if (_availableMonths.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Months Available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'There are no payment months available for this user.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Month selection list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectUnpaidMonths,
                            icon: const Icon(Icons.select_all, size: 16),
                            label: const Text('Select All Unpaid', style: TextStyle(fontSize: 10)),
                            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _selectedMonths.clear()),
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Clear All', style: TextStyle(fontSize: 10)),
                            style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.h)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Month checkboxes
                    ..._availableMonths.map((month) {
                      final monthDate = DateTime.parse('$month-01');
                      final monthName = DateFormat('MMMM yyyy').format(monthDate);
                      final transaction = _transactions[month];
                      final isPaid = transaction?.isPaid ?? false;
                      final isWaived = transaction?.isWaived ?? false;
                      final isSelected = _selectedMonths.contains(month);

                      final now = DateTime.now();
                      final currentMonth = DateTime(now.year, now.month);
                      final isOverdue = !isPaid && !isWaived && monthDate.isBefore(currentMonth);

                      final statusColor = isPaid
                          ? Colors.green
                          : isWaived
                              ? Colors.grey
                              : isOverdue
                                  ? Colors.red
                                  : Colors.orange;

                      final statusText = isPaid
                          ? 'Paid'
                          : isWaived
                              ? 'Waived'
                              : isOverdue
                                  ? 'Overdue'
                                  : 'Pending';

                      return CheckboxListTile(
                        dense: true,
                        value: isSelected,
                        onChanged: (isPaid || isWaived)
                            ? null
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedMonths.add(month);
                                  } else {
                                    _selectedMonths.remove(month);
                                  }
                                });
                              },
                        title: Text(monthName, style: TextStyle(fontSize: 12.sp)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text('₱100', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                        secondary: Icon(
                          isPaid
                              ? Icons.check_circle
                              : isWaived
                                  ? Icons.block
                                  : isOverdue
                                      ? Icons.error
                                      : Icons.schedule,
                          color: statusColor,
                          size: 20.sp,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Payment details
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),

                    // Payment method
                    DropdownButtonFormField<PaymentMethod>(
                      value: _selectedMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        labelStyle: TextStyle(fontSize: 11.sp),
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Row(
                            children: [
                              Icon(_getPaymentMethodIcon(method), size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(method.displayName, style: TextStyle(fontSize: 11.sp)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        border: const OutlineInputBorder(),
                        hintText: 'Add any notes...',
                        labelStyle: TextStyle(fontSize: 11.sp),
                        hintStyle: TextStyle(fontSize: 11.sp),
                      ),
                      style: TextStyle(fontSize: 11.sp),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),

                    // Summary
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${_selectedMonths.length} month(s) selected • Total: ₱${_selectedMonths.length * 100}',
                              style: TextStyle(fontSize: 10.sp, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Actions
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing || _selectedMonths.isEmpty ? null : _processPayments,
                        icon: _isProcessing
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _isProcessing ? 'Processing...' : 'Record Payments',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.gcash:
        return Icons.phone_android;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }
}
