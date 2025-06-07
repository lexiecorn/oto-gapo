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
}
