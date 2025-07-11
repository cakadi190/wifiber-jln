class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Token has expired']);

  @override
  String toString() => message;
}

class RefreshTokenException implements Exception {
  final String message;
  RefreshTokenException([this.message = 'Failed to refresh token']);

  @override
  String toString() => message;
}

class LoginException implements Exception {
  final String message;
  LoginException([this.message = 'Login failed']);

  @override
  String toString() => message;
}