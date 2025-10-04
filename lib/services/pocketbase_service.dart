import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  PocketBase? _pb;
  bool _isInitialized = false;

  PocketBase get pb {
    if (!_isInitialized) {
      _pb = PocketBase(
        FlavorConfig.instance.variables['pocketbaseUrl'] as String,
      );
      _isInitialized = true;
    }
    return _pb!;
  }

  void init() {
    // Lazy initialization - will be called when first accessed
    if (!_isInitialized) {
      _pb = PocketBase(
        FlavorConfig.instance.variables['pocketbaseUrl'] as String,
      );
      _isInitialized = true;
    }
  }

  // Get user by Firebase UID
  Future<RecordModel?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final result = await pb.collection('users').getList(
            filter: 'firebaseUid = "$firebaseUid"',
            perPage: 1,
          );
      return result.items.isNotEmpty ? result.items.first : null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Create user with Firebase UID
  Future<RecordModel> createUserWithFirebaseUid({
    required String firebaseUid,
    required String email,
    required String firstName,
    required String lastName,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'firebaseUid': firebaseUid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isActive': true,
      'isAdmin': false,
      ...?additionalData,
    };

    return await pb.collection('users').create(body: data);
  }

  // Update user data
  Future<RecordModel> updateUser(String userId, Map<String, dynamic> data) async {
    return await pb.collection('users').update(userId, body: data);
  }

  // Get user data
  Future<RecordModel> getUser(String userId) async {
    return await pb.collection('users').getOne(userId);
  }

  // Get all users (admin only)
  Future<List<RecordModel>> getAllUsers() async {
    final result = await pb.collection('users').getList(
          sort: '-created',
        );
    return result.items;
  }

  // Get announcements
  Future<List<RecordModel>> getAnnouncements() async {
    final result = await pb.collection('Announcements').getList(
          sort: '-created',
          filter: 'isActive = true',
        );
    return result.items;
  }

  // Create announcement
  Future<RecordModel> createAnnouncement({
    required String title,
    required String content,
    required String authorId,
    String? type,
  }) async {
    final data = {
      'title': title,
      'content': content,
      'author': authorId,
      'type': type ?? 'general',
      'isActive': true,
    };

    return await pb.collection('Announcements').create(body: data);
  }

  // Get app data
  Future<RecordModel?> getAppData(String key) async {
    try {
      final result = await pb.collection('app_data').getList(
            filter: 'key = "$key"',
            perPage: 1,
          );
      return result.items.isNotEmpty ? result.items.first : null;
    } catch (e) {
      print('Error getting app data: $e');
      return null;
    }
  }

  // Set app data
  Future<RecordModel> setAppData({
    required String key,
    required dynamic value,
    String? description,
    String? category,
  }) async {
    final data = {
      'key': key,
      'value': value,
      'description': description ?? '',
      'category': category ?? 'config',
      'isActive': true,
    };

    return await pb.collection('app_data').create(body: data);
  }

  // Update user profile
  Future<RecordModel> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? contactNumber,
    String? age,
    String? dateOfBirth,
    String? birthplace,
    String? bloodType,
    String? civilStatus,
    String? gender,
    String? nationality,
    String? religion,
    String? driversLicenseNumber,
    String? driversLicenseExpirationDate,
    String? driversLicenseRestrictionCode,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? spouseName,
    String? spouseContactNumber,
    String? memberNumber,
    int? membershipType,
    bool? isActive,
    bool? isAdmin,
    Map<String, dynamic>? vehicle,
  }) async {
    final data = <String, dynamic>{};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (middleName != null) data['middleName'] = middleName;
    if (contactNumber != null) data['contactNumber'] = contactNumber;
    if (age != null) data['age'] = age;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (birthplace != null) data['birthplace'] = birthplace;
    if (bloodType != null) data['bloodType'] = bloodType;
    if (civilStatus != null) data['civilStatus'] = civilStatus;
    if (gender != null) data['gender'] = gender;
    if (nationality != null) data['nationality'] = nationality;
    if (religion != null) data['religion'] = religion;
    if (driversLicenseNumber != null) data['driversLicenseNumber'] = driversLicenseNumber;
    if (driversLicenseExpirationDate != null) data['driversLicenseExpirationDate'] = driversLicenseExpirationDate;
    if (driversLicenseRestrictionCode != null) data['driversLicenseRestrictionCode'] = driversLicenseRestrictionCode;
    if (emergencyContactName != null) data['emergencyContactName'] = emergencyContactName;
    if (emergencyContactNumber != null) data['emergencyContactNumber'] = emergencyContactNumber;
    if (spouseName != null) data['spouseName'] = spouseName;
    if (spouseContactNumber != null) data['spouseContactNumber'] = spouseContactNumber;
    if (memberNumber != null) data['memberNumber'] = memberNumber;
    if (membershipType != null) data['membership_type'] = membershipType;
    if (isActive != null) data['isActive'] = isActive;
    if (isAdmin != null) data['isAdmin'] = isAdmin;
    if (vehicle != null) data['vehicle'] = vehicle;

    return await pb.collection('users').update(userId, body: data);
  }

  // Subscribe to real-time updates
  Future<UnsubscribeFunc> subscribeToUsers(void Function(RecordModel) onUpdate) async {
    return await pb.collection('users').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }

  // Subscribe to announcements
  Future<UnsubscribeFunc> subscribeToAnnouncements(void Function(RecordModel) onUpdate) async {
    return await pb.collection('Announcements').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }
}
