import 'package:flutter/foundation.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService;

  CustomerProvider(this._customerService);

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _error;
  CustomerStatus? _currentStatus;
  int? _currentRouterId;
  int? _currentAreaId;

  List<Customer> get customers => _customers;

  Customer? get selectedCustomer => _selectedCustomer;

  bool get isLoading => _isLoading;

  String? get error => _error;

  CustomerStatus? get currentStatus => _currentStatus;

  int? get currentRouterId => _currentRouterId;

  int? get currentAreaId => _currentAreaId;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomers({
    CustomerStatus? status,
    int? routerId,
    int? areaId,
  }) async {
    _setLoading(true);
    _currentStatus = status;
    _currentRouterId = routerId;
    _currentAreaId = areaId;

    try {
      final response = await _customerService.getAllCustomers(
        status,
        routerId,
        areaId,
      );
      _customers = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _customers = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCustomerById(String id) async {
    _setLoading(true);

    try {
      _selectedCustomer = await _customerService.getCustomerById(id);
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _selectedCustomer = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    _setLoading(true);

    try {
      final newCustomer = await _customerService.createCustomer(customerData);
      _customers.add(newCustomer);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    _setLoading(true);

    try {
      final updatedCustomer = await _customerService.updateCustomer(
        id,
        customerData,
      );

      final index = _customers.indexWhere((customer) => customer.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updatedCustomer;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCustomer(String id) async {
    _setLoading(true);

    try {
      final success = await _customerService.deleteCustomer(id);

      if (success) {
        _customers.removeWhere((customer) => customer.id == id);

        if (_selectedCustomer?.id == id) {
          _selectedCustomer = null;
        }

        _error = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchCustomers(String query) async {
    _setLoading(true);

    try {
      final response = await _customerService.searchCustomers(query);
      _customers = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _customers = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getCustomersByStatus(String status) async {
    _setLoading(true);

    try {
      final response = await _customerService.getCustomersByStatus(status);
      _customers = response.data;
      _error = null;
    } catch (e) {
      _setError(e.toString());
      _customers = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadCustomers(
      status: _currentStatus,
      routerId: _currentRouterId,
      areaId: _currentAreaId,
    );
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  void clearData() {
    _customers = [];
    _selectedCustomer = null;
    _error = null;
    _currentStatus = null;
    _currentRouterId = null;
    _currentAreaId = null;
    notifyListeners();
  }
}
