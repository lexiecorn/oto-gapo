import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/notifications/bloc/notification_cubit.dart';

@RoutePage(name: 'NotificationSettingsPageRouter')
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Permission status
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            state.permissionGranted
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: state.permissionGranted
                                ? Colors.green
                                : Colors.orange,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notification Status',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  state.permissionGranted
                                      ? 'Notifications enabled'
                                      : 'Notifications disabled',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Topic subscriptions
              Text(
                'Topics',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select which types of notifications you want to receive',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),

              // Topic list
              ...context
                  .read<NotificationCubit>()
                  .getAvailableTopics()
                  .map((topic) => _TopicTile(topic: topic)),
              
              SizedBox(height: 24.h),

              // Refresh token button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<NotificationCubit>().getFcmToken();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing notification token...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Token'),
                ),
              ),

              SizedBox(height: 16.h),

              // Admin section
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  // Only show admin section if user is admin
                  // You can check admin status here
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic});

  final String topic;

  String get _displayName {
    switch (topic) {
      case 'announcements':
        return 'Announcements';
      case 'meetings':
        return 'Meeting Notifications';
      case 'urgent':
        return 'Urgent Alerts';
      default:
        return topic;
    }
  }

  String get _description {
    switch (topic) {
      case 'announcements':
        return 'General announcements and updates';
      case 'meetings':
        return 'Meeting schedules and reminders';
      case 'urgent':
        return 'Important urgent messages';
      default:
        return '';
    }
  }

  IconData get _icon {
    switch (topic) {
      case 'announcements':
        return Icons.campaign;
      case 'meetings':
        return Icons.event;
      case 'urgent':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final isSubscribed = state.subscribedTopics.contains(topic);

        return Card(
          child: SwitchListTile(
            title: Row(
              children: [
                Icon(_icon, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            value: isSubscribed,
            onChanged: (value) {
              if (value) {
                context.read<NotificationCubit>().subscribeToTopic(topic);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subscribed to $_displayName'),
                  ),
                );
              } else {
                context.read<NotificationCubit>().unsubscribeFromTopic(topic);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unsubscribed from $_displayName'),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

