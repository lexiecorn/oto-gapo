import 'package:authentication_repository/src/models/auth_failure.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseAuthRepository {
  PocketBase? _pocketBase;
  bool _isInitialized = false;

  PocketBase get pocketBase {
    if (!_isInitialized) {
      _pocketBase = PocketBase(
        FlavorConfig.instance.variables['pocketbaseUrl'] as String,
      );
      _isInitialized = true;
    }
    return _pocketBase!;
  }

  /// Stream of authentication state changes
  Stream<RecordModel?> get user {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return pocketBase.authStore.model as RecordModel?;
    }).distinct();
  }

  /// Get current authenticated user
  RecordModel? get currentUser => pocketBase.authStore.model as RecordModel?;

  /// Check if user is authenticated
  bool get isAuthenticated => pocketBase.authStore.isValid;

  /// Sign up with email and password
  Future<RecordModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
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

      final authData = await pocketBase.collection('users').create(body: data);
      return authData;
    } catch (e) {
      throw AuthFailure(
        code: 'Sign Up Failed',
        message: e.toString(),
        plugin: 'pocketbase_auth',
      );
    }
  }

  /// Sign in with email and password
  Future<RecordModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authData = await pocketBase.collection('users').authWithPassword(
            email,
            password,
          );
      return authData.record ?? (throw Exception('Authentication failed - no user record returned'));
    } catch (e) {
      throw AuthFailure(
        code: 'Sign In Failed',
        message: e.toString(),
        plugin: 'pocketbase_auth',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    pocketBase.authStore.clear();
  }

  /// Update user profile
  Future<RecordModel> updateProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    return pocketBase.collection('users').update(user.id, body: data);
  }

  /// Get user profile
  Future<RecordModel> getProfile() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    // Return the current user's data from auth store instead of making API call
    // This avoids the 403 "Only superusers can perform this action" error
    return user;
  }

  /// Get vehicles by owner ID
  Future<List<RecordModel>> getVehiclesByOwner(String ownerId) async {
    try {
      print('PocketBaseAuthRepository.getVehiclesByOwner - Getting vehicles for owner: $ownerId');

      // Query vehicles collection with filter for user field
      final result = await pocketBase.collection('vehicles').getList(
            filter: 'user = "$ownerId"',
          );

      print('PocketBaseAuthRepository.getVehiclesByOwner - Found ${result.items.length} vehicles');
      return result.items;
    } catch (e) {
      print('PocketBaseAuthRepository.getVehiclesByOwner - Exception: $e');
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await pocketBase.collection('users').requestPasswordReset(email);
    } catch (e) {
      throw AuthFailure(
        code: 'Password Reset Failed',
        message: e.toString(),
        plugin: 'pocketbase_auth',
      );
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      await pocketBase.collection('users').confirmPasswordReset(
            token,
            password,
            password,
          );
    } catch (e) {
      throw AuthFailure(
        code: 'Password Reset Confirmation Failed',
        message: e.toString(),
        plugin: 'pocketbase_auth',
      );
    }
  }
}
