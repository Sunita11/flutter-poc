class AppException implements Exception {
  final String reason;

  AppException({this.reason});

  String errorMessage() {
    return reason;
  }
}