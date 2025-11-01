/// Notification type enum
enum NotificationType {
  meeting('meeting'),
  announcement('announcement'),
  payment('payment'),
  post('post'),
  general('general');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

/// Target type for notifications
enum NotificationTarget {
  user('user'),
  topic('topic');

  const NotificationTarget(this.value);
  final String value;

  static NotificationTarget fromString(String value) {
    return NotificationTarget.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationTarget.topic,
    );
  }
}

/// Represents a push notification payload for Firebase Cloud Messaging.
///
/// This model handles notification data for:
/// - Different notification types (meeting, announcement, payment, post, general)
/// - Targeting specific users or topics
/// - Deep linking to specific pages
/// - Rich notifications with images
///
/// Example:
/// ```dart
/// final notification = PushNotification(
///   title: 'New Meeting',
///   body: 'Monthly meeting scheduled for tomorrow',
///   type: NotificationType.meeting,
///   target: NotificationTarget.topic,
///   targetValue: 'announcements',
///   deepLinkData: {'meetingId': '123'},
///   imageUrl: 'https://example.com/image.jpg',
/// );
/// ```
class PushNotification {
  PushNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.target,
    this.targetValue,
    this.deepLinkData,
    this.imageUrl,
    this.sound,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String? ?? 'general'),
      target: NotificationTarget.fromString(
          json['target'] as String? ?? 'topic',),
      targetValue: json['targetValue'] as String?,
      deepLinkData: json['deepLinkData'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      sound: json['sound'] as String?,
    );
  }

  final String title;
  final String body;
  final NotificationType type;
  final NotificationTarget target;
  final String? targetValue; // userId or topic name
  final Map<String, dynamic>? deepLinkData; // Data for deep linking
  final String? imageUrl; // For rich notifications
  final String? sound; // Custom notification sound

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type.value,
      'target': target.value,
      'targetValue': targetValue,
      'deepLinkData': deepLinkData,
      'imageUrl': imageUrl,
      'sound': sound,
    };
  }

  Map<String, dynamic> toFcmPayload() {
    final payload = <String, dynamic>{
      'notification': {
        'title': title,
        'body': body,
        if (imageUrl != null) 'image': imageUrl,
      },
      'data': {
        'type': type.value,
        if (deepLinkData != null) ...deepLinkData!,
      },
      if (sound != null) 'sound': sound,
    };

    return payload;
  }

  PushNotification copyWith({
    String? title,
    String? body,
    NotificationType? type,
    NotificationTarget? target,
    String? targetValue,
    Map<String, dynamic>? deepLinkData,
    String? imageUrl,
    String? sound,
  }) {
    return PushNotification(
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      target: target ?? this.target,
      targetValue: targetValue ?? this.targetValue,
      deepLinkData: deepLinkData ?? this.deepLinkData,
      imageUrl: imageUrl ?? this.imageUrl,
      sound: sound ?? this.sound,
    );
  }

  @override
  String toString() {
    return 'PushNotification(title: $title, type: ${type.value}, '
        'target: ${target.value})';
  }
}

