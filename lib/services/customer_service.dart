import 'dart:convert';

import 'package:wifiber/models/customer.dart';
import 'package:wifiber/services/http_service.dart';

class CustomerService {
  static final HttpService _http = HttpService();
  static const String path = '/customers';

  Future<CustomerResponse> getAllCustomers() async {
    try {
      final response = await _http.get('/customers', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CustomerResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _http.get('/customers/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          return Customer.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to get customer: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await _http.post(
        '/customers/',
        body: json.encode(customerData),
        requiresAuth: true,
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          return Customer.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to create customer: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to create customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  Future<Customer> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final response = await _http.put(
        '/customers/$id',
        body: json.encode(customerData),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          return Customer.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to update customer: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      final response = await _http.delete('/customers/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'];
      } else {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  Future<CustomerResponse> searchCustomers(String query) async {
    try {
      final response = await _http.get(
        '/customers?search=$query',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CustomerResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to search customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching customers: $e');
    }
  }

  Future<CustomerResponse> getCustomersByStatus(String status) async {
    try {
      final response = await _http.get(
        '/customers?status=$status',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CustomerResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load customers by status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching customers by status: $e');
    }
  }
}
