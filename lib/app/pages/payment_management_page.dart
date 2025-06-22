import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('membership_type', whereIn: [3]) // Only regular members
          .get();

      final users = <Map<String, dynamic>>[];
      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        userData['id'] = doc.id;
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

    // Generate last 12 months
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy_MM').format(date);
      months.add(monthKey);
    }

    setState(() {
      _availableMonths = months;
      _selectedMonth = months.first;
    });
  }

  Future<void> _markPaymentStatus(String userId, String month, bool status) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('monthly_dues').doc(month).set({
        'amount': 100,
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

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
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).collection('monthly_dues').doc(month).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting payment status: $e');
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
      ),
      body: Column(
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
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserPaymentCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    ((user['firstName'] as String?) ?? '')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Member #${user['memberNumber'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'UNPAID',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱100',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }

  Future<int> _getPaidCount() async {
    int count = 0;
    for (final user in _users) {
      final paymentData = await _getPaymentStatus(user['id'] as String, _selectedMonth);
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
      if ((paymentData?['status'] as bool?) != true) {
        count++;
      }
    }
    return count;
  }
}
