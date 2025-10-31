part of 'notification_cubit.dart';

/// Status of notification operations.
enum NotificationStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for notification management.
class NotificationState extends Equatable {
  const NotificationState({
    required this.status,
    required this.permissionGranted,
    this.fcmToken,
    this.subscribedTopics = const [],
    this.errorMessage,
  });

  /// Initial state
  factory NotificationState.initial() {
    return const NotificationState(
      status: NotificationStatus.initial,
      permissionGranted: false,
      subscribedTopics: [],
    );
  }

  /// Current notification status.
  final NotificationStatus status;

  /// Whether notification permissions are granted.
  final bool permissionGranted;

  /// Current FCM token.
  final String? fcmToken;

  /// Topics the user is subscribed to.
  final List<String> subscribedTopics;

  /// Error message if status is error.
  final String? errorMessage;

  @override
  List<Object?> get props => [
        status,
        permissionGranted,
        fcmToken,
        subscribedTopics,
        errorMessage,
      ];

  @override
  String toString() =>
      'NotificationState(status: $status, permissionGranted: $permissionGranted, '
      'fcmToken: ${fcmToken != null ? '***' : null}, subscribedTopics: $subscribedTopics, '
      'errorMessage: $errorMessage)';

  /// Creates a copy with updated fields.
  NotificationState copyWith({
    NotificationStatus? status,
    bool? permissionGranted,
    String? fcmToken,
    List<String>? subscribedTopics,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      fcmToken: fcmToken ?? this.fcmToken,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

