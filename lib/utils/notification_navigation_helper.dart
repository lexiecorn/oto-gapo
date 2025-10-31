import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/models/push_notification.dart';

/// Helper class for handling notification tap navigation and deep linking.
///
/// This class parses notification payloads and navigates users to the
/// appropriate screens based on notification type and data.
class NotificationNavigationHelper {
  /// Handles navigation when a notification is tapped.
  ///
  /// Decodes the notification data and navigates to the appropriate screen.
  ///
  /// Example navigation:
  /// - `meeting` type with meetingId → MeetingDetailsPage
  /// - `announcement` type → AnnouncementsListPage
  /// - `post` type with postId → PostDetailPage
  /// - `general` type → HomePage
  static Future<void> handleNotificationTap(
    RemoteMessage message,
    BuildContext? context,
  ) async {
    try {
      final notificationType = message.data['type'] as String? ?? 'general';
      final type = NotificationType.fromString(notificationType);

      // Get router from GetIt
      final appRouter = getIt<AppRouter>();

      switch (type) {
        case NotificationType.meeting:
          await _handleMeetingNotification(message, appRouter, context);
          break;
        case NotificationType.announcement:
          await _handleAnnouncementNotification(
            message,
            appRouter,
            context,
          );
          break;
        case NotificationType.payment:
          await _handlePaymentNotification(message, appRouter, context);
          break;
        case NotificationType.post:
          await _handlePostNotification(message, appRouter, context);
          break;
        case NotificationType.general:
          await _handleGeneralNotification(appRouter, context);
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
      // If navigation fails, just go to home
      await _handleGeneralNotification(getIt<AppRouter>(), context);
    }
  }

  /// Navigates to meeting details page.
  static Future<void> _handleMeetingNotification(
    RemoteMessage message,
    AppRouter appRouter,
    BuildContext? context,
  ) async {
    final meetingId = message.data['meetingId'] as String?;

    if (meetingId != null && meetingId.isNotEmpty) {
      await appRouter.push(MeetingDetailsPageRouter(meetingId: meetingId));
    } else {
      // If no meeting ID, go to meetings list
      await appRouter.push(const MeetingsListPageRouter());
    }
  }

  /// Navigates to announcements page.
  static Future<void> _handleAnnouncementNotification(
    RemoteMessage message,
    AppRouter appRouter,
    BuildContext? context,
  ) async {
    await appRouter.push(const AnnouncementsListPageRouter());
  }

  /// Navigates to profile page (where payments are shown).
  static Future<void> _handlePaymentNotification(
    RemoteMessage message,
    AppRouter appRouter,
    BuildContext? context,
  ) async {
    await appRouter.push(ProfilePageRouter());
  }

  /// Navigates to post detail page.
  static Future<void> _handlePostNotification(
    RemoteMessage message,
    AppRouter appRouter,
    BuildContext? context,
  ) async {
    final postId = message.data['postId'] as String?;

    if (postId != null && postId.isNotEmpty) {
      await appRouter.push(PostDetailPageRouter(postId: postId));
    } else {
      // If no post ID, go to social feed
      await appRouter.push(const SocialFeedPageRouter());
    }
  }

  /// Navigates to home page for general notifications.
  static Future<void> _handleGeneralNotification(
    AppRouter appRouter,
    BuildContext? context,
  ) async {
    await appRouter.push(const HomePageRouter());
  }

  /// Gets a human-readable notification description for UI display.
  static String getNotificationDescription(RemoteMessage message) {
    final type = message.data['type'] as String? ?? 'general';

    switch (type) {
      case 'meeting':
        return 'Meeting notification';
      case 'announcement':
        return 'Announcement';
      case 'payment':
        return 'Payment notification';
      case 'post':
        return 'New post';
      default:
        return 'Notification';
    }
  }

  /// Checks if notification has deep link data.
  static bool hasDeepLinkData(RemoteMessage message) {
    final type = message.data['type'] as String? ?? 'general';
    final hasId = message.data['meetingId'] != null ||
        message.data['postId'] != null ||
        message.data['paymentId'] != null ||
        message.data['announcementId'] != null;

    return type != 'general' && hasId;
  }
}
