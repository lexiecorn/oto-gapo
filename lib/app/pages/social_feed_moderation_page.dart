import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/moderation_cubit.dart';
import 'package:otogapo/models/post_report.dart';
import 'package:otogapo/models/user_ban.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage(name: 'SocialFeedModerationPageRouter')
class SocialFeedModerationPage extends StatefulWidget {
  const SocialFeedModerationPage({super.key});

  @override
  State<SocialFeedModerationPage> createState() =>
      _SocialFeedModerationPageState();
}

class _SocialFeedModerationPageState extends State<SocialFeedModerationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ModerationCubit _moderationCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    _moderationCubit = ModerationCubit(
      pocketBaseService: PocketBaseService(),
      currentUserId: currentUserId,
    );

    // Load initial data
    _moderationCubit.loadReports(status: ReportStatus.pending);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _moderationCubit.loadReports(status: ReportStatus.pending);
        } else if (_tabController.index == 2) {
          _moderationCubit.loadBans(isActive: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _moderationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ModerationCubit>.value(
      value: _moderationCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social Feed Moderation'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.blue,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
            indicatorColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.blue,
            tabs: const [
              Tab(text: 'Reports', icon: Icon(Icons.flag)),
              Tab(text: 'Hidden', icon: Icon(Icons.visibility_off)),
              Tab(text: 'Bans', icon: Icon(Icons.block)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildReportsTab(),
            _buildHiddenContentTab(),
            _buildBansTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return BlocBuilder<ModerationCubit, ModerationState>(
      builder: (context, state) {
        if (state.status == ModerationStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64.sp, color: Colors.green),
                SizedBox(height: 16.h),
                const Text('No pending reports'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _moderationCubit.refreshReports(),
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: state.reports.length,
            itemBuilder: (context, index) {
              final report = state.reports[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report header
                      Row(
                        children: [
                          Icon(
                            _getReportIcon(report.reportReason),
                            size: 20.sp,
                            color: _getReportColor(report.reportReason),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              report.reportReason.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              report.status.displayName,
                              style: TextStyle(fontSize: 11.sp),
                            ),
                            backgroundColor: _getStatusColor(report.status),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Reporter info
                      Text(
                        'Reported by: ${report.reporterName}',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                      Text(
                        timeago.format(report.createdAt),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),

                      // Report details
                      if (report.reportDetails != null &&
                          report.reportDetails!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Details: ${report.reportDetails}',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ],

                      SizedBox(height: 12.h),

                      // Action buttons
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          SizedBox(
                            height: 36.h,
                            child: ElevatedButton.icon(
                              onPressed: () => _hideReportedContent(report),
                              icon: Icon(Icons.visibility_off, size: 16.sp),
                              label: const Text('Hide'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 36.h,
                            child: ElevatedButton.icon(
                              onPressed: () => _deleteReportedContent(report),
                              icon: Icon(Icons.delete, size: 16.sp),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 36.h,
                            child: OutlinedButton.icon(
                              onPressed: () => _dismissReport(report),
                              icon: Icon(Icons.check, size: 16.sp),
                              label: const Text('Dismiss'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 36.h,
                            child: OutlinedButton.icon(
                              onPressed: () => _banReporter(report),
                              icon: Icon(Icons.block, size: 16.sp),
                              label: const Text('Ban User'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHiddenContentTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          const Text('Hidden content management'),
          SizedBox(height: 8.h),
          const Text('Coming soon!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBansTab() {
    return BlocBuilder<ModerationCubit, ModerationState>(
      builder: (context, state) {
        if (state.status == ModerationStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.bans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64.sp, color: Colors.green),
                SizedBox(height: 16.h),
                const Text('No active bans'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _moderationCubit.refreshBans(),
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: state.bans.length,
            itemBuilder: (context, index) {
              final ban = state.bans[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ban.isActive ? Colors.red : Colors.grey,
                    child: Icon(
                      Icons.block,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    ban.userName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: ${ban.banReason}'),
                      Text('Type: ${ban.banType.displayName}'),
                      Text('Banned by: ${ban.bannerName}'),
                      if (!ban.isPermanent && ban.banExpiresAt != null)
                        Text(
                          'Expires: ${timeago.format(ban.banExpiresAt!)}',
                        ),
                      if (ban.isPermanent) const Text('Permanent ban'),
                    ],
                  ),
                  trailing: ban.isActive
                      ? ElevatedButton(
                          onPressed: () => _unbanUser(ban.userId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Unban'),
                        )
                      : const Chip(label: Text('Inactive')),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getReportIcon(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return Icons.report;
      case ReportReason.inappropriate:
        return Icons.warning;
      case ReportReason.harassment:
        return Icons.person_off;
      case ReportReason.other:
        return Icons.help_outline;
    }
  }

  Color _getReportColor(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return Colors.orange;
      case ReportReason.inappropriate:
        return Colors.red;
      case ReportReason.harassment:
        return Colors.deepOrange;
      case ReportReason.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange[100]!;
      case ReportStatus.reviewed:
        return Colors.blue[100]!;
      case ReportStatus.resolved:
        return Colors.green[100]!;
      case ReportStatus.dismissed:
        return Colors.grey[300]!;
    }
  }

  Future<void> _hideReportedContent(PostReport report) async {
    try {
      if (report.isPostReport && report.postId != null) {
        await _moderationCubit.togglePostVisibility(report.postId!, true);
      } else if (report.isCommentReport && report.commentId != null) {
        await _moderationCubit.toggleCommentVisibility(report.commentId!, true);
      }

      await _moderationCubit.reviewReport(
        report.id,
        ReportStatus.resolved,
        'Content hidden',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content hidden successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteReportedContent(PostReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Content',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Are you sure? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Delete',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final pocketBaseService = PocketBaseService();

      if (report.isPostReport && report.postId != null) {
        await pocketBaseService.deletePost(report.postId!);
      } else if (report.isCommentReport && report.commentId != null) {
        await pocketBaseService.deleteComment(report.commentId!);
      }

      await _moderationCubit.reviewReport(
        report.id,
        ReportStatus.resolved,
        'Content deleted',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _dismissReport(PostReport report) async {
    try {
      await _moderationCubit.reviewReport(
        report.id,
        ReportStatus.dismissed,
        'No action needed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report dismissed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _banReporter(PostReport report) async {
    // Show ban dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _BanUserDialog(userName: report.reporterName),
    );

    if (result == null) return;

    try {
      // Get the user ID from the report
      // For now, we'll need to get it from the content being reported
      // This is a placeholder - in production, you'd get the actual content creator
      const userIdToBan = 'USER_ID_HERE'; // TODO: Get from reported content

      await _moderationCubit.banUser(
        userIdToBan,
        result['reason'] as String,
        result['banType'] as BanType,
        result['duration'] as Duration?,
      );

      await _moderationCubit.reviewReport(
        report.id,
        ReportStatus.resolved,
        'User banned: ${result["reason"]}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User banned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _unbanUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unban User',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Are you sure you want to unban this user?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unban',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _moderationCubit.unbanUser(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User unbanned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _BanUserDialog extends StatefulWidget {
  const _BanUserDialog({required this.userName});

  final String userName;

  @override
  State<_BanUserDialog> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends State<_BanUserDialog> {
  final _reasonController = TextEditingController();
  BanType _selectedBanType = BanType.all;
  bool _isPermanent = false;
  int _durationDays = 7;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ban ${widget.userName}',
        style: TextStyle(fontSize: 18.sp),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ban Type:',
                style: TextStyle(fontSize: 14.sp),
              ),
              ...BanType.values.map((type) {
                return RadioListTile<BanType>(
                  title: Text(
                    type.displayName,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  value: type,
                  groupValue: _selectedBanType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBanType = value;
                      });
                    }
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              SizedBox(height: 16.h),
              Text(
                'Reason:',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'Ban reason...',
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 14.sp),
                maxLines: 2,
              ),
              SizedBox(height: 16.h),
              CheckboxListTile(
                title: Text(
                  'Permanent ban',
                  style: TextStyle(fontSize: 14.sp),
                ),
                value: _isPermanent,
                onChanged: (value) {
                  setState(() {
                    _isPermanent = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (!_isPermanent) ...[
                Text(
                  'Duration (days):',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Slider(
                  value: _durationDays.toDouble(),
                  min: 1,
                  max: 90,
                  divisions: 89,
                  label: '$_durationDays days',
                  onChanged: (value) {
                    setState(() {
                      _durationDays = value.toInt();
                    });
                  },
                ),
                Text(
                  '$_durationDays days',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please provide a reason',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'reason': _reasonController.text.trim(),
              'banType': _selectedBanType,
              'duration': _isPermanent ? null : Duration(days: _durationDays),
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'Ban User',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}
