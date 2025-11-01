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

    // No need for Firebase Server Key - using n8n webhook instead

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
      setState(() {
        _selectedUserId = null;
        _selectedTopic = null;
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
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
      targetValue: _selectedTarget == NotificationTarget.user ? _selectedUserId : _selectedTopic,
      deepLinkData: _buildDeepLinkData(),
    );

    // Send directly to n8n webhook (credentials already handled in n8n)
    await _sendToN8nWebhook(notification);
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

  /// Sends notification to n8n webhook which handles FCM HTTP v1 API
  Future<void> _sendToN8nWebhook(PushNotification notification) async {
    final dio = getIt<Dio>();

    // Build payload for n8n webhook
    final Map<String, dynamic> n8nPayload = {
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.toString().split('.').last, // e.g., 'meeting', 'announcement'
      'target': notification.target.toString().split('.').last, // 'user' or 'topic'
    };

    // Add target-specific data
    if (notification.target == NotificationTarget.user && _selectedUserId != null) {
      // Get user's FCM token from PocketBase
      final userRecord = await _pbService.getUser(_selectedUserId!);
      final fcmToken = userRecord?.data['fcm_token'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        throw Exception('User does not have an FCM token registered');
      }

      n8nPayload['fcmToken'] = fcmToken;
    } else if (_selectedTopic != null) {
      n8nPayload['topic'] = _selectedTopic;
    }

    // Add deep link data if available
    if (notification.deepLinkData != null) {
      n8nPayload['data'] = notification.deepLinkData;
    }

    try {
      debugPrint('Sending notification to n8n: $n8nPayload');

      // Send to n8n webhook
      final response = await dio.post<Map<String, dynamic>>(
        'https://n8n.lexserver.org/webhook/fcm-push-notification',
        data: n8nPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint('n8n response status: ${response.statusCode}');
      debugPrint('n8n response data: ${response.data}');

      // Check response from n8n
      if (response.data != null) {
        // n8n may return data as an array (list) or object
        dynamic responseData = response.data;

        // If response is an array, get the first element
        if (responseData is List && responseData.isNotEmpty) {
          responseData = responseData.first;
          debugPrint('n8n returned array response, using first element: $responseData');
        }

        // Ensure we have a Map to work with
        if (responseData is! Map) {
          // If status is 200, assume success even if format is unexpected
          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint('n8n returned status ${response.statusCode} with unexpected format - assuming success');
            return;
          }
          throw Exception('Unexpected response format from n8n: ${response.data}');
        }

        final dataMap = responseData as Map<String, dynamic>;

        // Check for success flag (standard format)
        final success = dataMap['success'] as bool?;

        if (success == true) {
          final message = dataMap['message']?.toString();
          final messageId = dataMap['messageId']?.toString();
          debugPrint('Notification sent successfully via n8n');
          if (message != null) debugPrint('Message: $message');
          if (messageId != null) debugPrint('Message ID: $messageId');
          return; // Success!
        }

        // n8n may return the webhook payload itself if "Respond to Webhook"
        // is configured to respond early or echo the request
        // This is common when "Respond to Webhook" comes before "Send FCM Notification"
        // If we see our payload in the response, consider it a success
        if (dataMap.containsKey('body')) {
          final body = dataMap['body'];
          if (body is Map) {
            // Check if this looks like our request being echoed back
            final hasTitle = body.containsKey('title') && body['title'] == n8nPayload['title'];
            final hasBody = body.containsKey('body') && body['body'] == n8nPayload['body'];
            final hasTarget = body.containsKey('target') && body['target'] == n8nPayload['target'];

            // If n8n returned our payload, it means the webhook was received
            // Since notification was actually sent (user confirmed), this is success
            if (hasTitle && hasBody && hasTarget) {
              debugPrint('n8n returned webhook payload - webhook received successfully');
              debugPrint('Note: n8n "Respond to Webhook" is responding before FCM send completes');
              return; // Success - n8n received the request and will process it
            }
          }
        }

        // Also check if the response itself contains our payload fields directly
        // Some n8n configurations return the payload at the root level
        if (dataMap.containsKey('title') && dataMap.containsKey('body') && dataMap.containsKey('target')) {
          final hasMatchingTitle = dataMap['title'] == n8nPayload['title'];
          final hasMatchingBody = dataMap['body'] == n8nPayload['body'];
          final hasMatchingTarget = dataMap['target'] == n8nPayload['target'];

          if (hasMatchingTitle && hasMatchingBody && hasMatchingTarget) {
            debugPrint('n8n returned payload directly - webhook received successfully');
            return; // Success
          }
        }

        // Check for explicit error
        if (dataMap.containsKey('error')) {
          final error = dataMap['error'];
          String? errorMessage;

          if (error is Map) {
            errorMessage = error['message']?.toString() ?? error['status']?.toString() ?? error.toString();
          } else {
            errorMessage = error.toString();
          }

          throw Exception('Failed to send notification: $errorMessage');
        }

        // Check for error message (only if success is false)
        if (dataMap.containsKey('message') && success != true) {
          final message = dataMap['message']?.toString();
          if (message != null && message.toLowerCase().contains('error')) {
            throw Exception('Failed to send notification: $message');
          }
        }

        // If we get here and status is 200, assume success (n8n received it)
        // This handles cases where n8n doesn't return a formatted response
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('n8n returned status ${response.statusCode} - assuming success');
          debugPrint('Note: Configure n8n to return {success: true} for explicit confirmation');
          return; // Consider HTTP 200/201 as success
        }

        // Last resort: show the response for debugging
        throw Exception('Unexpected response format from n8n. Status: ${response.statusCode}, Data: $dataMap');
      } else {
        // No response body but status might be OK
        if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
          debugPrint('n8n returned status ${response.statusCode} with no body - assuming success');
          return;
        }
        throw Exception('No response data from n8n webhook (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('n8n webhook DioException: ${e.type}');
      debugPrint('n8n webhook error message: ${e.message}');
      debugPrint('n8n webhook response: ${e.response?.data}');
      debugPrint('n8n webhook status code: ${e.response?.statusCode}');

      // Extract error from response if available
      String errorMessage = e.message ?? 'Network error';

      if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          final error = responseData['error'] ?? responseData['message'];
          if (error != null) {
            errorMessage = error.toString();
          } else {
            errorMessage = 'HTTP ${e.response?.statusCode}: ${responseData.toString()}';
          }
        } else {
          errorMessage = 'HTTP ${e.response?.statusCode}: ${responseData.toString()}';
        }
      } else if (e.response?.statusCode != null) {
        errorMessage = 'HTTP ${e.response?.statusCode}: ${e.message}';
      }

      throw Exception('Failed to send notification: $errorMessage');
    } catch (e) {
      debugPrint('Unexpected error sending notification: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
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
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Message Body',
                labelStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.message),
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
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Notification Type',
                labelStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              items: NotificationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.value.toUpperCase(),
                      style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
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
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Send To',
                labelStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.group),
              ),
              items: [
                DropdownMenuItem(
                  value: NotificationTarget.topic,
                  child: Text('All Members (Topic)',
                      style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
                ),
                DropdownMenuItem(
                  value: NotificationTarget.user,
                  child: Text('Specific User', style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
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
                style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Topic',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.campaign),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'announcements',
                    child: Text('Announcements', style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
                  ),
                  DropdownMenuItem(
                    value: 'meetings',
                    child: Text('Meetings', style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
                  ),
                  DropdownMenuItem(
                    value: 'urgent',
                    child: Text('Urgent', style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
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
                  style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Select User',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: _users.map((user) {
                    final name = '${user.data['firstName'] ?? ''} ${user.data['lastName'] ?? ''}';
                    final email = user.data['email'] ?? '';
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.trim(),
                              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis),
                          Text(
                            email.toString(),
                            style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurfaceVariant),
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

            // Info card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.green.shade700),
                        SizedBox(width: 8.w),
                        Text(
                          'Using n8n Webhook',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Notifications are sent via n8n webhook using FCM HTTP v1 API with Google Service Account credentials. No Firebase Server Key needed!',
                      style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface),
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
              label: Text('Send Notification', style: TextStyle(fontSize: 14.sp)),
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
