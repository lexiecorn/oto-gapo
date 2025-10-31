import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketbase/pocketbase.dart';

/// Service for managing Firebase Cloud Messaging (FCM) notifications.
///
/// This service handles:
/// - FCM token generation and storage
/// - Topic subscriptions
/// - Notification permission management
/// - Token updates and synchronization with PocketBase
///
/// Example:
/// ```dart
/// final notificationService = NotificationService();
/// await notificationService.initialize();
/// final token = await notificationService.getToken();
/// ```
class NotificationService {
  NotificationService() {
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  late final FirebaseMessaging _firebaseMessaging;
  String? _currentToken;
  final PocketBase _pocketBase = PocketBaseAuthRepository().pocketBase;

  /// Gets the current FCM token.
  String? get currentToken => _currentToken;

  /// Initializes the notification service.
  ///
  /// Requests permissions and sets up notification handlers.
  Future<void> initialize() async {
    try {
      log('NotificationService: Initializing...');

      // Request notification permissions
      await _requestPermissions();

      // Get initial token
      _currentToken = await _firebaseMessaging.getToken();
      log('NotificationService: Initial token obtained');

      // Save token to PocketBase if user is authenticated
      if (_currentToken != null && _pocketBase.authStore.isValid) {
        await _saveFcmTokenToUser(_currentToken!);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String newToken) {
        log('NotificationService: Token refreshed: $newToken');
        _currentToken = newToken;
        if (_pocketBase.authStore.isValid) {
          _saveFcmTokenToUser(newToken);
        }
      });

      log('NotificationService: Initialization complete');
    } catch (e) {
      log('NotificationService: Initialization error: $e');
    }
  }

  /// Requests notification permissions from the user.
  Future<bool> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('NotificationService: Permission status: ${settings.authorizationStatus}');

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('NotificationService: Permission request error: $e');
      return false;
    }
  }

  /// Gets the FCM token for this device.
  Future<String?> getToken() async {
    try {
      _currentToken = await _firebaseMessaging.getToken();
      log('NotificationService: Token obtained');

      // Save to PocketBase if authenticated
      if (_currentToken != null && _pocketBase.authStore.isValid) {
        await _saveFcmTokenToUser(_currentToken!);
      }

      return _currentToken;
    } catch (e) {
      log('NotificationService: Get token error: $e');
      return null;
    }
  }

  /// Saves FCM token to PocketBase user record.
  Future<void> _saveFcmTokenToUser(String token) async {
    try {
      if (!_pocketBase.authStore.isValid) {
        log('NotificationService: Not authenticated, skipping token save');
        return;
      }

      final userId = _pocketBase.authStore.model?.id as String?;
      if (userId == null) {
        log('NotificationService: No user ID available, skipping token save');
        return;
      }

      log('NotificationService: Saving FCM token for user: $userId');

      // Update user record with FCM token
      await _pocketBase.collection('users').update(
            userId,
            body: {'fcm_token': token},
          );

      log('NotificationService: FCM token saved successfully');
    } catch (e) {
      log('NotificationService: Error saving FCM token: $e');
    }
  }

  /// Subscribes to a notification topic.
  ///
  /// Topics allow sending notifications to groups of users:
  /// - 'announcements' - General announcements
  /// - 'meetings' - Meeting notifications
  /// - 'urgent' - Urgent notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('NotificationService: Subscribed to topic: $topic');

      // Update user record in PocketBase
      if (_pocketBase.authStore.isValid) {
        await _updateUserTopics();
      }
    } catch (e) {
      log('NotificationService: Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribes from a notification topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('NotificationService: Unsubscribed from topic: $topic');

      // Update user record in PocketBase
      if (_pocketBase.authStore.isValid) {
        await _updateUserTopics();
      }
    } catch (e) {
      log('NotificationService: Error unsubscribing from topic $topic: $e');
    }
  }

  /// Updates user's topic subscriptions in PocketBase.
  Future<void> _updateUserTopics() async {
    try {
      if (!_pocketBase.authStore.isValid) {
        return;
      }

      final userId = _pocketBase.authStore.model?.id as String?;
      if (userId == null) {
        return;
      }

      // Get current user's topic subscriptions
      final userTopics = await _getUserTopics();

      // Update PocketBase record
      await _pocketBase.collection('users').update(
            userId,
            body: {'notification_topics': userTopics},
          );

      log('NotificationService: User topics updated: $userTopics');
    } catch (e) {
      log('NotificationService: Error updating user topics: $e');
    }
  }

  /// Gets list of topics the user is subscribed to.
  ///
  /// Note: FCM doesn't provide an API to query subscriptions,
  /// so we maintain this list locally or in PocketBase.
  Future<List<String>> _getUserTopics() async {
    try {
      if (!_pocketBase.authStore.isValid) {
        return [];
      }

      final userId = _pocketBase.authStore.model?.id as String?;
      if (userId == null) {
        return [];
      }

      final userRecord = await _pocketBase.collection('users').getOne(userId);
      final topics = userRecord.data['notification_topics'];

      if (topics is List) {
        return topics.map((e) => e.toString()).toList();
      }

      return [];
    } catch (e) {
      log('NotificationService: Error getting user topics: $e');
      return [];
    }
  }

  /// Gets list of available notification topics.
  List<String> getAvailableTopics() {
    return ['announcements', 'meetings', 'urgent'];
  }

  /// Checks if user has granted notification permissions.
  Future<bool> hasPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('NotificationService: Error checking permission: $e');
      return false;
    }
  }

  /// Deletes the FCM token (used for logout).
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      log('NotificationService: Token deleted');
    } catch (e) {
      log('NotificationService: Error deleting token: $e');
    }
  }

  /// Gets the initial message if app was opened from a notification.
  Future<RemoteMessage?> getInitialMessage() async {
    return _firebaseMessaging.getInitialMessage();
  }
}

/// Top-level function for handling background messages.
///
/// This must be at the top level (not inside a class) for Flutter to find it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('NotificationService: Background message received: ${message.messageId}');
  log('NotificationService: Notification title: ${message.notification?.title}');
  log('NotificationService: Notification body: ${message.notification?.body}');
  log('NotificationService: Data: ${message.data}');
}

