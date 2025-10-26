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

      // Check if user is authenticated - use more robust check
      final authUser = pocketBaseAuth.currentUser;
      if (authUser == null) {
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

      final user = my_auth_repo.User.fromJson(userData);
      print('ProfileRepository.getProfile - User created successfully');
      return user;
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

      // Ensure user is authenticated before making API calls
      if (pocketBaseAuth.currentUser == null) {
        throw ProfileFailure(
          code: 'Not Authenticated',
          message: 'User is not authenticated with PocketBase',
          plugin: 'pocketbase_auth',
        );
      }

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

        // Year is already a number from PocketBase, no conversion needed

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

  /// Get awards for a user's vehicles
  Future<List<my_auth_repo.VehicleAward>> getUserVehicleAwards(String userId) async {
    try {
      print('ProfileRepository.getUserVehicleAwards - Getting awards for user: $userId');

      // Ensure user is authenticated before making API calls
      if (pocketBaseAuth.currentUser == null) {
        throw ProfileFailure(
          code: 'Not Authenticated',
          message: 'User is not authenticated with PocketBase',
          plugin: 'pocketbase_auth',
        );
      }

      // First get the user's vehicles
      final vehicles = await getUserVehicles(userId);
      if (vehicles.isEmpty) {
        print('ProfileRepository.getUserVehicleAwards - No vehicles found for user');
        return [];
      }

      // Get all vehicle IDs
      final vehicleIds = vehicles.map((v) => v.id).where((id) => id != null).cast<String>().toList();
      if (vehicleIds.isEmpty) {
        print('ProfileRepository.getUserVehicleAwards - No valid vehicle IDs found');
        return [];
      }

      // Query awards for all user's vehicles
      final awardsResponse = await pocketBaseAuth.pocketBase.collection('vehicle_awards').getList(
            page: 1,
            perPage: 500,
            sort: '-event_date',
            filter: vehicleIds.map((id) => 'vehicle_id = "$id"').join(' || '),
          );

      final awards = awardsResponse.items.map<my_auth_repo.VehicleAward>((item) {
        final data = Map<String, dynamic>.from(item.data);
        data['id'] = item.id;

        // Handle type conversions for fields that might come as different types
        if (data['vehicle_id'] != null) {
          data['vehicleId'] = data['vehicle_id'].toString();
        } else {
          data['vehicleId'] = ''; // Provide default for required field
        }

        if (data['created_by'] != null) {
          data['createdBy'] = data['created_by'].toString();
        }

        // Handle required string fields - provide defaults if null
        if (data['award_name'] == null) {
          data['awardName'] = 'Unknown Award';
        } else {
          data['awardName'] = data['award_name'].toString();
        }

        if (data['event_name'] == null) {
          data['eventName'] = 'Unknown Event';
        } else {
          data['eventName'] = data['event_name'].toString();
        }

        // Handle date fields - convert from ISO string to DateTime if needed
        if (data['event_date'] != null && data['event_date'] is String) {
          data['eventDate'] = data['event_date'];
        } else if (data['event_date'] != null) {
          // Handle if it's already a DateTime object
          data['eventDate'] = data['event_date'];
        } else {
          // Provide default date if null
          data['eventDate'] = DateTime.now().toIso8601String();
        }

        if (data['created_at'] != null && data['created_at'] is String) {
          data['createdAt'] = data['created_at'];
        }
        if (data['updated_at'] != null && data['updated_at'] is String) {
          data['updatedAt'] = data['updated_at'];
        }

        return my_auth_repo.VehicleAward.fromJson(data);
      }).toList();

      print('ProfileRepository.getUserVehicleAwards - Found ${awards.length} awards for user');
      return awards;
    } catch (e) {
      print('ProfileRepository.getUserVehicleAwards - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }
}
