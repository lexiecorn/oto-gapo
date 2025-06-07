///
class AuthFailure implements Exception {
  ///
  AuthFailure({
    required this.code,
    this.message,
    required this.plugin,
  });

  ///
  factory AuthFailure.initial() {
    return AuthFailure(
      code: '',
      message: 'An unknown auth error found ',
      plugin: '',
    );
  }

  ///
  String code = '';

  ///
  String? message;

  ///
  String plugin = '';
}
