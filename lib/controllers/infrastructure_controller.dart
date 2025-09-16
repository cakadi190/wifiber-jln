import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:wifiber/models/infrastructure.dart';
import 'package:wifiber/providers/infrastructure_provider.dart';
import 'package:wifiber/services/location_service.dart';

class InfrastructureController {
  final InfrastructureProvider provider;
  final MapController mapController;
  final DraggableScrollableController draggableController;

  InfrastructureController({
    required this.provider,
    required this.mapController,
    required this.draggableController,
  });

  void animateMapToDataCenter() {
    final items = provider.getItemsWithValidCoordinates();
    if (items.isEmpty) return;

    final coordinates = items
        .map((item) => LatLng(item.lat!, item.lng!))
        .toList();

    if (coordinates.isEmpty) return;

    final bounds = _calculateBounds(coordinates);
    final center = _calculateCenter(bounds);
    final zoomLevel = _calculateZoomLevel(bounds);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(center, zoomLevel);
    });
  }

  void animateMapToUserLocation() {
    final userLocation = provider.userLocation;
    if (userLocation == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(userLocation, 15.0);
    });
  }

  void animateMapToShowUserAndItems() {
    final userLocation = provider.userLocation;
    final items = provider.getItemsWithValidCoordinates();

    if (userLocation == null && items.isEmpty) return;

    List<LatLng> coordinates = [];

    if (userLocation != null) {
      coordinates.add(userLocation);
    }

    coordinates.addAll(items.map((item) => LatLng(item.lat!, item.lng!)));

    if (coordinates.isEmpty) return;

    final bounds = _calculateBounds(coordinates);
    final center = _calculateCenter(bounds);
    final zoomLevel = _calculateZoomLevel(bounds);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(center, zoomLevel);
    });
  }

  Future<void> getUserLocationAndUpdateMap() async {
    try {
      await provider.getUserLocation();
      if (provider.hasUserLocation) {
        animateMapToShowUserAndItems();
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
      provider.setError("Gagal mendapatkan lokasi pengguna: ${e.toString()}");
    }
  }

  Future<bool> handleLocationPermission(BuildContext context) async {
    try {
      final permission = await LocationService.requestLocationPermission();

      if (!context.mounted) return false;

      if (permission == LocationPermission.denied) {
        if (!context.mounted) return false;
        _showLocationDialog(
          context,
          'Location Permission Required',
          'This app needs location permission to show your position on the map.',
          'Grant Permission',
          () async {
            final newPermission =
                await LocationService.requestLocationPermission();
            if (newPermission == LocationPermission.whileInUse ||
                newPermission == LocationPermission.always) {
              getUserLocationAndUpdateMap();
            }
          },
        );
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return false;
        _showLocationDialog(
          context,
          'Location Permission Permanently Denied',
          'Please enable location permission in app settings to use this feature.',
          'Open Settings',
          () => LocationService.openLocationSettings(),
        );
        return false;
      }

      return true;
    } catch (e) {
      if (!context.mounted) return false;
      _showLocationDialog(
        context,
        'Location Error',
        'Failed to request location permission: ${e.toString()}',
        'OK',
        () {},
      );
      return false;
    }
  }

  void _showLocationDialog(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> coordinates) {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (var coord in coordinates) {
      minLat = minLat < coord.latitude ? minLat : coord.latitude;
      maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
      minLng = minLng < coord.longitude ? minLng : coord.longitude;
      maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  LatLng _calculateCenter(LatLngBounds bounds) {
    double centerLat = (bounds.south + bounds.north) / 2;
    double centerLng = (bounds.west + bounds.east) / 2;
    return LatLng(centerLat, centerLng);
  }

  double _calculateZoomLevel(LatLngBounds bounds) {
    double latDiff = bounds.north - bounds.south;
    double lngDiff = bounds.east - bounds.west;
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    maxDiff = maxDiff * 1.2;

    if (maxDiff > 0.5) return 9.0;
    if (maxDiff > 0.2) return 10.5;
    if (maxDiff > 0.1) return 11.5;
    if (maxDiff > 0.05) return 12.5;
    if (maxDiff > 0.02) return 13.5;
    return 14.0;
  }

  void onFilterTap(InfrastructureType type) {
    provider.changeActiveType(type);
  }

  void refreshCurrentData() {
    provider.refreshCurrentData();
  }

  void launchMaps(InfrastructureItem item) {
    if (item.hasValidCoordinates()) {
      MapsLauncher.launchCoordinates(item.lat!, item.lng!);
    }
  }

  void handleDragStart(DragStartDetails details) {}

  void handleDragUpdate(DragUpdateDetails details, BuildContext context) {
    double currentSize = draggableController.size;
    double delta = details.primaryDelta! / MediaQuery.of(context).size.height;
    double newSize = currentSize - delta;
    newSize = newSize.clamp(0.1, 0.9);

    draggableController.animateTo(
      newSize,
      duration: const Duration(milliseconds: 50),
      curve: Curves.linear,
    );
  }

  void handleDragEnd(DragEndDetails details) {
    double currentSize = draggableController.size;
    double velocity = details.primaryVelocity ?? 0;
    double targetSize;

    if (velocity.abs() > 500) {
      if (velocity < 0) {
        targetSize = currentSize < 0.4 ? 0.5 : 0.9;
      } else {
        targetSize = currentSize > 0.6 ? 0.5 : 0.25;
      }
    } else {
      if (currentSize < 0.35) {
        targetSize = 0.25;
      } else if (currentSize < 0.7) {
        targetSize = 0.5;
      } else {
        targetSize = 0.9;
      }
    }

    draggableController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void dispose() {}
}
