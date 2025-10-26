// ignore_for_file: prefer_single_quotes

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/admin_page.dart';
import 'package:otogapo/app/pages/current_user_account_page.dart';
import 'package:otogapo/app/pages/developer_tools_page.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/payment_status_card_new.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/providers/theme_provider.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _userName;
  String? _userEmail;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<String?> _getProfileImageUrl() async {
    if (_profileImage == null || _profileImage!.isEmpty) return null;

    try {
      if (!mounted) return null;
      final authState = context.read<AuthBloc>().state;
      if (authState.user?.id == null) return null;

      final pocketBaseService = PocketBaseService();
      final userRecord = await pocketBaseService.getUser(authState.user!.id);
      if (userRecord == null) return null;

      final baseUrl = pocketBaseService.baseUrl;
      final collectionId = userRecord.collectionId;
      final recordId = userRecord.id;

      return '$baseUrl/api/files/$collectionId/$recordId/$_profileImage';
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  Future<void> _checkUserStatus() async {
    try {
      debugPrint('Settings Page - Starting _checkUserStatus');

      // Get user from PocketBase authentication only
      final authState = context.read<AuthBloc>().state;
      debugPrint('Settings Page - AuthBloc state: ${authState.runtimeType}');

      if (authState.user != null) {
        debugPrint('Settings Page - User authenticated with PocketBase via AuthBloc');
        debugPrint('Settings Page - AuthBloc user ID: ${authState.user!.id}');
        try {
          final pocketBaseService = PocketBaseService();
          final userRecord = await pocketBaseService.getUser(authState.user!.id);
          if (userRecord == null) throw Exception('User record not found');
          final userData = userRecord.data;

          if (!mounted) return;
          setState(() {
            final membershipType = userData['membership_type'];
            debugPrint(
              'Settings Page - PocketBase user membership_type: $membershipType (type: ${membershipType.runtimeType})',
            );
            _isAdmin = membershipType == 1 || membershipType == 2 || membershipType == '1' || membershipType == '2';
            debugPrint('Settings Page - _isAdmin: $_isAdmin');
            _userName =
                '${userData['firstName']?.toString() ?? ''} ' + '${userData['lastName']?.toString() ?? ''}'.trim();
            _userEmail = userData['email']?.toString() ?? '';
            _profileImage = userData['profileImage']?.toString();
            _isLoading = false;
          });
        } catch (e) {
          debugPrint('Settings Page - Error getting user from PocketBase: $e');
          debugPrint(
            'Settings Page - User ID ${authState.user!.id} not found in PocketBase, trying ProfileCubit fallback',
          );

          // Try ProfileCubit fallback immediately
          try {
            if (!mounted) return;
            final profileCubit = context.read<ProfileCubit>();
            final profileState = profileCubit.state;

            if (profileState.user.uid.isNotEmpty) {
              debugPrint('Settings Page - Using ProfileCubit data as fallback');
              debugPrint('Settings Page - ProfileCubit user UID: ${profileState.user.uid}');
              debugPrint(
                'Settings Page - ProfileCubit user membership_type: ${profileState.user.membership_type}',
              );
              if (!mounted) return;
              setState(() {
                final membershipType = profileState.user.membership_type;
                debugPrint(
                  'Settings Page - ProfileCubit user membership_type: $membershipType (type: ${membershipType.runtimeType})',
                );
                _isAdmin = membershipType == 1 || membershipType == 2;
                debugPrint('Settings Page - _isAdmin: $_isAdmin');
                _userName = '${profileState.user.firstName} ${profileState.user.lastName}'.trim();
                _userEmail = ''; // User model doesn't have email field
                _isLoading = false;
              });
            } else {
              debugPrint('Settings Page - ProfileCubit user data is empty');
              if (!mounted) return;
              setState(() {
                _isAdmin = false;
                _userName = 'User';
                _userEmail = '';
                _isLoading = false;
              });
            }
          } catch (profileError) {
            debugPrint('Settings Page - ProfileCubit fallback also failed: $profileError');
            if (!mounted) return;
            setState(() {
              _isAdmin = false;
              _userName = 'User';
              _userEmail = '';
              _isLoading = false;
            });
          }
        }
      } else {
        debugPrint('Settings Page - No PocketBase user in AuthBloc');
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _userName = 'User';
          _userEmail = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking user status: $e');
      if (!mounted) return;
      setState(() {
        _isAdmin = false;
        _userName = 'User';
        _userEmail = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get package info for version display
    final packageInfo = getIt<PackageInfo>();

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading settings...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FutureBuilder<String?>(
                      future: _getProfileImageUrl(),
                      builder: (context, snapshot) {
                        final imageUrl = snapshot.data;
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          backgroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null || imageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName ?? 'Account Settings',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    if (_userEmail != null)
                      Text(
                        _userEmail!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account preferences',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.qr_code,
                      label: 'My QR Code',
                      onTap: () {
                        context.router.push(const UserQRCodePageRouter());
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.calendar_month,
                      label: 'Calendar View',
                      onTap: () {
                        context.router.push(const AttendanceCalendarPageRouter());
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Dues Section
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                // Only show if user is loaded
                if (profileState.profileStatus == ProfileStatus.loaded && profileState.user.uid.isNotEmpty) {
                  return Column(
                    children: [
                      PaymentStatusCardNew(userId: profileState.user.uid),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Settings Options
            Column(
              children: [
                // Account Information
                _buildSettingsCard(
                  icon: Icons.account_circle,
                  title: 'Account Information',
                  subtitle: 'View and edit your profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (context) => const CurrentUserAccountPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Theme Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildSettingsCard(
                      icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      title: 'Theme',
                      subtitle: themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Notifications (placeholder for future implementation)
                _buildSettingsCard(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications settings coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Privacy (placeholder for future implementation)
                _buildSettingsCard(
                  icon: Icons.privacy_tip,
                  title: 'Privacy',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy settings coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                if (_isAdmin) ...[
                  _buildSettingsCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Panel',
                    subtitle: 'Access administrative functions',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (context) => const AdminPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Developer Tools Navigation (only in debug/staging)
                if (kDebugMode || FlavorConfig.instance.name == 'DEVELOPMENT') ...[
                  _buildSettingsCard(
                    icon: Icons.developer_mode,
                    title: 'Developer Tools',
                    subtitle: 'Testing and debugging utilities',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const DeveloperToolsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                _buildSettingsCard(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirm Logout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout == true && mounted) {
                      // Show loading dialog
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text('Logging out...'),
                              ],
                            ),
                          );
                        },
                      );

                      await _handleLogout(context);

                      // Close loading dialog
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Text(
                  'Version ${packageInfo.version} (Build ${packageInfo.buildNumber})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      debugPrint('Starting logout process...');

      final authBloc = context.read<AuthBloc>();

      // Add logout event
      authBloc.add(SignoutRequestedEvent());

      // Wait for the logout to complete by listening to state changes
      await authBloc.stream
          .firstWhere(
        (state) => state.authStatus == AuthStatus.unauthenticated,
        orElse: () => authBloc.state,
      )
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Logout timeout - forcing navigation');
          return authBloc.state;
        },
      );

      debugPrint('Logout completed, navigating to signin page');

      // Navigate directly to signin page after logout completes
      if (mounted) {
        AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Still navigate to signin page even if logout fails
      if (mounted) {
        AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
      }
    }
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final color = title == 'Logout' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32.sp,
                color: isDark ? theme.colorScheme.primary : theme.colorScheme.secondary,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
