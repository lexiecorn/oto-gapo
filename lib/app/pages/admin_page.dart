import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otogapo/app/pages/user_management_page.dart';
import 'package:otogapo/app/pages/payment_management_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentUserData;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _currentUserData = userData;
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
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Access Denied'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have admin privileges to access this page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_currentUserData != null) ...[
                      Text('Name: ${_currentUserData!['firstName'] ?? ''} ${_currentUserData!['lastName'] ?? ''}'),
                      Text('Email: ${_currentUserData!['email'] ?? ''}'),
                      Text('Member Number: ${_currentUserData!['memberNumber'] ?? ''}'),
                      Text('Role: ${_getMembershipTypeText(_currentUserData!['membership_type'])}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Admin Functions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    icon: Icons.people,
                    title: 'User Management',
                    subtitle: 'Manage all users',
                    onTap: () {
                      // Navigate to user management
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const UserManagementPage()),
                      );
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.payment,
                    title: 'Payment Management',
                    subtitle: 'Manage monthly dues',
                    onTap: () {
                      // Navigate to payment management
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PaymentManagementPage()),
                      );
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View system analytics',
                    onTap: () {
                      // TODO: Implement analytics page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Analytics feature coming soon!')),
                      );
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.settings,
                    title: 'System Settings',
                    subtitle: 'Configure system',
                    onTap: () {
                      // TODO: Implement system settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('System settings feature coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMembershipTypeText(dynamic membershipType) {
    switch (membershipType) {
      case 1:
        return 'Super Admin';
      case 2:
        return 'Admin';
      case 3:
        return 'Member';
      default:
        return 'Unknown';
    }
  }
}
