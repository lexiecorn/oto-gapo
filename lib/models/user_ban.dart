import 'package:pocketbase/pocketbase.dart';

/// Enum for ban types
enum BanType {
  post('post', 'Post Ban'),
  comment('comment', 'Comment Ban'),
  all('all', 'Full Ban');

  const BanType(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Get BanType from string value
  static BanType fromValue(String value) {
    return BanType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BanType.all,
    );
  }
}

/// Represents a user ban
class UserBan {
  const UserBan({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bannedBy,
    required this.bannerName,
    required this.banReason,
    required this.banType,
    required this.isPermanent,
    this.banExpiresAt,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String bannedBy;
  final String bannerName;
  final String banReason;
  final BanType banType;
  final bool isPermanent;
  final DateTime? banExpiresAt;
  final bool isActive;
  final DateTime createdAt;

  /// Whether the ban has expired
  bool get isExpired {
    if (isPermanent) return false;
    if (banExpiresAt == null) return false;
    return DateTime.now().isAfter(banExpiresAt!);
  }

  /// Whether the ban is currently in effect
  bool get isEffective => isActive && !isExpired;

  /// Factory constructor to create a UserBan from PocketBase RecordModel
  factory UserBan.fromRecord(RecordModel record) {
    final data = record.data;

    // Extract banned user info from expanded relation
    var userName = 'Unknown User';
    try {
      final userRecord = record.get<RecordModel?>('expand.user_id');
      if (userRecord != null) {
        final firstName = userRecord.data['firstName'] as String? ?? '';
        final lastName = userRecord.data['lastName'] as String? ?? '';
        userName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      // Expand not available, use default values
    }

    // Extract banner info from expanded relation
    var bannerName = 'Unknown Admin';
    try {
      final bannerRecord = record.get<RecordModel?>('expand.banned_by');
      if (bannerRecord != null) {
        final firstName = bannerRecord.data['firstName'] as String? ?? '';
        final lastName = bannerRecord.data['lastName'] as String? ?? '';
        bannerName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      // Expand not available, use default values
    }

    final banTypeValue = data['ban_type'] as String? ?? 'all';

    DateTime? banExpiresAt;
    if (data['ban_expires_at'] != null && data['ban_expires_at'] != '') {
      try {
        banExpiresAt = DateTime.parse(data['ban_expires_at'] as String);
      } catch (_) {
        banExpiresAt = null;
      }
    }

    return UserBan(
      id: record.id,
      userId: data['user_id'] as String? ?? '',
      userName: userName,
      bannedBy: data['banned_by'] as String? ?? '',
      bannerName: bannerName,
      banReason: data['ban_reason'] as String? ?? '',
      banType: BanType.fromValue(banTypeValue),
      isPermanent: data['is_permanent'] as bool? ?? false,
      banExpiresAt: banExpiresAt,
      isActive: data['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(record.get<String>('created')),
    );
  }

  /// Copy with method for creating modified copies
  UserBan copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bannedBy,
    String? bannerName,
    String? banReason,
    BanType? banType,
    bool? isPermanent,
    DateTime? banExpiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserBan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bannedBy: bannedBy ?? this.bannedBy,
      bannerName: bannerName ?? this.bannerName,
      banReason: banReason ?? this.banReason,
      banType: banType ?? this.banType,
      isPermanent: isPermanent ?? this.isPermanent,
      banExpiresAt: banExpiresAt ?? this.banExpiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserBan(id: $id, userId: $userId, banType: ${banType.value}, isPermanent: $isPermanent)';
  }
}
