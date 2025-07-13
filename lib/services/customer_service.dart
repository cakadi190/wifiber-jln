import 'dart:convert';

import 'package:wifiber/models/customer.dart';
import 'package:wifiber/services/http_service.dart';

enum CustomerStatus { customer, inactive, free, isolir }

class CustomerService {
  static final HttpService _http = HttpService();
  static const String path = 'customers';

  Future<CustomerResponse> getAllCustomers(
    CustomerStatus? status,
    int? routerId,
    int? areaId,
  ) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }
      if (routerId != null) {
        queryParams['router_id'] = routerId.toString();
      }
      if (areaId != null) {
        queryParams['area_id'] = areaId.toString();
      }

      final response = await _http.get(
        path,
        requiresAuth: true,
        parameters: queryParams,
      );

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
      final response = await _http.get('$path/$id', requiresAuth: true);

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
        path,
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
        '$path/$id',
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
      final response = await _http.delete('$path/$id', requiresAuth: true);

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
        path,
        requiresAuth: true,
        parameters: {'search': query},
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
        path,
        requiresAuth: true,
        parameters: {'status': status},
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
