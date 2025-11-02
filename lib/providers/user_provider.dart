import 'package:flutter/foundation.dart';
import 'package:otogapo/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> updateUser({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual user update logic
      await Future<void>.delayed(const Duration(seconds: 1)); // Simulated delay

      _user = User(
        id: _user!.id,
        phoneNumber: _user!.phoneNumber,
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        profilePicture: profilePicture ?? _user!.profilePicture,
        createdAt: _user!.createdAt,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }
}
