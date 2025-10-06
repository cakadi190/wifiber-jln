import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/models/infrastructure.dart';
import 'package:wifiber/services/http_service.dart';
import 'package:wifiber/services/location_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class InfrastructureProvider extends SafeChangeNotifier {
  final HttpService _httpService = HttpService();

  List<InfrastructureItem> _items = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  InfrastructureType _activeType = InfrastructureType.olt;
  LatLng? _userLocation;
  bool _isLocationLoading = false;
  String? _locationError;

  List<InfrastructureItem> get items => _items;
  List<Customer> get customers => _customers;

  bool get isLoading => _isLoading;

  String? get error => _error;

  InfrastructureType get activeType => _activeType;

  bool get hasData => _activeType == InfrastructureType.customer
      ? _customers.isNotEmpty
      : _items.isNotEmpty;

  bool get hasError => _error != null;

  LatLng? get userLocation => _userLocation;

  bool get isLocationLoading => _isLocationLoading;

  String? get locationError => _locationError;

  bool get hasUserLocation => _userLocation != null;

  Future<void> loadData(InfrastructureType type) async {
    if (_activeType == type && !hasError && hasData) return;

    _setLoading(true);
    _clearError();
    _activeType = type;

    try {
      if (type == InfrastructureType.customer) {
        final response = await _httpService.get(
          type.endpoint,
          requiresAuth: true,
          parameters: {'status': 'customer'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final dynamic raw =
              data['data'] ?? data['customers'] ?? data['items'] ?? data;
          final List<dynamic> itemsData;

          if (raw is List) {
            itemsData = raw;
          } else if (raw is Map<String, dynamic>) {
            final dynamic nested =
                raw['data'] ?? raw['customers'] ?? raw['items'] ?? [];
            itemsData = nested is List ? nested : [];
          } else {
            itemsData = [];
          }

          _customers = itemsData
              .map((item) => Customer.fromJson(item))
              .toList();

          if (_userLocation != null && _customers.isNotEmpty) {
            _sortCustomersByDistance();
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } else {
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

          if (_userLocation != null && _items.isNotEmpty) {
            _sortItemsByDistance();
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (type == InfrastructureType.customer) {
        _customers = [];
      } else {
        _items = [];
      }
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getUserLocation() async {
    _setLocationLoading(true);
    _clearLocationError();

    try {
      final location = await LocationService.getCurrentPosition();
      _userLocation = location;

      if (_items.isNotEmpty) {
        _sortItemsByDistance();
      }
      if (_customers.isNotEmpty) {
        _sortCustomersByDistance();
      }
    } catch (e) {
      _setLocationError(e.toString());
    } finally {
      _setLocationLoading(false);
    }
  }

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

  void _sortCustomersByDistance() {
    if (_userLocation == null) return;

    _customers.sort((a, b) {
      final aValid = a.hasValidCoordinates();
      final bValid = b.hasValidCoordinates();

      if (!aValid && !bValid) return 0;
      if (!aValid) return 1;
      if (!bValid) return -1;

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

  List<CustomerWithDistance> getCustomersWithDistance() {
    if (_userLocation == null) {
      return _customers
          .map((customer) => CustomerWithDistance(customer, null))
          .toList();
    }

    return _customers.map((customer) {
      double? distance;
      if (customer.hasValidCoordinates()) {
        distance = LocationService.calculateDistance(
          _userLocation!,
          LatLng(customer.lat!, customer.lng!),
        );
      }
      return CustomerWithDistance(customer, distance);
    }).toList();
  }

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

  Customer? getNearestCustomer() {
    if (_userLocation == null || _customers.isEmpty) return null;

    final validCustomers =
        _customers.where((customer) => customer.hasValidCoordinates()).toList();

    if (validCustomers.isEmpty) return null;

    Customer? nearestCustomer;
    double? minDistance;

    for (final customer in validCustomers) {
      final distance = LocationService.calculateDistance(
        _userLocation!,
        LatLng(customer.lat!, customer.lng!),
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearestCustomer = customer;
      }
    }

    return nearestCustomer;
  }

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

  List<Customer> getCustomersWithValidCoordinates() {
    return _customers.where((customer) => customer.hasValidCoordinates()).toList();
  }

  List<LatLng> getActiveCoordinates() {
    if (_activeType == InfrastructureType.customer) {
      return getCustomersWithValidCoordinates()
          .map((customer) => LatLng(customer.lat!, customer.lng!))
          .toList();
    }

    return getItemsWithValidCoordinates()
        .map((item) => LatLng(item.lat!, item.lng!))
        .toList();
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

  Future<List<InfrastructureItem>> loadOdpsByOdcId(String odcId) async {
    try {
      final response = await _httpService.get(
        'odps',
        requiresAuth: true,
        parameters: {'odc_id': odcId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsData = data['data'] ?? [];

        return itemsData
            .map((item) => InfrastructureItem.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load ODPs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading ODPs: ${e.toString()}');
    }
  }

  Future<List<InfrastructureItem>> loadOdcsByOltId(String oltId) async {
    try {
      final response = await _httpService.get(
        'odcs',
        requiresAuth: true,
        parameters: {'olt_id': oltId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsData = data['data'] ?? [];

        return itemsData
            .map((item) => InfrastructureItem.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load ODCs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading ODCs: $e');
      throw Exception('Error loading ODCs: ${e.toString()}');
    }
  }

  Future<List<Customer>> loadCustomersByOdpId(String odpId) async {
    try {
      final response = await _httpService.get(
        'odp-customers/$odpId',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> customersData = data['data'] ?? [];

        return customersData
            .map((item) => Customer.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading customers: $e');
      throw Exception('Error loading customers: ${e.toString()}');
    }
  }
}

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

class CustomerWithDistance {
  final Customer customer;
  final double? distance;

  CustomerWithDistance(this.customer, this.distance);

  String get formattedDistance {
    if (distance == null) return 'Unknown';
    if (distance! < 1000) {
      return '${distance!.round()} m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)} km';
    }
  }
}
