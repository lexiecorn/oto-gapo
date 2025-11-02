import 'package:flutter/foundation.dart';
import 'package:otogapo/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual OTP sending logic
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulated delay
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<User?> verifyOtp(String verificationId, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual OTP verification logic
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulated delay

      // Simulate successful verification
      _user = User(
        id: '1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return _user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
