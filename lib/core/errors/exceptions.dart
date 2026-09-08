/// Base Exception class representing data-layer or platform-level exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException([String? message, String? code])
      : super(message ?? 'Server Exception', code: code);
}

class NetworkException extends AppException {
  const NetworkException([String? message, String? code])
      : super(message ?? 'Network Connection Exception', code: code);
}

class AuthException extends AppException {
  const AuthException([String? message, String? code])
      : super(message ?? 'Auth Exception', code: code);
}

class CacheException extends AppException {
  const CacheException([String? message, String? code])
      : super(message ?? 'Cache Exception', code: code);
}

class PermissionException extends AppException {
  const PermissionException([String? message, String? code])
      : super(message ?? 'Permission Exception', code: code);
}
