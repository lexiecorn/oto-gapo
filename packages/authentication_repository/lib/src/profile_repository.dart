import 'package:authentication_repository/authentication_repository.dart' as my_auth_repo;
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:authentication_repository/src/profile_failure.dart';

///Profile Repository
class ProfileRepository {
  ///
  ProfileRepository({
    required this.pocketBaseAuth,
  });

  ///
  final PocketBaseAuthRepository pocketBaseAuth;

  /// Get User Profile from PocketBase (authenticated user)
  Future<my_auth_repo.User> getProfile() async {
    try {
      print('ProfileRepository.getProfile - Getting current user profile');

      // Check if user is authenticated
      if (!pocketBaseAuth.isAuthenticated) {
        print('ProfileRepository.getProfile - User not authenticated with PocketBase');
        print(
          'ProfileRepository.getProfile - PocketBase auth store valid: ${pocketBaseAuth.pocketBase.authStore.isValid}',
        );
        print(
          'ProfileRepository.getProfile - PocketBase auth store model: ${pocketBaseAuth.pocketBase.authStore.model}',
        );

        throw ProfileFailure(
          code: 'Not Authenticated',
          message: 'User is not authenticated with PocketBase',
          plugin: 'pocketbase_auth',
        );
      }

      // Get current authenticated user's profile
      final userRecord = await pocketBaseAuth.getProfile();
      print('ProfileRepository.getProfile - User found with ID: ${userRecord.id}');
      print('ProfileRepository.getProfile - User email: ${userRecord.data['email']}');
      print('ProfileRepository.getProfile - User firstName: ${userRecord.data['firstName']}');
      print('ProfileRepository.getProfile - All user data keys: ${userRecord.data.keys.toList()}');
      print('ProfileRepository.getProfile - Sample data: ${userRecord.data}');

      // Convert PocketBase record to User model
      final userData = userRecord.data;
      userData['uid'] = userRecord.id;

      // Handle type conversions for fields that might come as different types
      // Convert memberNumber from int to String (schema shows it's number type)
      if (userData['memberNumber'] != null) {
        userData['memberNumber'] = userData['memberNumber'].toString();
      }

      // membership_type should remain as num (User model expects num?)
      // No conversion needed since schema provides it as number type

      // contactNumber, emergencyContactNumber, spouseContactNumber are now text type in schema
      // so they should come as String, but we'll handle conversion just in case
      if (userData['contactNumber'] != null && userData['contactNumber'] is! String) {
        userData['contactNumber'] = userData['contactNumber'].toString();
      }

      if (userData['emergencyContactNumber'] != null && userData['emergencyContactNumber'] is! String) {
        userData['emergencyContactNumber'] = userData['emergencyContactNumber'].toString();
      }

      if (userData['spouseContactNumber'] != null && userData['spouseContactNumber'] is! String) {
        userData['spouseContactNumber'] = userData['spouseContactNumber'].toString();
      }

      // Note: Vehicle relation has been moved to the vehicle collection
      // Vehicles now have an 'owner' field that references the user ID
      // No need to handle vehicle field in user data anymore

      // Handle profile image field mapping
      // PocketBase uses 'profileImage' (camelCase), same as Dart model
      // No conversion needed

      // Handle date field conversion - PocketBase can return dates as ISO strings or DateTime objects
      // The User.fromJson expects dates as ISO strings, so convert DateTime objects to strings
      if (userData['birthDate'] != null) {
        if (userData['birthDate'] is DateTime) {
          userData['birthDate'] = (userData['birthDate'] as DateTime).toIso8601String();
        }
        // If it's already a String, leave it as is (will be parsed by fromJson)
      }

      if (userData['driversLicenseExpirationDate'] != null) {
        if (userData['driversLicenseExpirationDate'] is DateTime) {
          userData['driversLicenseExpirationDate'] =
              (userData['driversLicenseExpirationDate'] as DateTime).toIso8601String();
        }
        // If it's already a String, leave it as is (will be parsed by fromJson)
      }

      // Remove legacy fields if they exist
      userData.remove('dateOfBirth');
      userData.remove('birthplace');

      final currentUser = my_auth_repo.User.fromJson(userData);
      print('ProfileRepository.getProfile - User created successfully');
      return currentUser;
    } catch (e) {
      print('ProfileRepository.getProfile - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  /// Get user's vehicles from PocketBase
  Future<List<my_auth_repo.Vehicle>> getUserVehicles(String userId) async {
    try {
      print('ProfileRepository.getUserVehicles - Getting vehicles for user: $userId');

      // Query vehicles where owner field matches the user ID
      final vehicleRecords = await pocketBaseAuth.getVehiclesByOwner(userId);
      print('ProfileRepository.getUserVehicles - Found ${vehicleRecords.length} vehicles');

      // Convert RecordModel vehicles to Vehicle objects, normalizing file URLs
      final baseUrl = pocketBaseAuth.pocketBase.baseUrl;
      final authToken = pocketBaseAuth.pocketBase.authStore.token;
      final vehicles = vehicleRecords.map((record) {
        final vehicleData = Map<String, dynamic>.from(record.data);

        // Add vehicle ID from record
        vehicleData['id'] = record.id;

        // Convert year from number to String (PocketBase returns number, model expects String)
        if (vehicleData['year'] != null) {
          vehicleData['year'] = vehicleData['year'].toString();
        }

        // Normalize primaryPhoto if it's a filename (not a full URL)
        final primary = vehicleData['primaryPhoto'];
        if (primary is String && primary.isNotEmpty) {
          final isAbsolute = primary.startsWith('http');
          final url = isAbsolute ? primary : '$baseUrl/api/files/${record.collectionId}/${record.id}/$primary';
          vehicleData['primaryPhoto'] = authToken.isNotEmpty ? '$url?token=$authToken' : url;
        }

        // Normalize photos list entries if they are filenames
        final photos = vehicleData['photos'];
        if (photos is List) {
          vehicleData['photos'] = photos.map((p) {
            if (p is! String || p.isEmpty) return p;
            final isAbsolute = p.startsWith('http');
            final url = isAbsolute ? p : '$baseUrl/api/files/${record.collectionId}/${record.id}/$p';
            return authToken.isNotEmpty ? '$url?token=$authToken' : url;
          }).toList();
        }

        return my_auth_repo.Vehicle.fromJson(vehicleData);
      }).toList();

      return vehicles;
    } catch (e) {
      print('ProfileRepository.getUserVehicles - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  /// Get a single user's vehicle (system guarantees exactly one vehicle)
  Future<my_auth_repo.Vehicle?> getUserVehicle(String userId) async {
    final vehicles = await getUserVehicles(userId);
    if (vehicles.isEmpty) return null;
    return vehicles.first;
  }

  /// Update user profile
  Future<my_auth_repo.User> updateProfile(Map<String, dynamic> data) async {
    try {
      print('ProfileRepository.updateProfile - Updating user profile');

      // Update profile in PocketBase
      final updatedRecord = await pocketBaseAuth.updateProfile(data);
      print('ProfileRepository.updateProfile - Profile updated with ID: ${updatedRecord.id}');
      print('ProfileRepository.updateProfile - User email: ${updatedRecord.data['email']}');
      print('ProfileRepository.updateProfile - User firstName: ${updatedRecord.data['firstName']}');

      // Convert to User model
      final userData = updatedRecord.data;
      userData['uid'] = updatedRecord.id;

      // Handle type conversions for fields that might come as different types
      // Convert memberNumber from int to String (schema shows it's number type)
      if (userData['memberNumber'] != null) {
        userData['memberNumber'] = userData['memberNumber'].toString();
      }

      // membership_type should remain as num (User model expects num?)
      // No conversion needed since schema provides it as number type

      // contactNumber, emergencyContactNumber, spouseContactNumber are now text type in schema
      // so they should come as String, but we'll handle conversion just in case
      if (userData['contactNumber'] != null && userData['contactNumber'] is! String) {
        userData['contactNumber'] = userData['contactNumber'].toString();
      }

      if (userData['emergencyContactNumber'] != null && userData['emergencyContactNumber'] is! String) {
        userData['emergencyContactNumber'] = userData['emergencyContactNumber'].toString();
      }

      if (userData['spouseContactNumber'] != null && userData['spouseContactNumber'] is! String) {
        userData['spouseContactNumber'] = userData['spouseContactNumber'].toString();
      }

      // Note: Vehicle relation has been moved to the vehicle collection
      // Vehicles now have an 'owner' field that references the user ID
      // No need to handle vehicle field in user data anymore

      // Handle profile image field mapping
      // PocketBase uses 'profileImage' (camelCase), same as Dart model
      // No conversion needed

      // Handle date field conversion - PocketBase can return dates as ISO strings or DateTime objects
      // The User.fromJson expects dates as ISO strings, so convert DateTime objects to strings
      if (userData['birthDate'] != null) {
        if (userData['birthDate'] is DateTime) {
          userData['birthDate'] = (userData['birthDate'] as DateTime).toIso8601String();
        }
        // If it's already a String, leave it as is (will be parsed by fromJson)
      }

      if (userData['driversLicenseExpirationDate'] != null) {
        if (userData['driversLicenseExpirationDate'] is DateTime) {
          userData['driversLicenseExpirationDate'] =
              (userData['driversLicenseExpirationDate'] as DateTime).toIso8601String();
        }
        // If it's already a String, leave it as is (will be parsed by fromJson)
      }

      // Remove legacy fields if they exist
      userData.remove('dateOfBirth');
      userData.remove('birthplace');

      final currentUser = my_auth_repo.User.fromJson(userData);
      print('ProfileRepository.updateProfile - Profile updated successfully');
      return currentUser;
    } catch (e) {
      print('ProfileRepository.updateProfile - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  /// Get a specific user's profile by userId (for viewing other users)
  Future<my_auth_repo.User> getProfileByUserId(String userId) async {
    try {
      print('ProfileRepository.getProfileByUserId - Getting profile for user: $userId');

      // Get the user's profile from PocketBase
      final userRecord = await pocketBaseAuth.pocketBase.collection('users').getOne(userId);
      print('ProfileRepository.getProfileByUserId - User found with ID: ${userRecord.id}');

      // Convert to User model
      final userData = userRecord.data;
      userData['uid'] = userRecord.id;

      // Apply same data transformations as getProfile
      if (userData['memberNumber'] != null) {
        userData['memberNumber'] = userData['memberNumber'].toString();
      }

      if (userData['contactNumber'] != null && userData['contactNumber'] is! String) {
        userData['contactNumber'] = userData['contactNumber'].toString();
      }

      if (userData['emergencyContactNumber'] != null && userData['emergencyContactNumber'] is! String) {
        userData['emergencyContactNumber'] = userData['emergencyContactNumber'].toString();
      }

      if (userData['spouseContactNumber'] != null && userData['spouseContactNumber'] is! String) {
        userData['spouseContactNumber'] = userData['spouseContactNumber'].toString();
      }

      // Handle profile image field mapping
      // PocketBase uses 'profileImage' (camelCase), same as Dart model
      // No conversion needed

      if (userData['birthDate'] != null && userData['birthDate'] is DateTime) {
        userData['birthDate'] = (userData['birthDate'] as DateTime).toIso8601String();
      }

      if (userData['driversLicenseExpirationDate'] != null && userData['driversLicenseExpirationDate'] is DateTime) {
        userData['driversLicenseExpirationDate'] =
            (userData['driversLicenseExpirationDate'] as DateTime).toIso8601String();
      }

      userData.remove('dateOfBirth');
      userData.remove('birthplace');

      final user = my_auth_repo.User.fromJson(userData);
      print('ProfileRepository.getProfileByUserId - Profile loaded successfully');
      return user;
    } catch (e) {
      print('ProfileRepository.getProfileByUserId - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }
}
