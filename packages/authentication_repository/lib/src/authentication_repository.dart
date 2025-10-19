// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:authentication_repository/src/models/auth_failure.dart';
import 'package:authentication_repository/src/models/token_storage.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:local_storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';

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

  /// Removed Firebase Auth - now using PocketBase only
  /// All authentication is handled through PocketBaseAuthRepository

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
