import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otogapo/app/pages/user_list_page.dart';
import 'package:otogapo/app/pages/create_user_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  int _totalUsers = 0;
  int _newThisMonth = 0;
  int _activeUsers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatistics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh statistics when page becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserStatistics();
    });
  }

  Future<void> _loadUserStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get total users count
      final totalUsersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final totalUsers = totalUsersSnapshot.docs.length;

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Get new users this month
      int newThisMonth = 0;
      int activeUsers = 0;

      for (final doc in totalUsersSnapshot.docs) {
        final data = doc.data();

        // Check if user was created this month
        if (data['createdAt'] != null) {
          final createdAt = data['createdAt'] as Timestamp;
          final createdDate = createdAt.toDate();

          if (createdDate.month == currentMonth && createdDate.year == currentYear) {
            newThisMonth++;
          }
        }

        // Check if user is active
        if (data['isActive'] == true) {
          activeUsers++;
        }
      }

      setState(() {
        _totalUsers = totalUsers;
        _newThisMonth = newThisMonth;
        _activeUsers = activeUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserStatistics,
            tooltip: 'Refresh Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection()
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: -0.3, duration: const Duration(milliseconds: 600)),

            SizedBox(height: 24.sp),

            // Quick Stats Section
            _buildQuickStatsSection()
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600))
                .slideY(
                    begin: -0.2, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600)),

            SizedBox(height: 24.sp),

            // Main Actions Section
            _buildMainActionsSection(context)
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 600))
                .slideY(
                    begin: -0.2, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 600)),

            SizedBox(height: 24.sp),

            // Quick Actions Section
            _buildQuickActionsSection(context)
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 600))
                .slideY(
                    begin: -0.2, delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[800]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              size: 32.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.sp),
          Text(
            'User Management Dashboard',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.sp),
          Text(
            'Manage user accounts, permissions, and system access',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'Total Users',
            value: _totalUsers.toString(),
            color: Colors.blue,
            delay: const Duration(milliseconds: 100),
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: _buildStatCard(
            icon: Icons.person_add,
            title: 'New This Month',
            value: _newThisMonth.toString(),
            color: Colors.green,
            delay: const Duration(milliseconds: 200),
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: _buildStatCard(
            icon: Icons.verified_user,
            title: 'Active Users',
            value: _activeUsers.toString(),
            color: Colors.orange,
            delay: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Duration delay,
  }) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.sp),
          _isLoading
              ? SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay, duration: const Duration(milliseconds: 400));
  }

  Widget _buildMainActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.sp),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.list_alt,
                title: 'User List',
                subtitle: 'View and manage all users',
                color: Colors.blue,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserListPage()),
                  );
                  // Refresh statistics when returning
                  _loadUserStatistics();
                },
                delay: const Duration(milliseconds: 100),
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.person_add_alt_1,
                title: 'Create User',
                subtitle: 'Add new user account',
                color: Colors.green,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreateUserPage()),
                  );
                  // Refresh statistics when returning
                  _loadUserStatistics();
                },
                delay: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.sp),
        child: Container(
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 12.sp),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.sp),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay, duration: const Duration(milliseconds: 400));
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildQuickActionTile(
                context: context,
                icon: Icons.search,
                title: 'Search Users',
                subtitle: 'Find specific users quickly',
                onTap: () {
                  // TODO: Implement search functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search functionality coming soon!')),
                  );
                },
              ),
              Divider(height: 1, color: Colors.grey[200]),
              _buildQuickActionTile(
                context: context,
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download user data as CSV',
                onTap: () {
                  // TODO: Implement export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export functionality coming soon!')),
                  );
                },
              ),
              Divider(height: 1, color: Colors.grey[200]),
              _buildQuickActionTile(
                context: context,
                icon: Icons.settings,
                title: 'Bulk Operations',
                subtitle: 'Manage multiple users at once',
                onTap: () {
                  // TODO: Implement bulk operations
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bulk operations coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.sp),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 8.sp),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8.sp),
            Text('User Management Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.list_alt,
              title: 'User List',
              description: 'View all registered users and manage their accounts.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.person_add_alt_1,
              title: 'Create User',
              description: 'Add new users to the system with their details.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.search,
              title: 'Search Users',
              description: 'Quickly find specific users by name or member number.',
            ),
            SizedBox(height: 12.sp),
            _buildHelpItem(
              icon: Icons.download,
              title: 'Export Data',
              description: 'Download user data for backup or analysis.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.blue),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
