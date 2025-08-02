import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/location_service.dart';
import 'package:wifiber/models/infrastructure.dart';

class InfrastructureProvider with ChangeNotifier {
  final HttpService _httpService = HttpService();

  List<InfrastructureItem> _items = [];
  bool _isLoading = false;
  String? _error;
  InfrastructureType _activeType = InfrastructureType.olt;
  LatLng? _userLocation;
  bool _isLocationLoading = false;
  String? _locationError;

  List<InfrastructureItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InfrastructureType get activeType => _activeType;
  bool get hasData => _items.isNotEmpty;
  bool get hasError => _error != null;
  LatLng? get userLocation => _userLocation;
  bool get isLocationLoading => _isLocationLoading;
  String? get locationError => _locationError;
  bool get hasUserLocation => _userLocation != null;

  Future<void> loadData(InfrastructureType type) async {
    if (_activeType == type && !hasError) return;

    _setLoading(true);
    _clearError();
    _activeType = type;

    try {
      final response = await _httpService.get(
        type.endpoint,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsData = data['data'] ?? [];

        _items = itemsData
            .map((item) => InfrastructureItem.fromJson(item))
            .toList();

        if (_userLocation != null) {
          _sortItemsByDistance();
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get user's current location
  Future<void> getUserLocation() async {
    _setLocationLoading(true);
    _clearLocationError();

    try {
      final location = await LocationService.getCurrentPosition();
      _userLocation = location;

      if (_items.isNotEmpty) {
        _sortItemsByDistance();
      }
    } catch (e) {
      _setLocationError(e.toString());
    } finally {
      _setLocationLoading(false);
    }
  }

  /// Sort items by distance from user location
  void _sortItemsByDistance() {
    if (_userLocation == null) return;

    _items.sort((a, b) {
      if (!a.hasValidCoordinates() && !b.hasValidCoordinates()) return 0;
      if (!a.hasValidCoordinates()) return 1;
      if (!b.hasValidCoordinates()) return -1;

      final distanceA = LocationService.calculateDistance(
        _userLocation!,
        LatLng(a.lat!, a.lng!),
      );
      final distanceB = LocationService.calculateDistance(
        _userLocation!,
        LatLng(b.lat!, b.lng!),
      );

      return distanceA.compareTo(distanceB);
    });

    notifyListeners();
  }

  /// Get items with distance from user location
  List<InfrastructureItemWithDistance> getItemsWithDistance() {
    if (_userLocation == null) {
      return _items
          .map((item) => InfrastructureItemWithDistance(item, null))
          .toList();
    }

    return _items.map((item) {
      double? distance;
      if (item.hasValidCoordinates()) {
        distance = LocationService.calculateDistance(
          _userLocation!,
          LatLng(item.lat!, item.lng!),
        );
      }
      return InfrastructureItemWithDistance(item, distance);
    }).toList();
  }

  /// Get nearest infrastructure item
  InfrastructureItem? getNearestItem() {
    if (_userLocation == null || _items.isEmpty) return null;

    final validItems = getItemsWithValidCoordinates();
    if (validItems.isEmpty) return null;

    InfrastructureItem? nearestItem;
    double? minDistance;

    for (final item in validItems) {
      final distance = LocationService.calculateDistance(
        _userLocation!,
        LatLng(item.lat!, item.lng!),
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearestItem = item;
      }
    }

    return nearestItem;
  }

  /// Clear user location
  void clearUserLocation() {
    _userLocation = null;
    _clearLocationError();
    notifyListeners();
  }

  Future<void> refreshCurrentData() async {
    await loadData(_activeType);
  }

  void changeActiveType(InfrastructureType type) {
    if (_activeType != type) {
      loadData(type);
    }
  }

  List<InfrastructureItem> getItemsWithValidCoordinates() {
    return _items.where((item) => item.hasValidCoordinates()).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLocationLoading(bool loading) {
    _isLocationLoading = loading;
    notifyListeners();
  }

  void _setLocationError(String error) {
    _locationError = error;
    notifyListeners();
  }

  void _clearLocationError() {
    _locationError = null;
    notifyListeners();
  }
}

/// Helper class to combine infrastructure item with distance
class InfrastructureItemWithDistance {
  final InfrastructureItem item;
  final double? distance;

  InfrastructureItemWithDistance(this.item, this.distance);

  String get formattedDistance {
    if (distance == null) return 'Unknown';
    if (distance! < 1000) {
      return '${distance!.round()} m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)} km';
    }
  }
}
