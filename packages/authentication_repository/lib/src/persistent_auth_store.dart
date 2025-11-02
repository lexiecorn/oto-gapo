import 'package:local_storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';

/// Persistent implementation of PocketBase's AuthStore using LocalStorage (Hive).
///
/// This auth store persists authentication data across app restarts,
/// ensuring users remain logged in until they explicitly sign out.
class PersistentAuthStore {
  /// Creates a [PersistentAuthStore] with the given [LocalStorage] instance.
  PersistentAuthStore(this._storage);

  /// The key used to store authentication data in LocalStorage.
  static const _authKey = '__pb_auth__';

  final LocalStorage _storage;

  /// Creates and initializes an [AsyncAuthStore] for PocketBase.
  ///
  /// This method should be called before using PocketBase to ensure
  /// persisted authentication data is loaded.
  Future<AsyncAuthStore> createAuthStore() async {
    // Load initial auth data from storage
    final initialData = await _storage.read<String>(_authKey);
    
    print('PersistentAuthStore: Loading auth data from storage');
    print('PersistentAuthStore: Initial data present: ${initialData != null && initialData.isNotEmpty}');
    if (initialData != null && initialData.isNotEmpty) {
      print('PersistentAuthStore: Initial data length: ${initialData.length}');
    }

    return AsyncAuthStore(
      save: (String data) async {
        // Persist auth data to storage
        print('PersistentAuthStore: Saving auth data to storage (length: ${data.length})');
        await _storage.write(_authKey, data);
      },
      initial: initialData,
      clear: () async {
        // Clear auth data from storage
        print('PersistentAuthStore: Clearing auth data from storage');
        await _storage.write(_authKey, '');
      },
    );
  }
}
