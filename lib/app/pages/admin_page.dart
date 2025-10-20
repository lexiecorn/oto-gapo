import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/admin_analytics/bloc/admin_analytics_cubit.dart';
import 'package:otogapo/app/modules/admin_analytics/bloc/admin_analytics_state.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/analytics_page.dart';
import 'package:otogapo/app/pages/gallery_management_page.dart';
import 'package:otogapo/app/pages/payment_management_page_new.dart';
import 'package:otogapo/app/pages/user_management_page.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/admin_stat_card.dart';
import 'package:otogapo/app/widgets/skeleton_loader.dart';
import 'package:otogapo/services/pocketbase_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    // Wait a bit for user data to load
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted && _isAdmin) {
      context.read<AdminAnalyticsCubit>().loadDashboardStats();
    }
  }

  Future<void> _loadCurrentUserData() async {
    try {
      // Prefer profile state which is already loaded and consistent
      final profileState = context.read<ProfileCubit>().state;
      final profileUser = profileState.user;

      if (profileState.profileStatus == ProfileStatus.loaded && profileUser.uid.isNotEmpty) {
        setState(() {
          _isAdmin = (profileUser.membership_type == 1) || (profileUser.membership_type == 2);
          _isLoading = false;
        });
        return;
      }

      // Fallback: resolve PocketBase user by email
      final pocketBaseService = PocketBaseService();
      final authBloc = context.read<ProfileCubit>();
      final profileUserFallback = authBloc.state.user;
      
      if (profileUserFallback.uid.isNotEmpty) {
        setState(() {
          _isAdmin = (profileUserFallback.membership_type == 1) || (profileUserFallback.membership_type == 2);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminAnalyticsCubit>().refreshAll();
            },
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AdminAnalyticsCubit>().refreshAll();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Statistics
              BlocBuilder<AdminAnalyticsCubit, AdminAnalyticsState>(
                builder: (context, analyticsState) {
                  if (analyticsState.isLoading) {
                    return SizedBox(
                      height: 200.h,
                      child: const SkeletonGrid(itemCount: 4),
                    );
                  }

                  if (analyticsState.hasData) {
                    final stats = analyticsState.dashboardStats;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 1.5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            AdminStatCard(
                              title: 'Total Users',
                              value: stats.totalUsers.toString(),
                              icon: Icons.people,
                              color: Colors.blue.shade600,
                            ),
                            AdminStatCard(
                              title: 'Active Today',
                              value: stats.activeToday.toString(),
                              icon: Icons.online_prediction,
                              color: Colors.green.shade600,
                            ),
                            AdminStatCard(
                              title: 'Pending Payments',
                              value: stats.pendingPayments.toString(),
                              icon: Icons.payment,
                              color: Colors.orange.shade600,
                            ),
                            AdminStatCard(
                              title: 'Avg Attendance',
                              value: '${stats.averageAttendance.toStringAsFixed(1)}%',
                              icon: Icons.show_chart,
                              color: Colors.purple.shade600,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              const Text(
                'Admin Functions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
              SizedBox(height: 20.h),
            ],
          ),
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
}
