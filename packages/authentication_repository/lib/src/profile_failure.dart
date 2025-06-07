///Profile Failure
class ProfileFailure implements Exception {
  ///
  ProfileFailure({
    required this.code,
    required this.message,
    required this.plugin,
  });

  ///initial value
  factory ProfileFailure.initial() {
    return ProfileFailure(
      code: '',
      message: '',
      plugin: '',
    );
  }

  ///error code
  String code;

  /// error message
  String message;

  /// error plugin
  String plugin;
}
