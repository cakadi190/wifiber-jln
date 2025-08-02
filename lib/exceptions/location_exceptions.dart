class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
}

class LocationPermissionDeniedForeverException implements Exception {
  final String message;
  LocationPermissionDeniedForeverException(this.message);
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
}
