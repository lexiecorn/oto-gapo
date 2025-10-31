import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/models/push_notification.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

@RoutePage(name: 'SendNotificationPageRouter')
class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _firebaseServerKeyController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  NotificationTarget _selectedTarget = NotificationTarget.topic;
  String? _selectedUserId;
  String? _selectedTopic;

  List<RecordModel> _users = [];
  bool _isLoadingUsers = false;

  final PocketBaseService _pbService = PocketBaseService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _firebaseServerKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await _pbService.getAllUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTarget == NotificationTarget.user && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTarget == NotificationTarget.topic && _selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a topic'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_firebaseServerKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase Server Key is required to send notifications'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _sendFcmNotification();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _titleController.clear();
      _bodyController.clear();
      _firebaseServerKeyController.clear();
      setState(() {
        _selectedUserId = null;
        _selectedTopic = null;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendFcmNotification() async {
    final notification = PushNotification(
      title: _titleController.text,
      body: _bodyController.text,
      type: _selectedType,
      target: _selectedTarget,
      targetValue:
          _selectedTarget == NotificationTarget.user ? _selectedUserId : _selectedTopic,
      deepLinkData: _buildDeepLinkData(),
    );

    final payload = notification.toFcmPayload();

    // Add target (token or topic)
    if (_selectedTarget == NotificationTarget.user && _selectedUserId != null) {
      // Get user's FCM token from PocketBase
      final userRecord = await _pbService.getUser(_selectedUserId!);
      final fcmToken = userRecord?.data['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        throw Exception('User does not have an FCM token registered');
      }

      payload['to'] = fcmToken;
    } else if (_selectedTopic != null) {
      payload['to'] = '/topics/$_selectedTopic';
    }

    // Send to FCM REST API
    await _sendFcmRestRequest(payload);
  }

  Map<String, dynamic>? _buildDeepLinkData() {
    // Build deep link data based on notification type
    switch (_selectedType) {
      case NotificationType.meeting:
        return {'meetingId': 'placeholder-meeting-id'};
      case NotificationType.post:
        return {'postId': 'placeholder-post-id'};
      case NotificationType.payment:
        return {'paymentId': 'placeholder-payment-id'};
      default:
        return null;
    }
  }

  Future<void> _sendFcmRestRequest(Map<String, dynamic> payload) async {
    final serverKey = _firebaseServerKeyController.text;
    final dio = getIt<Dio>();

    try {
      final response = await dio.post<Map<String, dynamic>>(
        'https://fcm.googleapis.com/fcm/send',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'key=$serverKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.data != null && response.data!.containsKey('message_id')) {
        // Success
        debugPrint('FCM notification sent successfully: ${response.data}');
      } else {
        throw Exception('Failed to send notification: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('FCM send error: ${e.response?.data}');
      throw Exception('Failed to send notification: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Push Notification'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Body
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Type
            DropdownButtonFormField<NotificationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Notification Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: NotificationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.value.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),

            // Target type (user or topic)
            DropdownButtonFormField<NotificationTarget>(
              value: _selectedTarget,
              decoration: const InputDecoration(
                labelText: 'Send To',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              items: [
                const DropdownMenuItem(
                  value: NotificationTarget.topic,
                  child: Text('All Members (Topic)'),
                ),
                const DropdownMenuItem(
                  value: NotificationTarget.user,
                  child: Text('Specific User'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTarget = value;
                    _selectedUserId = null;
                    _selectedTopic = null;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),

            // Topic or User selector
            if (_selectedTarget == NotificationTarget.topic) ...[
              DropdownButtonFormField<String>(
                value: _selectedTopic,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.campaign),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'announcements',
                    child: Text('Announcements'),
                  ),
                  DropdownMenuItem(
                    value: 'meetings',
                    child: Text('Meetings'),
                  ),
                  DropdownMenuItem(
                    value: 'urgent',
                    child: Text('Urgent'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTopic = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a topic';
                  }
                  return null;
                },
              ),
            ] else ...[
              if (_isLoadingUsers)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Select User',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: _users.map((user) {
                    final name =
                        '${user.data['firstName'] ?? ''} ${user.data['lastName'] ?? ''}';
                    final email = user.data['email'] ?? '';
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.trim(), overflow: TextOverflow.ellipsis),
                          Text(
                            email.toString(),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a user';
                    }
                    return null;
                  },
                ),
            ],
            SizedBox(height: 16.h),

            // Firebase Server Key (for admin)
            TextFormField(
              controller: _firebaseServerKeyController,
              decoration: InputDecoration(
                labelText: 'Firebase Server Key',
                hintText: 'Get from Firebase Console > Project Settings > Cloud Messaging',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                helperText:
                    'Required to send notifications via FCM REST API',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Firebase Server Key is required';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),

            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        SizedBox(width: 8.w),
                        Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Firebase Server Key is required to send notifications from the admin panel. You can find it in Firebase Console under Project Settings > Cloud Messaging > Server Key.',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Send button
            ElevatedButton.icon(
              onPressed: _sendNotification,
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

