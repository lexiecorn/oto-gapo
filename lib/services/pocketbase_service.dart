import 'dart:async';

import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:otogapo/models/monthly_dues.dart';
import 'package:otogapo/utils/payment_statistics_utils.dart';
import 'package:pocketbase/pocketbase.dart';

/// Service class for interacting with PocketBase backend.
///
/// Provides a centralized interface for all PocketBase operations including:
/// - User management (CRUD operations)
/// - Vehicle management
/// - Monthly dues tracking
/// - Announcements
/// - Gallery image management
/// - Real-time subscriptions
///
/// This service uses the singleton pattern to ensure a single instance
/// throughout the application. It shares the PocketBase instance with
/// [PocketBaseAuthRepository] for authentication consistency.
///
/// Example:
/// ```dart
/// final service = PocketBaseService();
/// final users = await service.getAllUsers();
/// ```
class PocketBaseService {
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();
  static final PocketBaseService _instance = PocketBaseService._internal();

  // Use the shared PocketBase instance from PocketBaseAuthRepository
  PocketBase get pb => PocketBaseAuthRepository().pocketBase;

  void init() {
    // No-op: using shared instance from PocketBaseAuthRepository
  }

  // Ensure authentication before any operations
  Future<void> _ensureAuthenticated() async {
    if (!pb.authStore.isValid) {
      print('PocketBaseService - Not authenticated with PocketBase');
      throw Exception('PocketBase authentication required. Please log in first.');
    } else {
      print('PocketBaseService - Already authenticated with user ID: ${pb.authStore.model?.id}');
    }

    // Check the authenticated user's membership_type
    try {
      final currentUser = pb.authStore.model;
      if (currentUser != null) {
        print('PocketBaseService - Current user data: ${currentUser.data}');
        print('PocketBaseService - Current user membership_type: ${currentUser.data['membership_type']}');
        print('PocketBaseService - Current user email: ${currentUser.data['email']}');
      }
    } catch (e) {
      print('PocketBaseService - Error getting current user data: $e');
    }
  }

  // Authenticate with PocketBase using email and password
  Future<void> authenticateWithPocketBase(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      print('PocketBaseService - Authentication successful with: $email');
    } catch (e) {
      print('PocketBaseService - Authentication failed: $e');
      rethrow;
    }
  }

  // Get user by email
  Future<RecordModel?> getUserByEmail(String email) async {
    try {
      final result = await pb.collection('users').getList(
            filter: 'email = "$email"',
            perPage: 1,
          );
      if (result.items.isNotEmpty) {
        print('Found user by email: $email');
        return result.items.first;
      }

      print('No user found with email: $email');
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Create user in PocketBase
  Future<RecordModel> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    Map<String, dynamic>? additionalData,
  }) async {
    await _ensureAuthenticated();

    final data = {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'firstName': firstName,
      'lastName': lastName,
      'isActive': true,
      'isAdmin': false,
      'joinedDate': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    print('PocketBaseService - Creating user with data: $data');

    try {
      final result = await pb.collection('users').create(body: data);
      print('PocketBaseService - User created successfully: ${result.id}');
      return result;
    } catch (e) {
      print('PocketBaseService - Error creating user: $e');
      print('PocketBaseService - Error details: ${e.toString()}');
      rethrow;
    }
  }

  // Update user data
  Future<RecordModel> updateUser(String userId, Map<String, dynamic> data) async {
    return pb.collection('users').update(userId, body: data);
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await pb.collection('users').delete(userId);
  }

  // Get user data
  Future<RecordModel?> getUser(String userId) async {
    try {
      return await pb.collection('users').getOne(userId);
    } catch (e) {
      // Handle 404 errors gracefully - user might not exist
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        print('User $userId not found in getUser method');
        return null;
      }
      print('Error getting user $userId: $e');
      rethrow;
    }
  }

  // Create vehicle for user
  Future<RecordModel> createVehicle({
    required String userId,
    required String color,
    required String make,
    required String model,
    required String plateNumber,
    required String type,
    required int year,
    String? primaryPhoto,
    List<String>? photos,
  }) async {
    await _ensureAuthenticated();

    final data = {
      'user': userId,
      'color': color,
      'make': make,
      'model': model,
      'plateNumber': plateNumber,
      'type': type,
      'year': year,
      if (primaryPhoto != null) 'primaryPhoto': primaryPhoto,
      if (photos != null && photos.isNotEmpty) 'photos': photos,
    };

    print('PocketBaseService - Creating vehicle for user: $userId');
    print('PocketBaseService - Vehicle data: $data');

    try {
      final result = await pb.collection('vehicles').create(body: data);
      print('PocketBaseService - Vehicle created successfully: ${result.id}');
      return result;
    } catch (e) {
      print('PocketBaseService - Error creating vehicle: $e');
      rethrow;
    }
  }

  // Get vehicles for user
  Future<List<RecordModel>> getVehiclesByUser(String userId) async {
    try {
      final result = await pb.collection('vehicles').getList(
            filter: 'user = "$userId"',
          );
      return result.items;
    } catch (e) {
      print('Error getting vehicles for user: $e');
      return [];
    }
  }

  // Update vehicle
  Future<RecordModel> updateVehicle(String vehicleId, Map<String, dynamic> data) async {
    return pb.collection('vehicles').update(vehicleId, body: data);
  }

  // Delete vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    await pb.collection('vehicles').delete(vehicleId);
  }

  // Get all users (admin only)
  Future<List<RecordModel>> getAllUsers() async {
    await _ensureAuthenticated();
    print('PocketBaseService - Getting all users...');
    print('PocketBaseService - Authenticated user: ${pb.authStore.model?.id}');

    final result = await pb.collection('users').getList(
          sort: '-created',
          perPage: 500, // Increase limit to get more users
        );

    print('PocketBaseService - Found ${result.items.length} users');
    for (final user in result.items) {
      print('PocketBaseService - User: ${user.data['email']} (ID: ${user.id})');
    }

    return result.items;
  }

  // Get announcements
  Future<List<RecordModel>> getAnnouncements() async {
    try {
      await _ensureAuthenticated();
      final result = await pb.collection('Announcements').getList(
            sort: '-created',
          );
      return result.items;
    } catch (e) {
      print('Error getting announcements: $e');
      return [];
    }
  }

  // Create announcement
  Future<RecordModel> createAnnouncement({
    required String title,
    required String content,
    String? type,
  }) async {
    final data = {
      'title': title,
      'content': content,
      'type': type ?? 'general',
    };

    return pb.collection('Announcements').create(body: data);
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

    return pb.collection('app_data').create(body: data);
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
    String? joinedDate,
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
    if (joinedDate != null) data['joinedDate'] = joinedDate;

    return pb.collection('users').update(userId, body: data);
  }

  // Subscribe to real-time updates
  Future<UnsubscribeFunc> subscribeToUsers(void Function(RecordModel) onUpdate) async {
    return pb.collection('users').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }

  // Subscribe to announcements
  Future<UnsubscribeFunc> subscribeToAnnouncements(void Function(RecordModel) onUpdate) async {
    return pb.collection('Announcements').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }

  // Monthly Dues Methods

  // Get monthly dues for a specific user
  Future<List<MonthlyDues>> getMonthlyDuesForUser(String userId) async {
    try {
      print('PocketBaseService.getMonthlyDuesForUser - Searching for userId: "$userId"');

      // Ensure authentication first
      await _ensureAuthenticated();

      // First, let's fetch ALL monthly dues records to see what's in the database
      try {
        final allResult = await pb.collection('monthly_dues').getFullList(
              sort: '-due_for_month',
            );

        print('PocketBaseService.getMonthlyDuesForUser - Total monthly dues records in database: ${allResult.length}');

        // Debug: Print ALL monthly dues records
        for (final record in allResult) {
          print('PocketBaseService.getMonthlyDuesForUser - Monthly due record:');
          print('  - ID: ${record.id}');
          print('  - User field: "${record.data['user']}"');
          print('  - Amount: ${record.data['amount']}');
          print('  - Status: ${record.data['status']}');
          print('  - Due for month: ${record.data['due_for_month']}');
        }

        // Now filter by userId in the app
        final filteredRecords = allResult.where((record) {
          final userField = record.data['user'];
          print('PocketBaseService.getMonthlyDuesForUser - Comparing: "$userField" == "$userId"');
          return userField == userId;
        }).toList();

        print(
          'PocketBaseService.getMonthlyDuesForUser - Found ${filteredRecords.length} monthly dues records for user "$userId" after filtering',
        );

        return filteredRecords.map(MonthlyDues.fromRecord).toList();
      } catch (e) {
        print('PocketBaseService.getMonthlyDuesForUser - Error getting monthly dues: $e');
        return [];
      }
    } catch (e) {
      print('Error getting monthly dues for user: $e');
      return [];
    }
  }

  // Get monthly dues for a specific user and month
  Future<MonthlyDues?> getMonthlyDuesForUserAndMonth(String userId, DateTime month) async {
    try {
      final monthString = month.toIso8601String().split('T')[0];

      // Query for the specific user and month with expanded user relation
      final result = await pb.collection('monthly_dues').getFirstListItem(
            'user = "$userId" && due_for_month = "$monthString"',
            expand: 'user',
          );

      return MonthlyDues.fromRecord(result);
    } catch (e) {
      print('Error getting monthly dues for user and month: $e');
      return null;
    }
  }

  // Create or update monthly dues
  Future<MonthlyDues> createOrUpdateMonthlyDues({
    required String userId,
    required DateTime dueForMonth,
    required double amount,
    DateTime? paymentDate,
    String? notes,
    String? existingId,
  }) async {
    // Since we're using PocketBase authentication, userId should be the PocketBase record ID
    print('PocketBaseService.createOrUpdateMonthlyDues - Using userId: "$userId"');

    final data = {
      'user': userId, // Use the PocketBase record ID directly since it's a relation field
      'due_for_month': dueForMonth.toIso8601String().split('T')[0],
      'amount': amount,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'notes': notes ?? '',
    };

    RecordModel record;
    if (existingId != null) {
      record = await pb.collection('monthly_dues').update(existingId, body: data);
    } else {
      record = await pb.collection('monthly_dues').create(body: data);
    }

    return MonthlyDues.fromRecord(record);
  }

  // Mark payment status for a specific month
  Future<MonthlyDues> markPaymentStatus({
    required String userId,
    required DateTime month,
    required bool isPaid,
    DateTime? paymentDate,
    String? notes,
  }) async {
    print('PocketBase - markPaymentStatus called for user: $userId, month: $month, isPaid: $isPaid');

    final existingDues = await getMonthlyDuesForUserAndMonth(userId, month);
    print('PocketBase - Existing dues found: ${existingDues?.id}');

    final result = await createOrUpdateMonthlyDues(
      userId: userId,
      dueForMonth: month,
      amount: 100, // Fixed amount per month
      paymentDate: isPaid ? (paymentDate ?? DateTime.now()) : null,
      notes: notes,
      existingId: existingDues?.id,
    );

    print('PocketBase - markPaymentStatus completed, result ID: ${result.id}');
    return result;
  }

  // Get payment statistics for a user
  Future<Map<String, int>> getPaymentStatistics(String userId) async {
    try {
      // Get user details to find joinedDate
      final userRecord = await getUser(userId);
      if (userRecord == null) {
        print('User $userId not found in getPaymentStatistics - returning zero stats');
        return {'paid': 0, 'unpaid': 0, 'advance': 0, 'total': 0};
      }

      final joinedDateString = userRecord.data['joinedDate'] as String?;

      if (joinedDateString == null) {
        print('Warning: User $userId has no joinedDate, using current date');
        return {'paid': 0, 'unpaid': 0, 'advance': 0, 'total': 0};
      }

      final joinedDate = DateTime.parse(joinedDateString);
      final dues = await getMonthlyDuesForUser(userId);

      // Use the utility class to compute statistics
      return PaymentStatisticsUtils.computePaymentStatistics(
        joinedDate: joinedDate,
        monthlyDues: dues,
      );
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {'paid': 0, 'unpaid': 0, 'advance': 0, 'total': 0};
    }
  }

  // Get payment status for a specific month
  Future<bool?> getPaymentStatusForMonth({
    required String userId,
    required DateTime monthDate,
  }) async {
    try {
      // Get user details to find joinedDate
      final userRecord = await getUser(userId);
      if (userRecord == null) {
        print('User $userId not found in getPaymentStatusForMonth - returning null');
        return null;
      }

      final joinedDateString = userRecord.data['joinedDate'] as String?;

      if (joinedDateString == null) {
        print('Warning: User $userId has no joinedDate');
        return null;
      }

      final joinedDate = DateTime.parse(joinedDateString);
      final dues = await getMonthlyDuesForUser(userId);

      print('getPaymentStatusForMonth - User: $userId, Month: $monthDate, Joined: $joinedDate');
      print('getPaymentStatusForMonth - Found ${dues.length} dues records');

      // Use the utility class to get payment status
      final status = PaymentStatisticsUtils.getPaymentStatusForMonth(
        monthDate: monthDate,
        joinedDate: joinedDate,
        monthlyDues: dues,
      );

      print('getPaymentStatusForMonth - Status: $status');
      return status;
    } catch (e) {
      // Handle 404 errors gracefully - user might not exist
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        print('User $userId not found in getPaymentStatusForMonth - returning null');
        return null;
      }
      print('Error getting payment status for month: $e');
      return null;
    }
  }

  // Get all monthly dues (admin only)
  Future<List<MonthlyDues>> getAllMonthlyDues() async {
    try {
      final result = await pb.collection('monthly_dues').getFullList(
            sort: '-due_for_month',
          );
      return result.map(MonthlyDues.fromRecord).toList();
    } catch (e) {
      print('Error getting all monthly dues: $e');
      return [];
    }
  }

  // Debug method to see all monthly dues records
  Future<void> debugAllMonthlyDues() async {
    try {
      print('=== DEBUG: All Monthly Dues Records ===');

      // Ensure authentication first
      await _ensureAuthenticated();

      // First, let's check the authenticated user
      print('Authenticated user: ${pb.authStore.model?.id}');
      print('Auth store is valid: ${pb.authStore.isValid}');
      print('Auth token: ${pb.authStore.token}');

      final allResult = await pb.collection('monthly_dues').getFullList(
            sort: '-due_for_month',
          );

      print('Total records: ${allResult.length}');

      for (var i = 0; i < allResult.length; i++) {
        final record = allResult[i];
        print('Record ${i + 1}:');
        print('  - ID: ${record.id}');
        print('  - User field: "${record.data['user']}"');
        print('  - Amount: ${record.data['amount']}');
        print('  - Status: ${record.data['status']}');
        print('  - Due for month: ${record.data['due_for_month']}');
        print('  - Payment date: ${record.data['payment_date']}');
        print('  - Notes: ${record.data['notes']}');
        print('  - Created: ${record.created}');
        print('  - Updated: ${record.updated}');
        print('');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error debugging monthly dues: $e');
    }
  }

  // Create a test monthly dues record
  Future<void> createTestMonthlyDues(String userId) async {
    try {
      print('=== Creating Test Monthly Dues Record ===');

      // Ensure authentication first
      await _ensureAuthenticated();

      // Use the authenticated user's ID instead of the passed userId
      final authenticatedUserId = pb.authStore.model?.id;
      print('Using authenticated user ID: $authenticatedUserId (instead of passed userId: $userId)');

      if (authenticatedUserId == null) {
        print('ERROR: No authenticated user found!');
        return;
      }

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      // Create a record for last month (paid)
      final record1 = await pb.collection('monthly_dues').create(
        body: {
          'user': authenticatedUserId, // Use authenticated user ID
          'amount': 100.0,
          'due_for_month': lastMonth.toIso8601String().split('T')[0],
          'payment_date': lastMonth.toIso8601String().split('T')[0],
          'notes': 'Test payment for debugging',
        },
      );

      print('Created test record 1: ${record1.id}');

      // Create a record for current month (unpaid - no payment_date)
      final record2 = await pb.collection('monthly_dues').create(
        body: {
          'user': authenticatedUserId, // Use authenticated user ID
          'amount': 100.0,
          'due_for_month': currentMonth.toIso8601String().split('T')[0],
          'notes': 'Current month dues',
        },
      );

      print('Created test record 2: ${record2.id}');
      print('=== Test Records Created Successfully ===');
    } catch (e) {
      print('Error creating test monthly dues: $e');
    }
  }

  // Delete monthly dues
  Future<void> deleteMonthlyDues(String duesId) async {
    try {
      await pb.collection('monthly_dues').delete(duesId);
    } catch (e) {
      print('Error deleting monthly dues: $e');
      rethrow;
    }
  }

  // Subscribe to monthly dues updates
  Future<UnsubscribeFunc> subscribeToMonthlyDues(void Function(RecordModel) onUpdate) async {
    return pb.collection('monthly_dues').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update' || e.action == 'delete') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }

  // Gallery Images Methods

  /// Get all active gallery images sorted by display_order
  Future<List<RecordModel>> getActiveGalleryImages() async {
    try {
      await _ensureAuthenticated();
      final result = await pb.collection('gallery_images').getList(
            filter: 'is_active = true',
            sort: '+display_order',
            expand: 'uploaded_by',
          );
      return result.items;
    } catch (e) {
      print('Error getting active gallery images: $e');
      return [];
    }
  }

  /// Get all gallery images (admin only)
  Future<List<RecordModel>> getAllGalleryImages() async {
    try {
      await _ensureAuthenticated();
      final result = await pb.collection('gallery_images').getList(
            sort: '+display_order',
            expand: 'uploaded_by',
          );
      return result.items;
    } catch (e) {
      print('Error getting all gallery images: $e');
      return [];
    }
  }

  /// Create a new gallery image
  Future<RecordModel> createGalleryImage({
    required String imageFilePath,
    required String uploadedBy,
    String? title,
    String? description,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    try {
      await _ensureAuthenticated();
      final body = <String, dynamic>{
        'image': await MultipartFile.fromPath('image', imageFilePath),
        'uploaded_by': uploadedBy,
        'display_order': displayOrder,
        'is_active': isActive,
      };

      if (title != null && title.isNotEmpty) {
        body['title'] = title;
      }
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      return await pb.collection('gallery_images').create(body: body);
    } catch (e) {
      print('Error creating gallery image: $e');
      rethrow;
    }
  }

  /// Update gallery image metadata
  Future<RecordModel> updateGalleryImage({
    required String imageId,
    String? imageFilePath,
    String? title,
    String? description,
    int? displayOrder,
    bool? isActive,
  }) async {
    try {
      await _ensureAuthenticated();
      final body = <String, dynamic>{};

      if (imageFilePath != null) {
        body['image'] = await MultipartFile.fromPath('image', imageFilePath);
      }
      if (title != null) {
        body['title'] = title;
      }
      if (description != null) {
        body['description'] = description;
      }
      if (displayOrder != null) {
        body['display_order'] = displayOrder;
      }
      if (isActive != null) {
        body['is_active'] = isActive;
      }

      return await pb.collection('gallery_images').update(imageId, body: body);
    } catch (e) {
      print('Error updating gallery image: $e');
      rethrow;
    }
  }

  /// Delete a gallery image
  Future<void> deleteGalleryImage(String imageId) async {
    try {
      await _ensureAuthenticated();
      await pb.collection('gallery_images').delete(imageId);
    } catch (e) {
      print('Error deleting gallery image: $e');
      rethrow;
    }
  }

  /// Reorder gallery images by updating display_order
  Future<void> reorderGalleryImages(List<Map<String, dynamic>> imageOrders) async {
    try {
      for (final order in imageOrders) {
        await pb.collection('gallery_images').update(
          order['id'] as String,
          body: {'display_order': order['order']},
        );
      }
    } catch (e) {
      print('Error reordering gallery images: $e');
      rethrow;
    }
  }

  /// Get image URL from PocketBase
  String getGalleryImageUrl(RecordModel record, {String? thumb}) {
    final filename = record.data['image'] as String?;
    if (filename == null || filename.isEmpty) {
      return '';
    }

    final baseUrl = pb.baseUrl;
    final collectionId = record.collectionId;
    final recordId = record.id;

    if (thumb != null && thumb.isNotEmpty) {
      return '$baseUrl/api/files/$collectionId/$recordId/$filename?thumb=$thumb';
    }

    return '$baseUrl/api/files/$collectionId/$recordId/$filename';
  }

  /// Subscribe to gallery images updates
  Future<UnsubscribeFunc> subscribeToGalleryImages(void Function(RecordModel) onUpdate) async {
    return pb.collection('gallery_images').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update' || e.action == 'delete') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }
}
