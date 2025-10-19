import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/analytics_page.dart';
import 'package:otogapo/app/pages/gallery_management_page.dart';
import 'package:otogapo/app/pages/payment_management_page_new.dart';
import 'package:otogapo/app/pages/user_management_page.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

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
      // Prefer profile state which is already loaded and consistent
      final profileState = context.read<ProfileCubit>().state;
      final profileUser = profileState.user;

      if (profileState.profileStatus == ProfileStatus.loaded && profileUser.uid.isNotEmpty) {
        setState(() {
          _currentUserData = {
            'firstName': profileUser.firstName,
            'lastName': profileUser.lastName,
            'memberNumber': profileUser.memberNumber,
            'membership_type': profileUser.membership_type,
          };
          _isAdmin = (profileUser.membership_type == 1) || (profileUser.membership_type == 2);
          _isLoading = false;
        });
        return;
      }

      // Fallback: resolve PocketBase user by email
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        final pocketBaseService = PocketBaseService();
        final rec = await pocketBaseService.getUserByEmail(authState.user!.data['email'].toString());
        final userData = rec?.data;
        setState(() {
          _currentUserData = userData;
          _isAdmin = (userData?['membership_type'] == 1) || (userData?['membership_type'] == 2);
          _isLoading = false;
        });
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                childAspectRatio: 0.85,
                children: [
                  _buildAdminCard(
                    icon: Icons.people,
                    title: 'User Management',
                    subtitle: 'Manage all users',
                    onTap: () {
                      // Navigate to user management
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (context) => const UserManagementPage()),
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
                        MaterialPageRoute<void>(builder: (context) => const PaymentManagementPageNew()),
                      );
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.photo_library,
                    title: 'Gallery Management',
                    subtitle: 'Manage images',
                    onTap: () {
                      // Navigate to gallery management
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (context) => const GalleryManagementPage()),
                      );
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.event_note,
                    title: 'Meetings',
                    subtitle: 'Manage meetings',
                    onTap: () {
                      context.router.push(const MeetingsListPageRouter());
                    },
                  ),
                  _buildAdminCard(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View system analytics',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (context) => const AnalyticsPage()),
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
                  _buildAdminCard(
                    icon: Icons.feed,
                    title: 'Social Feed Moderation',
                    subtitle: 'Manage posts & reports',
                    onTap: () {
                      context.router.push(const SocialFeedModerationPageRouter());
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
    final iconColor = Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white;
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
