import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../models/monthly_dues.dart';
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

  // Ensure authentication before any monthly dues operations
  Future<void> _ensureAuthenticated() async {
    if (!pb.authStore.isValid) {
      print('PocketBaseService - Not authenticated, authenticating with test account...');
      await pb.collection('users').authWithPassword(
            'ialexies@gmail.com',
            'chachielex',
          );
      print('PocketBaseService - Authentication successful!');
      print('PocketBaseService - Authenticated user ID: ${pb.authStore.model?.id}');
    } else {
      print('PocketBaseService - Already authenticated with user ID: ${pb.authStore.model?.id}');
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

  // Delete user
  Future<void> deleteUser(String userId) async {
    await pb.collection('users').delete(userId);
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
            'PocketBaseService.getMonthlyDuesForUser - Found ${filteredRecords.length} monthly dues records for user "$userId" after filtering');

        return filteredRecords.map((record) => MonthlyDues.fromRecord(record)).toList();
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
    required String status,
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
      'status': status,
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
    final existingDues = await getMonthlyDuesForUserAndMonth(userId, month);
    final status = isPaid ? 'Paid' : 'Unpaid';

    return await createOrUpdateMonthlyDues(
      userId: userId,
      dueForMonth: month,
      amount: 100.0, // Fixed amount per month
      status: status,
      paymentDate: isPaid ? (paymentDate ?? DateTime.now()) : null,
      notes: notes,
      existingId: existingDues?.id,
    );
  }

  // Get payment statistics for a user
  Future<Map<String, int>> getPaymentStatistics(String userId) async {
    try {
      final dues = await getMonthlyDuesForUser(userId);
      final now = DateTime.now();
      final currentYear = now.year;

      int paid = 0;
      int unpaid = 0;
      int advance = 0;

      for (final due in dues) {
        if (due.dueForMonth != null) {
          final dueYear = due.dueForMonth!.year;
          final dueMonth = due.dueForMonth!.month;

          if (dueYear == currentYear) {
            if (dueMonth <= now.month) {
              // Current or past months
              if (due.isPaid) {
                paid++;
              } else {
                unpaid++;
              }
            } else {
              // Future months (advance payments)
              if (due.isPaid) {
                advance++;
              }
            }
          }
        }
      }

      return {
        'paid': paid,
        'unpaid': unpaid,
        'advance': advance,
      };
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {'paid': 0, 'unpaid': 0, 'advance': 0};
    }
  }

  // Get all monthly dues (admin only)
  Future<List<MonthlyDues>> getAllMonthlyDues() async {
    try {
      final result = await pb.collection('monthly_dues').getFullList(
            sort: '-due_for_month',
          );
      return result.map((record) => MonthlyDues.fromRecord(record)).toList();
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

      for (int i = 0; i < allResult.length; i++) {
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
      final currentMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      // Create a record for last month (paid)
      final record1 = await pb.collection('monthly_dues').create(body: {
        'user': authenticatedUserId, // Use authenticated user ID
        'amount': 100.0,
        'due_for_month': lastMonth.toIso8601String().split('T')[0],
        'status': 'Paid',
        'payment_date': lastMonth.toIso8601String().split('T')[0],
        'notes': 'Test payment for debugging',
      });

      print('Created test record 1: ${record1.id}');

      // Create a record for current month (unpaid)
      final record2 = await pb.collection('monthly_dues').create(body: {
        'user': authenticatedUserId, // Use authenticated user ID
        'amount': 100.0,
        'due_for_month': currentMonth.toIso8601String().split('T')[0],
        'status': 'Unpaid',
        'notes': 'Current month dues',
      });

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
    return await pb.collection('monthly_dues').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update' || e.action == 'delete') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }
}
