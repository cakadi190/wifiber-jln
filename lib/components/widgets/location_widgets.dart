import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/config/app_colors.dart';

class LocationWidgets {
  /// Build floating action button for getting user location
  static Widget buildLocationFAB({
    required VoidCallback onPressed,
    required bool isLoading,
    bool hasLocation = false,
  }) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: hasLocation ? AppColors.primary : Colors.grey[600],
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              hasLocation ? Icons.my_location : Icons.location_searching,
              color: Colors.white,
            ),
    );
  }

  /// Build user location marker for map
  static Marker buildUserLocationMarker(LatLng location) {
    return Marker(
      point: location,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 3),
        ),
        child: const Center(
          child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 20),
        ),
      ),
    );
  }

  /// Build location info card
  static Widget buildLocationInfoCard({
    required LatLng location,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: const Text('Your Location'),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  /// Build location error widget
  static Widget buildLocationError({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Location Error',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build distance chip
  static Widget buildDistanceChip(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            distance,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build nearest item indicator
  static Widget buildNearestItemIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Nearest',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build location permission request widget
  static Widget buildLocationPermissionRequest({
    required VoidCallback onRequestPermission,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.blue, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Enable Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Allow location access to find nearby infrastructure and get better recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRequestPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
