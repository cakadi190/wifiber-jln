import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/exceptions/location_exceptions.dart'
    as custom_exceptions;

class LocationService {
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// Check if location services are enabled and permissions are granted
  static Future<bool> isLocationAvailable() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  static Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current position with error handling
  static Future<LatLng?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw custom_exceptions.LocationServiceDisabledException(
          'Location service is disabled',
        );
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw custom_exceptions.LocationPermissionDeniedException(
            'Location permission denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw custom_exceptions.LocationPermissionDeniedForeverException(
          'Location permission denied forever',
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(_timeoutDuration);

      return LatLng(position.latitude, position.longitude);
    } on custom_exceptions.LocationServiceDisabledException {
      throw custom_exceptions.LocationException(
        'Location services are disabled',
      );
    } on custom_exceptions.LocationPermissionDeniedException {
      throw custom_exceptions.LocationException(
        'Location permissions are denied',
      );
    } on custom_exceptions.LocationPermissionDeniedForeverException {
      throw custom_exceptions.LocationException(
        'Location permissions are permanently denied',
      );
    } on TimeoutException {
      throw custom_exceptions.LocationException('Location request timed out');
    } catch (e) {
      throw custom_exceptions.LocationException(
        'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Get location stream for real-time updates
  static Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
