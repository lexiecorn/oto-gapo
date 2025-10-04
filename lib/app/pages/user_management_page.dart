import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:otogapo/providers/theme_provider.dart';
import 'package:otogapo/app/pages/user_list_page.dart';
import 'package:otogapo/app/pages/create_user_page.dart';
import 'package:otogapo/services/pocketbase_service.dart';

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

      // Use PocketBase to get user statistics
      final pocketBaseService = PocketBaseService();
      final pocketBaseUsers = await pocketBaseService.getAllUsers();

      final totalUsers = pocketBaseUsers.length;

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Get new users this month and active users
      int newThisMonth = 0;
      int activeUsers = 0;

      for (final user in pocketBaseUsers) {
        final data = user.data;

        // Check if user was created this month
        if (data['created'] != null) {
          final createdAt = DateTime.parse(data['created'].toString());
          if (createdAt.month == currentMonth && createdAt.year == currentYear) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        foregroundColor: isDark ? colorScheme.onSurface : Colors.black87,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
            onPressed: () {
              // Toggle theme using the theme provider
              context.read<ThemeProvider>().toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
            onPressed: _loadUserStatistics,
            tooltip: 'Refresh Statistics',
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
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

            SizedBox(height: 24.sp),

            // Theme Info Section
            _buildThemeInfoSection(context)
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 600))
                .slideY(
                    begin: -0.2, delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ]
              : [
                  Colors.blue[600]!,
                  Colors.blue[800]!,
                ],
        ),
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: (isDark ? colorScheme.primary : Colors.blue).withOpacity(0.3),
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
              color: (isDark ? colorScheme.onPrimary : Colors.white).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              size: 32.sp,
              color: isDark ? colorScheme.onPrimary : Colors.white,
            ),
          ),
          SizedBox(height: 16.sp),
          Text(
            'User Management Dashboard',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? colorScheme.onPrimary : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.sp),
          Text(
            'Manage user accounts, permissions, and system access',
            style: TextStyle(
              fontSize: 14.sp,
              color: (isDark ? colorScheme.onPrimary : Colors.white).withOpacity(0.9),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(color: colorScheme.outline.withOpacity(0.2)) : null,
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
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.sp),
          _isLoading
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? colorScheme.onSurface : Colors.black87,
                  ),
                ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay, duration: const Duration(milliseconds: 600));
  }

  Widget _buildMainActionsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? colorScheme.onSurface : Colors.black87,
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
                    MaterialPageRoute<void>(builder: (context) => const UserListPage()),
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
                    MaterialPageRoute<void>(builder: (context) => const CreateUserPage()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.sp),
        child: Container(
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
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
                  color: isDark ? colorScheme.onSurface : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.sp),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
        SizedBox(height: 16.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isDark ? Border.all(color: colorScheme.outline.withOpacity(0.2)) : null,
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
              Divider(height: 1, color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey[200]),
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
              Divider(height: 1, color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey[200]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: isDark ? colorScheme.primary : Colors.grey[700],
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
                        color: isDark ? colorScheme.onSurface : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: isDark ? colorScheme.primary : Colors.blue),
            SizedBox(width: 8.sp),
            Text(
              'User Management Help',
              style: TextStyle(
                color: isDark ? colorScheme.onSurface : Colors.black87,
              ),
            ),
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
            child: Text(
              'Got it',
              style: TextStyle(
                color: isDark ? colorScheme.primary : Colors.blue,
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: isDark ? colorScheme.primary : Colors.blue),
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
                  color: isDark ? colorScheme.onSurface : Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeInfoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.secondary,
                  colorScheme.secondary.withOpacity(0.8),
                ]
              : [
                  Colors.purple[600]!,
                  Colors.purple[800]!,
                ],
        ),
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: (isDark ? colorScheme.secondary : Colors.purple).withOpacity(0.3),
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
              color: (isDark ? colorScheme.onSecondary : Colors.white).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 32.sp,
              color: isDark ? colorScheme.onSecondary : Colors.white,
            ),
          ),
          SizedBox(height: 16.sp),
          Text(
            'Theme Information',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? colorScheme.onSecondary : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.sp),
          Text(
            'Current Theme: ${isDark ? 'Dark' : 'Light'} Mode',
            style: TextStyle(
              fontSize: 14.sp,
              color: (isDark ? colorScheme.onSecondary : Colors.white).withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.sp),
          Text(
            'Tap the theme icon in the app bar to switch themes',
            style: TextStyle(
              fontSize: 12.sp,
              color: (isDark ? colorScheme.onSecondary : Colors.white).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
