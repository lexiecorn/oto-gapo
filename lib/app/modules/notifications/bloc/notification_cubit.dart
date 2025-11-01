import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/services/notification_service.dart';

part 'notification_state.dart';

/// Cubit for managing notification state and operations.
///
/// Handles:
/// - FCM token management
/// - Topic subscriptions
/// - Permission status
/// - Notification settings
///
/// Example:
/// ```dart
/// final cubit = NotificationCubit(notificationService: service);
/// await cubit.loadNotificationStatus();
/// await cubit.subscribeToTopic('announcements');
/// ```
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required this.notificationService,
  }) : super(NotificationState.initial());

  final NotificationService notificationService;

  /// Loads current notification status (permissions, token, topics).
  Future<void> loadNotificationStatus() async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      final hasPermission = await notificationService.hasPermission();
      final token = notificationService.currentToken;

      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          permissionGranted: hasPermission,
          fcmToken: token,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Gets/refreshes FCM token.
  Future<void> getFcmToken() async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      final token = await notificationService.getToken();

      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          fcmToken: token,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Subscribes to a notification topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await notificationService.subscribeToTopic(topic);

      final updatedTopics = List<String>.from(state.subscribedTopics);
      if (!updatedTopics.contains(topic)) {
        updatedTopics.add(topic);
      }

      emit(
        state.copyWith(
          subscribedTopics: updatedTopics,
          status: NotificationStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Unsubscribes from a notification topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await notificationService.unsubscribeFromTopic(topic);

      final updatedTopics = List<String>.from(state.subscribedTopics)
        ..remove(topic);

      emit(
        state.copyWith(
          subscribedTopics: updatedTopics,
          status: NotificationStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Gets available notification topics.
  List<String> getAvailableTopics() {
    return notificationService.getAvailableTopics();
  }

  /// Deletes FCM token (for logout).
  Future<void> deleteToken() async {
    try {
      await notificationService.deleteToken();

      emit(
        state.copyWith(
          fcmToken: null,
          status: NotificationStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Resets notification state.
  void reset() {
    emit(NotificationState.initial());
  }
}

