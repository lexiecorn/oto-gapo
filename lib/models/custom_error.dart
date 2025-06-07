// ignore_for_file: public_member_api_docs, sort_constructors_first

class CustomError implements Exception {
  String code;
  String message;
  String plugin;
  CustomError({
    required this.code,
    required this.message,
    required this.plugin,
  });

  factory CustomError.initial() {
    return CustomError(
      code: '',
      message: '',
      plugin: '',
    );
  }
}
