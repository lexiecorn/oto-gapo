import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pocketbase/pocketbase.dart';

/// Service for managing Firebase Cloud Messaging (FCM) notifications.
///
/// This service handles:
/// - FCM token generation and storage
/// - Topic subscriptions
/// - Notification permission management
/// - Token updates and synchronization with PocketBase
/// - Local notifications display (for foreground messages on Android)
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
  late final FlutterLocalNotificationsPlugin _localNotifications;
  String? _currentToken;

  /// Get PocketBase instance from singleton
  PocketBase get _pocketBase => PocketBaseAuthRepository().pocketBase;

  /// Gets the current FCM token.
  String? get currentToken => _currentToken;

  /// Initializes the notification service.
  ///
  /// Requests permissions and sets up notification handlers.
  Future<void> initialize() async {
    try {
      log('NotificationService: ===== STARTING INITIALIZATION =====');
      log('NotificationService: FirebaseMessaging instance created');

      // Initialize local notifications plugin for foreground notification display
      log('NotificationService: Initializing FlutterLocalNotificationsPlugin...');
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings (optional, but required for initialization)
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Initialize the plugin
      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          log('NotificationService: Local notification tapped: ${details.payload}');
        },
      );
      
      log('NotificationService: Local notifications initialized: $initialized');

      // Request notification permissions
      log('NotificationService: Step 1: Requesting permissions...');
      try {
        final hasPermission = await _requestPermissions().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            log('NotificationService: Permission request TIMEOUT after 10 seconds');
            return false;
          },
        );
        log('NotificationService: Permission request completed. Result: $hasPermission');
      } catch (e, stackTrace) {
        log('NotificationService: Error requesting permissions: $e');
        log('NotificationService: Stack trace: $stackTrace');
      }

      // Get initial token
      log('NotificationService: Step 2: Getting FCM token...');
      try {
        _currentToken = await _firebaseMessaging.getToken().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            log('NotificationService: Get token TIMEOUT after 15 seconds');
            return null;
          },
        );
        log('NotificationService: Initial token obtained: $_currentToken');
        log('NotificationService: Token length: ${_currentToken?.length ?? 0}');
        if (_currentToken == null) {
          log('NotificationService: WARNING - Token is null!');
        }
      } catch (e, stackTrace) {
        log('NotificationService: Error getting token: $e');
        log('NotificationService: Stack trace: $stackTrace');
        _currentToken = null;
      }

      // Save token to PocketBase if user is authenticated
      log('NotificationService: Step 3: Checking authentication status...');
      final isAuthenticated = _pocketBase.authStore.isValid;
      log('NotificationService: Is authenticated: $isAuthenticated');
      if (_currentToken != null && isAuthenticated) {
        log('NotificationService: Saving token to PocketBase...');
        try {
          await _saveFcmTokenToUser(_currentToken!).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              log('NotificationService: Save token to PocketBase TIMEOUT');
            },
          );
        } catch (e) {
          log('NotificationService: Error saving token to PocketBase: $e');
        }
      } else {
        if (_currentToken == null) {
          log('NotificationService: Skipping PocketBase save - no token');
        } else {
          log('NotificationService: Skipping PocketBase save - not authenticated');
        }
      }

      // Listen for token refresh
      log('NotificationService: Step 4: Setting up token refresh listener...');
      try {
        _firebaseMessaging.onTokenRefresh.listen((String newToken) {
          log('NotificationService: ===== TOKEN REFRESHED =====');
          log('NotificationService: Old token: $_currentToken');
          log('NotificationService: New token: $newToken');
          _currentToken = newToken;
          if (_pocketBase.authStore.isValid) {
            _saveFcmTokenToUser(newToken);
          } else {
            log('NotificationService: User not authenticated, token not saved to PocketBase');
          }
        });
        log('NotificationService: Token refresh listener set up successfully');
      } catch (e) {
        log('NotificationService: Error setting up token refresh listener: $e');
      }

      // Print diagnostic information
      await _printDiagnostics();

      log('NotificationService: ===== INITIALIZATION COMPLETE =====');
      log('NotificationService: Message listeners should be set up in AppView');
      log('NotificationService: Use printToken() to see your FCM token for testing');
    } catch (e, stackTrace) {
      log('NotificationService: ===== INITIALIZATION ERROR =====');
      log('NotificationService: Error: $e');
      log('NotificationService: Stack trace: $stackTrace');
    }
  }

  /// Prints diagnostic information about notification setup.
  Future<void> _printDiagnostics() async {
    log('NotificationService: ===== DIAGNOSTICS =====');
    log('NotificationService: Current FCM Token: $_currentToken');
    log('NotificationService: Token is ${_currentToken == null ? "NULL - ERROR!" : "PRESENT"}');
    if (_currentToken != null) {
      log('NotificationService: Token length: ${_currentToken!.length}');
      log('NotificationService: Token preview: ${_currentToken!.substring(0, _currentToken!.length > 50 ? 50 : _currentToken!.length)}...');
    }

    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      log('NotificationService: Authorization Status: ${settings.authorizationStatus}');
      log('NotificationService: Alert Enabled: ${settings.alert}');
      log('NotificationService: Badge Enabled: ${settings.badge}');
      log('NotificationService: Sound Enabled: ${settings.sound}');
    } catch (e) {
      log('NotificationService: Error getting notification settings: $e');
    }

    final isAuthenticated = _pocketBase.authStore.isValid;
    log('NotificationService: User Authenticated: $isAuthenticated');

    log('NotificationService: ===== END DIAGNOSTICS =====');
  }

  /// Prints the current FCM token to console (useful for testing).
  /// Call this method to see your token for Firebase Console testing.
  Future<void> printToken() async {
    log('NotificationService: ===== FCM TOKEN =====');
    if (_currentToken == null) {
      log('NotificationService: Token is null, attempting to get new token...');
      _currentToken = await _firebaseMessaging.getToken();
    }

    if (_currentToken != null) {
      log('NotificationService: YOUR FCM TOKEN (copy this to Firebase Console):');
      log('NotificationService: $_currentToken');
      log('NotificationService: Token length: ${_currentToken!.length}');
      log('NotificationService: ===== END FCM TOKEN =====');
    } else {
      log('NotificationService: ERROR - Could not obtain FCM token!');
      log('NotificationService: Check permissions and Firebase setup');
    }
  }

  /// Requests notification permissions from the user.
  Future<bool> _requestPermissions() async {
    try {
      log('NotificationService: Calling FirebaseMessaging.requestPermission()...');
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('NotificationService: Permission request returned');
      log('NotificationService: Authorization status: ${settings.authorizationStatus}');
      log('NotificationService: Alert: ${settings.alert}');
      log('NotificationService: Badge: ${settings.badge}');
      log('NotificationService: Sound: ${settings.sound}');
      log('NotificationService: Announcement: ${settings.announcement}');
      log('NotificationService: CarPlay: ${settings.carPlay}');
      log('NotificationService: CriticalAlert: ${settings.criticalAlert}');

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      log('NotificationService: Is authorized: $isAuthorized');

      return isAuthorized;
    } catch (e, stackTrace) {
      log('NotificationService: Permission request error: $e');
      log('NotificationService: Stack trace: $stackTrace');
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

  /// Saves the current FCM token to PocketBase if user is authenticated.
  /// Call this after user logs in to ensure token is saved.
  Future<void> saveCurrentTokenIfAuthenticated() async {
    if (_currentToken == null) {
      log('NotificationService: No FCM token to save');
      return;
    }

    if (!_pocketBase.authStore.isValid) {
      log('NotificationService: User not authenticated, cannot save token');
      return;
    }

    log('NotificationService: Attempting to save FCM token');
    await _saveFcmTokenToUser(_currentToken!);
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

      log('NotificationService: ===== SAVING FCM TOKEN =====');
      log('NotificationService: User ID: $userId');
      log('NotificationService: Token to save: $token');
      log('NotificationService: Token length: ${token.length}');

      // Get current token from PocketBase to compare
      try {
        final userRecord = await _pocketBase.collection('users').getOne(userId);
        final currentSavedToken = userRecord.data['fcm_token'] as String?;
        if (currentSavedToken != null && currentSavedToken != token) {
          log('NotificationService: WARNING - Token mismatch!');
          log('NotificationService: Saved token: $currentSavedToken');
          log('NotificationService: New token: $token');
          log('NotificationService: Updating to new token...');
        } else if (currentSavedToken == token) {
          log('NotificationService: Token already up-to-date in PocketBase');
          return;
        } else {
          log('NotificationService: No existing token in PocketBase, saving new token');
        }
      } catch (e) {
        log('NotificationService: Could not fetch current token from PocketBase: $e');
        log('NotificationService: Proceeding with save anyway...');
      }

      // Update user record with FCM token
      await _pocketBase.collection('users').update(
        userId,
        body: {'fcm_token': token},
      );

      log('NotificationService: ✅ FCM token saved successfully to PocketBase');
      log('NotificationService: ===== END SAVE FCM TOKEN =====');
    } catch (e, stackTrace) {
      log('NotificationService: ❌ ERROR saving FCM token: $e');
      log('NotificationService: Stack trace: $stackTrace');
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
    try {
      log('NotificationService: Checking for initial message (app opened from notification)...');
      final message = await _firebaseMessaging.getInitialMessage();
      if (message != null) {
        log('NotificationService: ===== INITIAL MESSAGE FOUND =====');
        log('NotificationService: Message ID: ${message.messageId}');
        log('NotificationService: Title: ${message.notification?.title}');
        log('NotificationService: Body: ${message.notification?.body}');
        log('NotificationService: Data: ${message.data}');
      } else {
        log('NotificationService: No initial message found (app not opened from notification)');
      }
      return message;
    } catch (e) {
      log('NotificationService: Error getting initial message: $e');
      return null;
    }
  }

  /// Displays a local notification for foreground messages.
  /// This is required on Android to show notifications when app is in foreground.
  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'otogapo_notifications',
        'OtoGapo Notifications',
        channelDescription: 'OtoGapo push notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new message',
        notificationDetails,
        payload: message.messageId,
      );

      log('NotificationService: Local notification displayed successfully');
    } catch (e) {
      log('NotificationService: Error displaying local notification: $e');
    }
  }
}

/// Top-level function for handling background messages.
///
/// This must be at the top level (not inside a class) for Flutter to find it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Print to console multiple times to ensure visibility
  print('');
  print('========================================');
  print('BACKGROUND MESSAGE RECEIVED!');
  print('========================================');
  log('NotificationService: ===== BACKGROUND MESSAGE RECEIVED =====');
  log('NotificationService: Message ID: ${message.messageId}');
  log('NotificationService: From: ${message.from}');
  log('NotificationService: Sent Time: ${message.sentTime}');
  log('NotificationService: Collapse Key: ${message.collapseKey}');
  log('NotificationService: Message Type: ${message.messageType}');
  log('NotificationService: Title: ${message.notification?.title ?? "NO TITLE"}');
  log('NotificationService: Body: ${message.notification?.body ?? "NO BODY"}');
  log('NotificationService: Click Action: ${message.notification?.android?.clickAction}');
  log('NotificationService: Data: ${message.data}');
  log('NotificationService: Notification data: ${message.notification?.toMap()}');
  log('NotificationService: ===== END BACKGROUND MESSAGE =====');
  print('========================================');
  print('');
}
