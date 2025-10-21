import 'package:pocketbase/pocketbase.dart';

/// Service class for PocketBase operations
class PocketBaseService {
  const PocketBaseService({
    required PocketBase client,
  }) : _client = client;

  final PocketBase _client;

  /// Get the PocketBase client
  PocketBase get client => _client;
}
