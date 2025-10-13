// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:authentication_repository/src/models/auth_failure.dart';
import 'package:authentication_repository/src/models/token_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:local_storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';

/// Firaebause API Eception
class FirebaseAuthApiFailure implements Exception {
  ///
  const FirebaseAuthApiFailure([
    this.message = 'An unknown exception occurred',
    this.code = 'An unknown exeption code',
    this.plugin = 'An unknown plugin exception',
  ]);

  /// error message
  final String message;

  /// error code
  final String code;

  /// error plugin
  final String plugin;

  @override
  String toString() => 'FirebaseAuthApiFailure(message: $message, code: $code, plugin: $plugin)';
}

/// Authentication Repository

class AuthRepository {
  ///
  AuthRepository({
    required Dio client,
    required LocalStorage storage,
  }) : _storage = storage {
    _fresh = Fresh<String>(
      httpClient: client,
      tokenStorage: AuthTokenStorage(_storage),
      tokenHeader: (token) => {
        'Authorization': 'Bearer $token',
      },
      refreshToken: (token, client) async {
        if (token != null) {
          return token;
        }
        return '';
      },
    );

    // Add fresh as an interceptor to the Dio client to automatically
    // add the token to all requests.
    client.interceptors.add(_fresh);
  }

  late final Fresh<String> _fresh;
  final LocalStorage _storage;
  PocketBase? _pocketBase;
  bool _isPocketBaseInitialized = false;

  ///
  final fb_auth.FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// Get PocketBase instance (lazy initialization)
  PocketBase get pocketBase {
    if (!_isPocketBaseInitialized) {
      _pocketBase = PocketBase(
        FlavorConfig.instance.variables['pocketbaseUrl'] as String,
      );
      _isPocketBaseInitialized = true;
    }
    return _pocketBase!;
  }

  /// Initialize PocketBase (lazy initialization)
  void initPocketBase() {
    // Lazy initialization - will be called when first accessed
    if (!_isPocketBaseInitialized) {
      _pocketBase = PocketBase(
        FlavorConfig.instance.variables['pocketbaseUrl'] as String,
      );
      _isPocketBaseInitialized = true;
    }
  }

  ///
  Stream<fb_auth.User?> get user => firebaseAuth.authStateChanges().asyncMap((user) async {
        if (user == null) {
          await _fresh.clearToken();
          return null;
        }

        /// Fetch the authorization token from the currently logged in user
        final token = await user.getIdToken();
        await _fresh.setToken(token);

        return user;
      });

  Future<void> currentUserChangeListener() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      FirebaseAuth.instance.currentUser?.reload();
    });
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle({required String idToken, String? displayName}) async {
    try {
      // 1. Exchange the Google ID token for a Firebase credential
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // 2. Sign in with Firebase using the credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);

      // Update user display name if provided and different
      if (displayName != null && userCredential.user?.displayName != displayName) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Sync with PocketBase
      if (userCredential.user != null) {
        await _syncUserWithPocketBase(userCredential.user!);
      }

      return userCredential;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(
        code: 'Google Sign-In Failed',
        message: e.message,
        plugin: e.plugin,
      );
    } catch (e) {
      throw AuthFailure(
        code: 'Google Sign-In Exception',
        message: e.toString(),
        plugin: 'flutter_error/google_sign_in_error',
      );
    }
  }

  /// Signin
  Future<UserCredential?> signin({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sync with PocketBase
      if (userCredential.user != null) {
        await _syncUserWithPocketBase(userCredential.user!);
      }

      return userCredential;
    } on fb_auth.FirebaseAuthException catch (e) {
      // throw FirebaseAuthApiFailure(e.message.toString());

      throw AuthFailure(
        code: 'Login Failed',
        message: e.message,
        plugin: e.plugin,
      );
    } catch (e) {
      throw AuthFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  /// Sign out
  Future<void> signout() async {
    await firebaseAuth.signOut();
  }

  /// Sync Firebase user with PocketBase
  Future<void> _syncUserWithPocketBase(User firebaseUser) async {
    try {
      // Check if user exists in PocketBase
      final existingUser = await _getUserByFirebaseUid(firebaseUser.uid);

      if (existingUser == null) {
        // Create new user in PocketBase
        await _createUserWithFirebaseUid(
          firebaseUid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: firebaseUser.displayName?.split(' ').first ?? '',
          lastName: firebaseUser.displayName?.split(' ').last ?? '',
        );
      }
    } catch (e) {
      print('Error syncing user with PocketBase: $e');
    }
  }

  /// Get user by Firebase UID from PocketBase
  Future<RecordModel?> _getUserByFirebaseUid(String firebaseUid) async {
    try {
      final result = await pocketBase.collection('users').getList(
            filter: 'firebaseUid = "$firebaseUid"',
            perPage: 1,
          );
      return result.items.isNotEmpty ? result.items.first : null;
    } catch (e) {
      print('Error getting user from PocketBase: $e');
      return null;  
    }
  }

  /// Create user with Firebase UID in PocketBase
  Future<RecordModel> _createUserWithFirebaseUid({
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

    return pocketBase.collection('users').create(body: data);
  }

  /// Get current user data from PocketBase
  Future<RecordModel?> getCurrentUserData() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    return _getUserByFirebaseUid(user.uid);
  }

  /// Update user data in PocketBase
  Future<RecordModel> updateUserData(Map<String, dynamic> data) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final pocketBaseUser = await _getUserByFirebaseUid(user.uid);
    if (pocketBaseUser == null) throw Exception('User not found in PocketBase');

    return pocketBase.collection('users').update(pocketBaseUser.id, body: data);
  }

  /// Get announcements from PocketBase
  Future<List<RecordModel>> getAnnouncements() async {
    final result = await pocketBase.collection('Announcements').getList(
          sort: '-created',
          filter: 'isActive = true',
        );
    return result.items;
  }

  /// Get app data from PocketBase
  Future<RecordModel?> getAppData(String key) async {
    try {
      final result = await pocketBase.collection('app_data').getList(
            filter: 'key = "$key"',
            perPage: 1,
          );
      return result.items.isNotEmpty ? result.items.first : null;
    } catch (e) {
      print('Error getting app data: $e');
      return null;
    }
  }
}
