import 'package:fresh_dio/fresh_dio.dart';
import 'package:local_storage/local_storage.dart';

/// This handles the authentication token storage which is used by the main
/// [Fresh] instance.
class AuthTokenStorage implements TokenStorage<String> {
  /// {@macro auth_token_storage}
  const AuthTokenStorage(this._storage);

  /// The key used to store the token in the [LocalStorage].
  static const _tokenKey = '__auth_token__';

  final LocalStorage _storage;

  @override
  Future<void> delete() {
    return _storage.write(_tokenKey, '');
  }

  @override
  Future<String?> read() {
    return _storage.read<String>(_tokenKey);
  }

  @override
  Future<void> write(String token) {
    return _storage.write(_tokenKey, token);
  }
}
