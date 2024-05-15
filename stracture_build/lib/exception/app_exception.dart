class AppException implements Exception {
  String message;
  AppException({required this.message});

  @override
  String toString() => message;
}