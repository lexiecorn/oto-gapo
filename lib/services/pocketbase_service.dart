import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:otogapo/models/monthly_dues.dart';
import 'package:otogapo/models/payment_analytics.dart';
import 'package:otogapo/models/payment_statistics.dart';
import 'package:otogapo/models/payment_transaction.dart';
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
    await _ensureAuthenticated();

    // Separate file uploads from regular data updates
    final fileFields = <String, File>{};
    final regularData = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is File) {
        fileFields[entry.key] = entry.value as File;
      } else {
        regularData[entry.key] = entry.value;
      }
    }

    print('PocketBaseService - Updating user $userId');
    print('PocketBaseService - Regular data keys: ${regularData.keys.toList()}');
    print('PocketBaseService - File fields: ${fileFields.keys.toList()}');

    try {
      RecordModel result;

      // First update regular data if any
      if (regularData.isNotEmpty) {
        result = await pb.collection('users').update(userId, body: regularData);
        print('PocketBaseService - Regular data updated successfully');
      } else {
        result = await pb.collection('users').getOne(userId);
      }

      // Handle file uploads using separate method
      if (fileFields.isNotEmpty) {
        for (final entry in fileFields.entries) {
          final fieldName = entry.key;
          final file = entry.value;

          print('PocketBaseService - Uploading file for field: $fieldName');
          print('PocketBaseService - File path: ${file.path}');

          // Upload file using dedicated method
          result = await _uploadUserFile(userId, fieldName, file);

          print('PocketBaseService - File $fieldName uploaded successfully');
        }
      }

      print('PocketBaseService - User updated successfully: ${result.id}');
      return result;
    } catch (e) {
      print('PocketBaseService - Error updating user: $e');
      print('PocketBaseService - Error type: ${e.runtimeType}');
      if (e.toString().contains('MultipartFile')) {
        print('PocketBaseService - MultipartFile conversion issue detected');
      }
      rethrow;
    }
  }

  // Upload file for user
  Future<RecordModel> _uploadUserFile(String userId, String fieldName, File file) async {
    try {
      print('PocketBaseService - Starting file upload for field: $fieldName');

      // Read file bytes
      final fileBytes = await file.readAsBytes();
      print('PocketBaseService - File size: ${fileBytes.length} bytes');

      // Create multipart request manually
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${pb.baseUrl}/api/collections/users/records/$userId'),
      );

      // Add authorization header
      final token = pb.authStore.token;
      request.headers['Authorization'] = 'Bearer $token';

      // Add the file
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: file.path.split('/').last,
        ),
      );

      print('PocketBaseService - Sending multipart request');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('PocketBaseService - Response status: ${response.statusCode}');
      print('PocketBaseService - Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return RecordModel.fromJson(responseData);
      } else {
        throw Exception('File upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('PocketBaseService - Error uploading file for field $fieldName: $e');
      print('PocketBaseService - Error type: ${e.runtimeType}');
      rethrow;
    }
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
      print('PocketBase - getMonthlyDuesForUserAndMonth: userId=$userId, month=$month, monthString=$monthString');

      // Also try with time component to match database format
      final monthStringWithTime = '${monthString} 00:00:00 UTC';
      print('PocketBase - monthStringWithTime: $monthStringWithTime');

      // Query for ALL records for the specific user and month to handle duplicates
      // Try both date formats to match database
      final result = await pb.collection('monthly_dues').getList(
            page: 1,
            perPage: 100, // Should be enough for any reasonable number of duplicates
            filter: 'user = "$userId" && (due_for_month = "$monthString" || due_for_month = "$monthStringWithTime")',
            expand: 'user',
          );

      print('PocketBase - getMonthlyDuesForUserAndMonth: Found ${result.items.length} records');
      for (int i = 0; i < result.items.length; i++) {
        final item = result.items[i];
        print(
            'PocketBase - Record $i: id=${item.id}, due_for_month=${item.data['due_for_month']}, payment_date=${item.data['payment_date']}');
        print('PocketBase - Record $i full data: ${item.data}');
      }

      if (result.items.isEmpty) {
        print('PocketBase - getMonthlyDuesForUserAndMonth: No records found');
        return null;
      }

      // If there are multiple records (duplicates), we need to clean them up
      if (result.items.length > 1) {
        print(
            'PocketBase - Found ${result.items.length} duplicate records for user $userId, month $monthString. Cleaning up...');

        // Keep the most recent record (highest created timestamp)
        result.items.sort((a, b) => DateTime.parse(b.created).compareTo(DateTime.parse(a.created)));
        final recordToKeep = result.items.first;

        print('PocketBase - Keeping record: ${recordToKeep.id} (created: ${recordToKeep.created})');

        // Delete all other duplicate records
        for (int i = 1; i < result.items.length; i++) {
          try {
            print(
                'PocketBase - Deleting duplicate record: ${result.items[i].id} (created: ${result.items[i].created})');
            await pb.collection('monthly_dues').delete(result.items[i].id);
            print('PocketBase - Successfully deleted duplicate record: ${result.items[i].id}');
          } catch (e) {
            print('PocketBase - Error deleting duplicate record ${result.items[i].id}: $e');
          }
        }

        print('PocketBase - Cleanup completed, returning record: ${recordToKeep.id}');
        return MonthlyDues.fromRecord(recordToKeep);
      }

      return MonthlyDues.fromRecord(result.items.first);
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

    print('PocketBaseService.createOrUpdateMonthlyDues - Data being sent:');
    print('  - user: ${data['user']}');
    print('  - due_for_month: ${data['due_for_month']}');
    print('  - amount: ${data['amount']}');
    print('  - payment_date: ${data['payment_date']}');
    print('  - notes: ${data['notes']}');

    RecordModel record;
    if (existingId != null) {
      record = await pb.collection('monthly_dues').update(existingId, body: data);
    } else {
      record = await pb.collection('monthly_dues').create(body: data);
    }

    print('PocketBaseService.createOrUpdateMonthlyDues - Record created/updated:');
    print('  - id: ${record.id}');
    print('  - payment_date in record: ${record.data['payment_date']}');
    print('  - amount in record: ${record.data['amount']}');

    return MonthlyDues.fromRecord(record);
  }

  // Mark payment status for a specific month
  Future<MonthlyDues?> markPaymentStatus({
    required String userId,
    required DateTime month,
    required bool isPaid,
    DateTime? paymentDate,
    String? notes,
  }) async {
    print('PocketBase - markPaymentStatus called for user: $userId, month: $month, isPaid: $isPaid');

    final existingDues = await getMonthlyDuesForUserAndMonth(userId, month);
    print('PocketBase - Existing dues found: ${existingDues?.id}');
    print('PocketBase - Existing dues payment date: ${existingDues?.paymentDate}');
    print('PocketBase - Existing dues isPaid: ${existingDues?.isPaid}');

    // If marking as unpaid (isPaid = false)
    if (!isPaid) {
      if (existingDues != null) {
        // Delete existing record
        print('PocketBase - Deleting payment record for user: $userId, month: $month, record ID: ${existingDues.id}');
        try {
          await deleteMonthlyDues(existingDues.id);
          print('PocketBase - Payment record deleted successfully');
          return null; // Return null to indicate record was deleted
        } catch (e) {
          print('PocketBase - Error deleting payment record: $e');
          rethrow;
        }
      } else {
        // No existing record, nothing to do
        print('PocketBase - No existing record to delete for user: $userId, month: $month');
        return null; // Return null to indicate no action needed
      }
    }

    // If marking as paid (isPaid = true)
    print('PocketBase - Marking as paid for user: $userId, month: $month');
    final paymentDateToUse = paymentDate ?? DateTime.now();
    print('PocketBase - Using payment date: $paymentDateToUse');

    MonthlyDues result;

    if (existingDues != null) {
      // Update existing record
      print('PocketBase - Updating existing record: ${existingDues.id}');
      result = await createOrUpdateMonthlyDues(
        userId: userId,
        dueForMonth: month,
        amount: 100, // Fixed amount per month
        paymentDate: paymentDateToUse,
        notes: notes,
        existingId: existingDues.id,
      );
    } else {
      // Create new record - but first check again for duplicates
      print('PocketBase - Creating new record, but first checking for duplicates...');

      // Double-check for duplicates before creating
      final duplicateCheck = await getMonthlyDuesForUserAndMonth(userId, month);
      if (duplicateCheck != null) {
        print('PocketBase - Found duplicate during creation, updating instead');
        result = await createOrUpdateMonthlyDues(
          userId: userId,
          dueForMonth: month,
          amount: 100, // Fixed amount per month
          paymentDate: paymentDateToUse,
          notes: notes,
          existingId: duplicateCheck.id,
        );
      } else {
        print('PocketBase - No duplicates found, creating new record');
        result = await createOrUpdateMonthlyDues(
          userId: userId,
          dueForMonth: month,
          amount: 100, // Fixed amount per month
          paymentDate: paymentDateToUse,
          notes: notes,
          existingId: null,
        );
      }
    }

    print(
        'PocketBase - Final record: id=${result.id}, paymentDate=${result.paymentDate}, isPaid=${result.paymentDate != null}');
    print('PocketBase - markPaymentStatus completed, result ID: ${result.id}');
    return result;
  }

  // Clean up all duplicate monthly dues records across the system
  Future<void> cleanupDuplicateMonthlyDues() async {
    try {
      print('PocketBase - Starting cleanup of duplicate monthly dues records...');

      // Get all monthly dues records
      final allRecords = await pb.collection('monthly_dues').getList(
            page: 1,
            perPage: 1000, // Adjust based on your data size
          );

      // Group records by user and month
      final Map<String, List<RecordModel>> groupedRecords = {};

      for (final record in allRecords.items) {
        final user = record.data['user'] as String;
        final dueForMonth = record.data['due_for_month'] as String;
        final key = '$user-$dueForMonth';

        if (!groupedRecords.containsKey(key)) {
          groupedRecords[key] = [];
        }
        groupedRecords[key]!.add(record);
      }

      int totalDuplicatesRemoved = 0;

      // Process each group
      for (final entry in groupedRecords.entries) {
        final records = entry.value;

        if (records.length > 1) {
          print('PocketBase - Found ${records.length} duplicates for key: ${entry.key}');

          // Sort by created date (keep the most recent)
          records.sort((a, b) => DateTime.parse(b.created).compareTo(DateTime.parse(a.created)));

          // Delete all other records
          for (int i = 1; i < records.length; i++) {
            try {
              await pb.collection('monthly_dues').delete(records[i].id);
              totalDuplicatesRemoved++;
              print('PocketBase - Deleted duplicate record: ${records[i].id}');
            } catch (e) {
              print('PocketBase - Error deleting duplicate record ${records[i].id}: $e');
            }
          }
        }
      }

      print('PocketBase - Cleanup completed. Removed $totalDuplicatesRemoved duplicate records.');
    } catch (e) {
      print('PocketBase - Error during cleanup: $e');
    }
  }

  // Old monthly_dues getPaymentStatistics removed - see new implementation below for payment_transactions

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

  /// Get base URL for PocketBase
  String get baseUrl => pb.baseUrl;

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

  // ========================================================================
  // Payment Transactions Methods (New Clean Implementation)
  // ========================================================================

  /// Get all payment transactions for a specific user
  /// Expands the recorded_by relation to include admin name
  Future<List<PaymentTransaction>> getPaymentTransactions(String userId) async {
    try {
      await _ensureAuthenticated();

      final result = await pb.collection('payment_transactions').getList(
            filter: 'user = "$userId"',
            sort: '-month', // Most recent first
            expand: 'recorded_by',
            perPage: 500,
          );

      return result.items.map(PaymentTransaction.fromRecord).toList();
    } catch (e) {
      print('Error getting payment transactions for user $userId: $e');
      return [];
    }
  }

  /// Get a specific payment transaction for a user and month
  Future<PaymentTransaction?> getPaymentTransaction(
    String userId,
    String month,
  ) async {
    try {
      await _ensureAuthenticated();

      final result = await pb.collection('payment_transactions').getList(
            filter: 'user = "$userId" && month = "$month"',
            expand: 'recorded_by',
            perPage: 1,
          );

      if (result.items.isEmpty) return null;
      return PaymentTransaction.fromRecord(result.items.first);
    } catch (e) {
      print('Error getting payment transaction for user $userId, month $month: $e');
      return null;
    }
  }

  /// Create or update a payment transaction
  Future<PaymentTransaction> updatePaymentTransaction({
    required String userId,
    required String month,
    required PaymentStatus status,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? notes,
    String? recordedBy,
  }) async {
    try {
      await _ensureAuthenticated();

      final data = <String, dynamic>{
        'user': userId,
        'month': month,
        'amount': 100.0, // Default amount
        'status': status.value,
        'notes': notes ?? '',
      };

      // Only include payment_date if not null
      if (paymentDate != null) {
        data['payment_date'] = paymentDate.toIso8601String().split('T')[0];
      }

      // Only include payment_method if not null
      if (paymentMethod != null) {
        data['payment_method'] = paymentMethod.value;
      }

      // Only include recorded_by if not null
      if (recordedBy != null) {
        data['recorded_by'] = recordedBy;
      }

      // Check if record already exists
      final existing = await getPaymentTransaction(userId, month);

      RecordModel record;
      if (existing != null) {
        // Update existing record
        record = await pb.collection('payment_transactions').update(
              existing.id,
              body: data,
            );
      } else {
        // Create new record
        record = await pb.collection('payment_transactions').create(body: data);
      }

      return PaymentTransaction.fromRecord(record);
    } catch (e) {
      print('Error updating payment transaction: $e');
      rethrow;
    }
  }

  /// Delete a payment transaction
  Future<void> deletePaymentTransaction(String transactionId) async {
    try {
      await _ensureAuthenticated();
      await pb.collection('payment_transactions').delete(transactionId);
    } catch (e) {
      print('Error deleting payment transaction: $e');
      rethrow;
    }
  }

  /// Get payment statistics for a user
  Future<PaymentStatistics> getPaymentStatistics(String userId) async {
    try {
      await _ensureAuthenticated();

      // Get user's join date
      final userRecord = await getUser(userId);
      if (userRecord == null) {
        return const PaymentStatistics(
          totalMonths: 0,
          paidCount: 0,
          pendingCount: 0,
          waivedCount: 0,
          overdueCount: 0,
          totalPaidAmount: 0,
          totalExpectedAmount: 0,
        );
      }

      final joinedDateString = userRecord.data['joinedDate'] as String?;
      if (joinedDateString == null) {
        return const PaymentStatistics(
          totalMonths: 0,
          paidCount: 0,
          pendingCount: 0,
          waivedCount: 0,
          overdueCount: 0,
          totalPaidAmount: 0,
          totalExpectedAmount: 0,
        );
      }

      final joinedDate = DateTime.parse(joinedDateString);
      final transactions = await getPaymentTransactions(userId);

      // Calculate expected months
      final expectedMonths = getExpectedMonths(joinedDate);
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      // Count statistics
      var paidCount = 0;
      var pendingCount = 0;
      var waivedCount = 0;
      var overdueCount = 0;
      var totalPaidAmount = 0.0;
      DateTime? lastPaymentDate;
      String? lastPaymentMethod;

      for (final month in expectedMonths) {
        final transaction = transactions.cast<PaymentTransaction?>().firstWhere(
              (t) => t?.month == month,
              orElse: () => null,
            );

        if (transaction != null) {
          if (transaction.isPaid) {
            paidCount++;
            totalPaidAmount += transaction.amount;
            if (lastPaymentDate == null || (transaction.paymentDate?.isAfter(lastPaymentDate) ?? false)) {
              lastPaymentDate = transaction.paymentDate;
              lastPaymentMethod = transaction.paymentMethod?.displayName;
            }
          } else if (transaction.isWaived) {
            waivedCount++;
          } else if (transaction.isPending) {
            pendingCount++;
            final monthDate = DateTime.parse('$month-01');
            if (monthDate.isBefore(currentMonth)) {
              overdueCount++;
            }
          }
        } else {
          // No record exists, count as pending
          pendingCount++;
          final monthDate = DateTime.parse('$month-01');
          if (monthDate.isBefore(currentMonth)) {
            overdueCount++;
          }
        }
      }

      return PaymentStatistics(
        totalMonths: expectedMonths.length,
        paidCount: paidCount,
        pendingCount: pendingCount,
        waivedCount: waivedCount,
        overdueCount: overdueCount,
        totalPaidAmount: totalPaidAmount,
        totalExpectedAmount: expectedMonths.length * 100.0,
        lastPaymentDate: lastPaymentDate,
        lastPaymentMethod: lastPaymentMethod,
      );
    } catch (e) {
      print('Error getting payment statistics: $e');
      return const PaymentStatistics(
        totalMonths: 0,
        paidCount: 0,
        pendingCount: 0,
        waivedCount: 0,
        overdueCount: 0,
        totalPaidAmount: 0,
        totalExpectedAmount: 0,
      );
    }
  }

  /// Get list of expected payment months from join date to current month
  List<String> getExpectedMonths(DateTime joinedDate) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final joinMonth = DateTime(joinedDate.year, joinedDate.month);

    final months = <String>[];
    var date = joinMonth;

    while (date.isBefore(currentMonth) || date.isAtSameMomentAs(currentMonth)) {
      months.add(DateFormat('yyyy-MM').format(date));
      // Move to next month
      date = DateTime(date.year, date.month + 1);
    }

    return months;
  }

  /// Initialize payment records for a user (creates pending records for all expected months)
  Future<void> initializePaymentRecords(String userId, DateTime joinedDate) async {
    try {
      await _ensureAuthenticated();

      final expectedMonths = getExpectedMonths(joinedDate);
      final existingTransactions = await getPaymentTransactions(userId);
      final existingMonths = existingTransactions.map((t) => t.month).toSet();

      // Create records for months that don't exist yet
      for (final month in expectedMonths) {
        if (!existingMonths.contains(month)) {
          await updatePaymentTransaction(
            userId: userId,
            month: month,
            status: PaymentStatus.pending,
          );
        }
      }
    } catch (e) {
      print('Error initializing payment records: $e');
      rethrow;
    }
  }

  /// Subscribe to payment transactions updates
  Future<UnsubscribeFunc> subscribeToPaymentTransactions(
    void Function(RecordModel) onUpdate,
  ) async {
    return pb.collection('payment_transactions').subscribe('*', (e) {
      if ((e.action == 'create' || e.action == 'update' || e.action == 'delete') && e.record != null) {
        onUpdate(e.record!);
      }
    });
  }

  /// Get name of user who recorded the payment (for audit trail)
  Future<String> getRecordedByName(String? recordedById) async {
    if (recordedById == null || recordedById.isEmpty) return 'System';

    try {
      final userRecord = await getUser(recordedById);
      if (userRecord == null) return 'Unknown';

      final firstName = userRecord.data['firstName'] as String? ?? '';
      final lastName = userRecord.data['lastName'] as String? ?? '';
      return '$firstName $lastName'.trim();
    } catch (e) {
      print('Error getting recorded by name: $e');
      return 'Unknown';
    }
  }

  // ========================================================================
  // Analytics Methods
  // ========================================================================

  /// Get all payment transactions (admin only) within date range
  Future<List<PaymentTransaction>> getAllPaymentTransactions({
    String? startMonth,
    String? endMonth,
  }) async {
    try {
      await _ensureAuthenticated();

      var filter = '';
      if (startMonth != null && endMonth != null) {
        filter = 'month >= "$startMonth" && month <= "$endMonth"';
      }

      final result = await pb.collection('payment_transactions').getList(
            filter: filter,
            sort: '-month',
            expand: 'user,recorded_by',
            perPage: 5000,
          );

      return result.items.map(PaymentTransaction.fromRecord).toList();
    } catch (e) {
      print('Error getting all payment transactions: $e');
      return [];
    }
  }

  /// Get system-wide analytics for admin dashboard
  Future<PaymentAnalytics> getSystemWideAnalytics({
    String? startMonth,
    String? endMonth,
  }) async {
    try {
      // Get all transactions in the date range
      final transactions = await getAllPaymentTransactions(
        startMonth: startMonth,
        endMonth: endMonth,
      );

      if (transactions.isEmpty) {
        return PaymentAnalytics.empty();
      }

      // Calculate overall statistics
      final paidTransactions = transactions.where((t) => t.status == PaymentStatus.paid).toList();
      final totalRevenue = paidTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final avgPayment = paidTransactions.isEmpty ? 0.0 : totalRevenue / paidTransactions.length;

      // Group by month for monthly revenue
      final monthlyRevenueMap = <String, MonthlyRevenue>{};
      for (final transaction in transactions) {
        final month = transaction.month;
        final existing = monthlyRevenueMap[month];

        if (existing == null) {
          monthlyRevenueMap[month] = MonthlyRevenue(
            month: month,
            totalAmount: transaction.isPaid ? transaction.amount : 0,
            transactionCount: 1,
            paidCount: transaction.isPaid ? 1 : 0,
            pendingCount: transaction.isPending ? 1 : 0,
            waivedCount: transaction.isWaived ? 1 : 0,
          );
        } else {
          monthlyRevenueMap[month] = MonthlyRevenue(
            month: month,
            totalAmount: existing.totalAmount + (transaction.isPaid ? transaction.amount : 0),
            transactionCount: existing.transactionCount + 1,
            paidCount: existing.paidCount + (transaction.isPaid ? 1 : 0),
            pendingCount: existing.pendingCount + (transaction.isPending ? 1 : 0),
            waivedCount: existing.waivedCount + (transaction.isWaived ? 1 : 0),
          );
        }
      }

      final monthlyRevenues = monthlyRevenueMap.values.toList()..sort((a, b) => a.month.compareTo(b.month));

      // Calculate payment method statistics
      final methodCounts = <PaymentMethod, int>{};
      final methodAmounts = <PaymentMethod, double>{};

      for (final transaction in paidTransactions) {
        if (transaction.paymentMethod != null) {
          final method = transaction.paymentMethod!;
          methodCounts[method] = (methodCounts[method] ?? 0) + 1;
          methodAmounts[method] = (methodAmounts[method] ?? 0) + transaction.amount;
        }
      }

      final totalPaidCount = paidTransactions.length;
      final paymentMethodStats = <PaymentMethodStats>[];

      for (final method in PaymentMethod.values) {
        final count = methodCounts[method] ?? 0;
        if (count > 0) {
          paymentMethodStats.add(
            PaymentMethodStats(
              method: method,
              count: count,
              totalAmount: methodAmounts[method] ?? 0,
              percentage: totalPaidCount > 0 ? (count / totalPaidCount) * 100 : 0,
            ),
          );
        }
      }

      // Calculate compliance rates by month
      final complianceMap = <String, ComplianceRate>{};
      for (final transaction in transactions) {
        final month = transaction.month;
        final existing = complianceMap[month];

        if (existing == null) {
          complianceMap[month] = ComplianceRate(
            month: month,
            totalExpected: 1,
            paidCount: transaction.isPaid ? 1 : 0,
            waivedCount: transaction.isWaived ? 1 : 0,
            pendingCount: transaction.isPending ? 1 : 0,
            overdueCount: transaction.isPending && transaction.isOverdue ? 1 : 0,
          );
        } else {
          complianceMap[month] = ComplianceRate(
            month: month,
            totalExpected: existing.totalExpected + 1,
            paidCount: existing.paidCount + (transaction.isPaid ? 1 : 0),
            waivedCount: existing.waivedCount + (transaction.isWaived ? 1 : 0),
            pendingCount: existing.pendingCount + (transaction.isPending ? 1 : 0),
            overdueCount: existing.overdueCount + (transaction.isPending && transaction.isOverdue ? 1 : 0),
          );
        }
      }

      final complianceRates = complianceMap.values.toList()..sort((a, b) => a.month.compareTo(b.month));

      // Calculate overall compliance rate
      final totalExpected = transactions.length;
      final totalPaid = transactions.where((t) => t.isPaid || t.isWaived).length;
      final overallCompliance = totalExpected > 0 ? (totalPaid / totalExpected) * 100.0 : 0.0;

      return PaymentAnalytics(
        totalRevenue: totalRevenue,
        totalTransactions: transactions.length,
        averagePaymentAmount: avgPayment,
        overallComplianceRate: overallCompliance,
        monthlyRevenues: monthlyRevenues,
        paymentMethodStats: paymentMethodStats,
        complianceRates: complianceRates,
        startMonth: startMonth ?? '',
        endMonth: endMonth ?? '',
      );
    } catch (e) {
      print('Error calculating system-wide analytics: $e');
      return PaymentAnalytics.empty();
    }
  }

  /// Get user-specific analytics
  Future<PaymentAnalytics> getUserAnalytics(
    String userId, {
    String? startMonth,
    String? endMonth,
  }) async {
    try {
      await _ensureAuthenticated();

      // Get user's transactions
      var transactions = await getPaymentTransactions(userId);

      // Filter by date range if provided
      if (startMonth != null && endMonth != null) {
        transactions = transactions
            .where(
              (t) => t.month.compareTo(startMonth) >= 0 && t.month.compareTo(endMonth) <= 0,
            )
            .toList();
      }

      if (transactions.isEmpty) {
        return PaymentAnalytics.empty();
      }

      // Calculate overall statistics
      final paidTransactions = transactions.where((t) => t.status == PaymentStatus.paid).toList();
      final totalRevenue = paidTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final avgPayment = paidTransactions.isEmpty ? 0.0 : totalRevenue / paidTransactions.length;

      // Monthly revenue (user version)
      final monthlyRevenueMap = <String, MonthlyRevenue>{};
      for (final transaction in transactions) {
        monthlyRevenueMap[transaction.month] = MonthlyRevenue(
          month: transaction.month,
          totalAmount: transaction.isPaid ? transaction.amount : 0,
          transactionCount: 1,
          paidCount: transaction.isPaid ? 1 : 0,
          pendingCount: transaction.isPending ? 1 : 0,
          waivedCount: transaction.isWaived ? 1 : 0,
        );
      }

      final monthlyRevenues = monthlyRevenueMap.values.toList()..sort((a, b) => a.month.compareTo(b.month));

      // Payment method statistics for user
      final methodCounts = <PaymentMethod, int>{};
      final methodAmounts = <PaymentMethod, double>{};

      for (final transaction in paidTransactions) {
        if (transaction.paymentMethod != null) {
          final method = transaction.paymentMethod!;
          methodCounts[method] = (methodCounts[method] ?? 0) + 1;
          methodAmounts[method] = (methodAmounts[method] ?? 0) + transaction.amount;
        }
      }

      final totalPaidCount = paidTransactions.length;
      final paymentMethodStats = <PaymentMethodStats>[];

      for (final method in PaymentMethod.values) {
        final count = methodCounts[method] ?? 0;
        if (count > 0) {
          paymentMethodStats.add(
            PaymentMethodStats(
              method: method,
              count: count,
              totalAmount: methodAmounts[method] ?? 0,
              percentage: totalPaidCount > 0 ? (count / totalPaidCount) * 100 : 0,
            ),
          );
        }
      }

      // Compliance by month (for user)
      final complianceMap = <String, ComplianceRate>{};
      for (final transaction in transactions) {
        complianceMap[transaction.month] = ComplianceRate(
          month: transaction.month,
          totalExpected: 1,
          paidCount: transaction.isPaid ? 1 : 0,
          waivedCount: transaction.isWaived ? 1 : 0,
          pendingCount: transaction.isPending ? 1 : 0,
          overdueCount: transaction.isPending && transaction.isOverdue ? 1 : 0,
        );
      }

      final complianceRates = complianceMap.values.toList()..sort((a, b) => a.month.compareTo(b.month));

      // Overall compliance
      final totalExpected = transactions.length;
      final totalPaid = transactions.where((t) => t.isPaid || t.isWaived).length;
      final overallCompliance = totalExpected > 0 ? (totalPaid / totalExpected) * 100.0 : 0.0;

      return PaymentAnalytics(
        totalRevenue: totalRevenue,
        totalTransactions: transactions.length,
        averagePaymentAmount: avgPayment,
        overallComplianceRate: overallCompliance,
        monthlyRevenues: monthlyRevenues,
        paymentMethodStats: paymentMethodStats,
        complianceRates: complianceRates,
        startMonth: startMonth ?? '',
        endMonth: endMonth ?? '',
      );
    } catch (e) {
      print('Error calculating user analytics: $e');
      return PaymentAnalytics.empty();
    }
  }
}
