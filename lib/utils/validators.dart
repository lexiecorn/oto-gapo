class Validators {
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.length != 6) {
      return 'Verification code must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit code';
    }
    return null;
  }
}
