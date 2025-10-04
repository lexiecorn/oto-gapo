import 'package:authentication_repository/authentication_repository.dart' as my_auth_repo;
import 'package:authentication_repository/src/profile_failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';

///Profile Repository
class ProfileRepository {
  ///
  ProfileRepository({
    required this.firebaseFirestore,
    required this.pocketBaseAuth,
  });

  ///
  final FirebaseFirestore firebaseFirestore;
  final PocketBaseAuthRepository pocketBaseAuth;

  /// Get User Profile from PocketBase (authenticated user)
  Future<my_auth_repo.User> getProfile() async {
    try {
      print('ProfileRepository.getProfile - Getting current user profile');

      // Check if user is authenticated
      if (!pocketBaseAuth.isAuthenticated) {
        print('ProfileRepository.getProfile - User not authenticated with PocketBase');
        print(
            'ProfileRepository.getProfile - PocketBase auth store valid: ${pocketBaseAuth.pocketBase.authStore.isValid}');
        print(
            'ProfileRepository.getProfile - PocketBase auth store model: ${pocketBaseAuth.pocketBase.authStore.model}');

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
      // New schema uses 'profileImage' instead of 'profile_image'
      if (userData['profileImage'] != null && userData['profile_image'] == null) {
        userData['profile_image'] = userData['profileImage'];
      }

      // Handle date field conversion - only convert if it's a string
      if (userData['birthplace'] != null) {
        // birthplace is actually a date field in the schema
        if (userData['birthplace'] is String) {
          userData['dateOfBirth'] = Timestamp.fromDate(DateTime.parse(userData['birthplace'] as String));
        }
        // If it's already a Timestamp, leave it as is
      }
      if (userData['driversLicenseExpirationDate'] != null) {
        // Only convert if it's a string, otherwise leave the Timestamp as is
        if (userData['driversLicenseExpirationDate'] is String) {
          userData['driversLicenseExpirationDate'] =
              Timestamp.fromDate(DateTime.parse(userData['driversLicenseExpirationDate'] as String));
        }
        // If it's already a Timestamp, leave it as is
      }

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

      // Convert RecordModel vehicles to Vehicle objects
      final vehicles = vehicleRecords.map((record) {
        final vehicleData = record.data;
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
      // New schema uses 'profileImage' instead of 'profile_image'
      if (userData['profileImage'] != null && userData['profile_image'] == null) {
        userData['profile_image'] = userData['profileImage'];
      }

      // Handle date field conversion - only convert if it's a string
      if (userData['birthplace'] != null) {
        // birthplace is actually a date field in the schema
        if (userData['birthplace'] is String) {
          userData['dateOfBirth'] = Timestamp.fromDate(DateTime.parse(userData['birthplace'] as String));
        }
        // If it's already a Timestamp, leave it as is
      }
      if (userData['driversLicenseExpirationDate'] != null) {
        // Only convert if it's a string, otherwise leave the Timestamp as is
        if (userData['driversLicenseExpirationDate'] is String) {
          userData['driversLicenseExpirationDate'] =
              Timestamp.fromDate(DateTime.parse(userData['driversLicenseExpirationDate'] as String));
        }
        // If it's already a Timestamp, leave it as is
      }

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
}
