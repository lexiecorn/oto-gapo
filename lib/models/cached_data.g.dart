// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedPostAdapter extends TypeAdapter<CachedPost> {
  @override
  final int typeId = 0;

  @override
  CachedPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedPost(
      id: fields[0] as String,
      content: fields[1] as String,
      authorId: fields[2] as String,
      authorName: fields[3] as String,
      createdAt: fields[4] as DateTime,
      cachedAt: fields[5] as DateTime,
      imageUrls: (fields[6] as List).cast<String>(),
      likesCount: fields[7] as int,
      commentsCount: fields[8] as int,
      needsSync: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedPost obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.authorId)
      ..writeByte(3)
      ..write(obj.authorName)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.cachedAt)
      ..writeByte(6)
      ..write(obj.imageUrls)
      ..writeByte(7)
      ..write(obj.likesCount)
      ..writeByte(8)
      ..write(obj.commentsCount)
      ..writeByte(9)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedMeetingAdapter extends TypeAdapter<CachedMeeting> {
  @override
  final int typeId = 1;

  @override
  CachedMeeting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMeeting(
      id: fields[0] as String,
      title: fields[1] as String,
      meetingDate: fields[2] as DateTime,
      location: fields[3] as String,
      status: fields[4] as String,
      cachedAt: fields[8] as DateTime,
      description: fields[5] as String?,
      presentCount: fields[6] as int,
      absentCount: fields[7] as int,
      needsSync: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMeeting obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.meetingDate)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.presentCount)
      ..writeByte(7)
      ..write(obj.absentCount)
      ..writeByte(8)
      ..write(obj.cachedAt)
      ..writeByte(9)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedMeetingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedUserProfileAdapter extends TypeAdapter<CachedUserProfile> {
  @override
  final int typeId = 2;

  @override
  CachedUserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUserProfile(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      cachedAt: fields[7] as DateTime,
      memberNumber: fields[4] as String?,
      profileImage: fields[5] as String?,
      membershipType: fields[6] as int,
      needsSync: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.memberNumber)
      ..writeByte(5)
      ..write(obj.profileImage)
      ..writeByte(6)
      ..write(obj.membershipType)
      ..writeByte(7)
      ..write(obj.cachedAt)
      ..writeByte(8)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineActionAdapter extends TypeAdapter<OfflineAction> {
  @override
  final int typeId = 3;

  @override
  OfflineAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAction(
      id: fields[0] as String,
      type: fields[1] as OfflineActionType,
      data: (fields[2] as Map).cast<String, dynamic>(),
      createdAt: fields[3] as DateTime,
      attempts: fields[4] as int,
      lastAttempt: fields[5] as DateTime?,
      error: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.attempts)
      ..writeByte(5)
      ..write(obj.lastAttempt)
      ..writeByte(6)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineActionTypeAdapter extends TypeAdapter<OfflineActionType> {
  @override
  final int typeId = 4;

  @override
  OfflineActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OfflineActionType.createPost;
      case 1:
        return OfflineActionType.updateProfile;
      case 2:
        return OfflineActionType.markAttendance;
      case 3:
        return OfflineActionType.addReaction;
      case 4:
        return OfflineActionType.addComment;
      case 5:
        return OfflineActionType.deletePost;
      case 6:
        return OfflineActionType.updatePost;
      default:
        return OfflineActionType.createPost;
    }
  }

  @override
  void write(BinaryWriter writer, OfflineActionType obj) {
    switch (obj) {
      case OfflineActionType.createPost:
        writer.writeByte(0);
        break;
      case OfflineActionType.updateProfile:
        writer.writeByte(1);
        break;
      case OfflineActionType.markAttendance:
        writer.writeByte(2);
        break;
      case OfflineActionType.addReaction:
        writer.writeByte(3);
        break;
      case OfflineActionType.addComment:
        writer.writeByte(4);
        break;
      case OfflineActionType.deletePost:
        writer.writeByte(5);
        break;
      case OfflineActionType.updatePost:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineActionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
