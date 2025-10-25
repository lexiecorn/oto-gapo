import 'package:authentication_repository/src/models/auth_failure.dart';
import 'package:authentication_repository/src/persistent_auth_store.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:local_storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class PocketBaseAuthRepository {
  // Singleton pattern with LocalStorage dependency
  factory PocketBaseAuthRepository({LocalStorage? storage}) {
    if (storage != null) {
      _instance._storage = storage;
    }
    return _instance;
  }
  PocketBaseAuthRepository._internal();
  static final PocketBaseAuthRepository _instance = PocketBaseAuthRepository._internal();

  PocketBase? _pocketBase;
  bool _isInitialized = false;
  LocalStorage? _storage;

  /// Initialize PocketBase with persistent auth store.
  ///
  /// This must be called before accessing [pocketBase] to ensure
  /// authentication persistence works correctly.
  Future<void> initialize() async {
    if (_isInitialized) return;

    final url = FlavorConfig.instance.variables['pocketbaseUrl'] as String? ?? 'https://pb.lexserver.org';

    try {
      // If storage is available, use persistent auth store
      if (_storage != null) {
        final persistentStore = PersistentAuthStore(_storage!);
        final authStore = await persistentStore.createAuthStore();
        _pocketBase = PocketBase(url, authStore: authStore);
      } else {
        // Fallback to default auth store if storage is not available
        _pocketBase = PocketBase(url);
      }

      _isInitialized = true;
    } catch (e) {
      // If initialization fails, create a basic PocketBase instance
      // This prevents the app from hanging on network issues
      print('PocketBase initialization failed: $e');
      _pocketBase = PocketBase(url);
      _isInitialized = true;
    }
  }

  PocketBase get pocketBase {
    if (!_isInitialized) {
      throw StateError(
        'PocketBaseAuthRepository not initialized. '
        'Call initialize() before accessing pocketBase.',
      );
    }
    return _pocketBase!;
  }

  /// Stream of authentication state changes
  Stream<RecordModel?> get user {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
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
      print('🔐 Attempting to sign in with email: $email');

      final authData = await pocketBase.collection('users').authWithPassword(
            email,
            password,
          );

      print('✅ Sign in successful for user: ${authData.record.data['email']}');
      return authData.record;
    } catch (e) {
      print('❌ Sign in failed: $e');
      throw AuthFailure(
        code: 'Sign In Failed',
        message: e.toString(),
        plugin: 'pocketbase_auth',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out from PocketBase...');
      pocketBase.authStore.clear();
      print('✅ Successfully signed out from PocketBase');
    } catch (e) {
      print('❌ Error during sign out: $e');
      // Still clear the store even if there's an error
      pocketBase.authStore.clear();
    }
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

  /// Get user by email
  Future<RecordModel?> getUserByEmail(String email) async {
    try {
      print('PocketBaseAuthRepository.getUserByEmail - Getting user by email: $email');
      print('PocketBaseAuthRepository.getUserByEmail - Is authenticated: ${pocketBase.authStore.isValid}');
      print('PocketBaseAuthRepository.getUserByEmail - Current user: ${pocketBase.authStore.model?.id}');

      // Query users collection with filter for email
      final result = await pocketBase.collection('users').getList(
            filter: 'email = "$email"',
            perPage: 1,
          );

      final user = result.items.isNotEmpty ? result.items.first : null;
      print('PocketBaseAuthRepository.getUserByEmail - User found: ${user != null}');
      if (user != null) {
        print('PocketBaseAuthRepository.getUserByEmail - User ID: ${user.id}');
        print('PocketBaseAuthRepository.getUserByEmail - User email: ${user.data['email']}');
      }
      return user;
    } catch (e) {
      print('PocketBaseAuthRepository.getUserByEmail - Exception: $e');
      print('PocketBaseAuthRepository.getUserByEmail - Exception type: ${e.runtimeType}');
      return null; // Return null instead of rethrowing to handle gracefully
    }
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

  /// Sign in with Google OAuth using PocketBase native OAuth2
  Future<RecordModel> signInWithGoogleOAuth() async {
    try {
      print('🔍 Starting PocketBase Google OAuth flow');

      // Use PocketBase's native OAuth2 with Google
      // This method initializes a one-off realtime subscription and will
      // call the provided urlCallback with the OAuth2 vendor url to authenticate.
      final authData = await pocketBase.collection('users').authWithOAuth2(
        'google',
        (url) async {
          print('🔗 Opening OAuth URL: $url');
          try {
            // Use url_launcher to open the OAuth URL
            final launched = await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );

            if (!launched) {
              throw Exception('Failed to open OAuth URL');
            }

            print('✅ OAuth URL opened successfully');
            print('⚠️  IMPORTANT: Do not close the browser window manually!');
            print('⚠️  Let Google redirect back automatically to complete authentication.');
          } catch (e) {
            print('❌ Failed to open OAuth URL: $e');
            throw Exception('Failed to open OAuth URL: $e');
          }
        },
      );

      print('✅ PocketBase Google OAuth successful');
      print('✅ Authenticated user: ${authData.record.data['email']}');
      print('✅ Auth store valid: ${pocketBase.authStore.isValid}');
      print('✅ Auth token: ${pocketBase.authStore.token}');

      return authData.record;
    } catch (e) {
      print('❌ PocketBase Google OAuth failed: $e');

      // Handle specific OAuth errors
      if (e.toString().contains('popup') || e.toString().contains('blocked')) {
        throw AuthFailure(
          code: 'OAuth Popup Blocked',
          message: 'Google sign-in popup was blocked. Please allow popups and try again.',
          plugin: 'pocketbase_oauth',
        );
      }

      if (e.toString().contains('cancelled') ||
          e.toString().contains('canceled') ||
          e.toString().contains('aborted') ||
          e.toString().contains('interrupted')) {
        throw AuthFailure(
          code: 'OAuth Cancelled',
          message: 'Google sign-in was cancelled or interrupted. Please try again.',
          plugin: 'pocketbase_oauth',
        );
      }

      // Handle realtime connection issues
      if (e.toString().contains('realtime') || e.toString().contains('connection')) {
        throw AuthFailure(
          code: 'OAuth Connection Error',
          message:
              'OAuth connection was interrupted. Please ensure the browser window remains open during authentication.',
          plugin: 'pocketbase_oauth',
        );
      }

      // Handle realtime connection issues (Android 15+ specific)
      if (e.toString().contains('realtime') || e.toString().contains('connection')) {
        throw AuthFailure(
          code: 'OAuth Connection Error',
          message:
              'OAuth connection was interrupted. This may be due to Android 15+ background restrictions. Please:\n\n1. Keep the browser window open during authentication\n2. Do not manually close the browser\n3. Let Google redirect back automatically',
          plugin: 'pocketbase_oauth',
        );
      }

      // Handle Android 15+ background processing issues
      if (e.toString().contains('background') || e.toString().contains('foreground')) {
        throw AuthFailure(
          code: 'Android 15+ Background Restriction',
          message:
              'Authentication failed due to Android 15+ background processing restrictions. Please try again and ensure the browser stays open.',
          plugin: 'pocketbase_oauth',
        );
      }

      if (e is AuthFailure) {
        rethrow;
      }

      throw AuthFailure(
        code: 'Google OAuth Sign-In Failed',
        message: e.toString(),
        plugin: 'pocketbase_google_oauth',
      );
    }
  }
}
