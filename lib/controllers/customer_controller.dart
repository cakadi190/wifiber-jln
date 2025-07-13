import 'package:flutter/foundation.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/services/customer_service.dart';

class CustomerController extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Customer? _selectedCustomer;

  List<Customer> get customers => _customers;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  Customer? get selectedCustomer => _selectedCustomer;

  Future<void> loadCustomers() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await _customerService.getAllCustomers();
      _customers = response.data;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error loading customers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCustomerById(String id) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final customer = await _customerService.getCustomerById(id);
      _selectedCustomer = customer;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error fetching customer: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final customer = await _customerService.createCustomer(customerData);
      _customers.add(customer);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error creating customer: $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final updatedCustomer = await _customerService.updateCustomer(
        id,
        customerData,
      );

      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      _selectedCustomer = updatedCustomer;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error updating customer: $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final success = await _customerService.deleteCustomer(id);

      if (success) {
        _customers.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error deleting customer: $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await _customerService.searchCustomers(query);
      _customers = response.data;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error searching customers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByStatus(String status) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await _customerService.getCustomersByStatus(status);
      _customers = response.data;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error filtering customers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Customer> get activeCustomers =>
      _customers.where((c) => c.status == 'customer').toList();

  List<Customer> get registrants =>
      _customers.where((c) => c.status == 'registrant').toList();

  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }

  void refresh() {
    loadCustomers();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
