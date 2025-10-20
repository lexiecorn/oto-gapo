import 'package:hive_flutter/adapters.dart';

/// {@template local_storage}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class LocalStorage {
  /// {@macro local_storage}
  const LocalStorage();

  /// Initializes the local storage.
  ///
  /// This should be called in the `main` or `bootstrap`
  /// method of your application.
  ///
  Future<void> init([String? subDir]) async {
    await Hive.initFlutter(subDir);
  }

  Future<Box<dynamic>> _getBox(String key) async {
    return Hive.openBox<dynamic>(key);
  }

  /// Returns the value associated with the [key] or `null` if it doesn't exist.
  Future<T?> read<T extends Object>(String key) async {
    final box = await _getBox(key);

    /// Manually handle [Map<String, dynamic>] type as this
    /// may cause some type casting issues with Hive.
    if (T is Map<String, dynamic>) {
      final values = box.toMap().map(
            (key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value as Map<dynamic, dynamic>),
            ),
          );

      return values[key] as T?;
    }

    return box.get(key) as T?;
  }

  /// Writes the [value] associated with the [key].
  Future<void> write<T extends Object>(String key, T value) async {
    final box = await _getBox(key);

    await box.put(key, value);
  }

  /// Reads a list of values associated with the [key] or empty list if it doesn't exist.
  Future<List<T>> readList<T extends Object>(String key) async {
    final box = await _getBox(key);
    final values = box.values.whereType<T>().toList();
    return values;
  }

  /// Writes a list of [values] to storage, replacing existing data.
  Future<void> writeList<T extends Object>(String key, List<T> values) async {
    final box = await _getBox(key);
    await box.clear();
    for (final value in values) {
      await box.add(value);
    }
  }

  /// Appends a [value] to the list at [key].
  Future<void> appendToList<T extends Object>(String key, T value) async {
    final box = await _getBox(key);
    await box.add(value);
  }

  /// Deletes the value associated with the [key].
  Future<void> delete(String key) async {
    final box = await _getBox(key);
    await box.delete(key);
  }

  /// Clears all values in the box for [key].
  Future<void> clear(String key) async {
    final box = await _getBox(key);
    await box.clear();
  }

  /// Checks if a [key] exists in storage.
  Future<bool> exists(String key) async {
    final box = await _getBox(key);
    return box.containsKey(key);
  }

  /// Gets all keys in the box for [key].
  Future<List<String>> getKeys(String key) async {
    final box = await _getBox(key);
    return box.keys.cast<String>().toList();
  }

  /// Writes the [value] associated with the [key] along with a timestamp.
  Future<void> writeWithTimestamp<T extends Object>(
    String key,
    T value,
  ) async {
    final box = await _getBox(key);
    final dataWithTimestamp = {
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.put(key, dataWithTimestamp);
  }

  /// Reads the value and timestamp associated with the [key].
  Future<MapEntry<T?, DateTime?>?> readWithTimestamp<T extends Object>(
    String key,
  ) async {
    final box = await _getBox(key);
    final data = box.get(key) as Map<dynamic, dynamic>?;

    if (data == null) return null;

    final value = data['value'] as T?;
    final timestampStr = data['timestamp'] as String?;
    final timestamp = timestampStr != null ? DateTime.tryParse(timestampStr) : null;

    return MapEntry(value, timestamp);
  }
}
