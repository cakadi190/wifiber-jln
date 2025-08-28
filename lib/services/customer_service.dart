import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
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
      final queryParams = <String, dynamic>{};
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
        if (jsonData['success'] == true) {
          return Customer.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to get customer: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to load customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    try {
      List<http.MultipartFile> files = [];

      if (customerData['ktp-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'ktp-photo',
            (customerData['ktp-photo'] as XFile).path,
          ),
        );
      }

      if (customerData['location-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'location-photo',
            (customerData['location-photo'] as XFile).path,
          ),
        );
      }

      final streamedResponse = await _http.postUpload(
        path,
        fields: Map.fromEntries(
          customerData.entries
              .where(
                (entry) =>
                    entry.key != 'ktp-photo' && entry.key != 'location-photo',
              )
              .map((entry) => MapEntry(entry.key, entry.value.toString())),
        ),
        files: files,
        requiresAuth: true,
      );

      int statusCode = streamedResponse.statusCode;

      if (statusCode >= 400) {
        if (statusCode == 401) {
          throw Exception('Session expired. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('You do not have permission.');
        } else if (statusCode == 422) {
          throw Exception('Validation failed.');
        } else if (statusCode >= 500) {
          throw Exception('Server error occurred.');
        } else {
          throw Exception('Failed to create customer: $statusCode');
        }
      }

      String responseBody = '';
      await for (String chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        responseBody += chunk;
      }

      if (statusCode == 201) {
        final jsonData = json.decode(responseBody);

        if (jsonData is Map<String, dynamic>) {
          if (jsonData['success'] == true) {
            return true;
          } else {
            throw Exception(
              'Failed to create customer: ${jsonData['message'] ?? 'Unknown error'}',
            );
          }
        } else {
          throw Exception('Invalid JSON response format');
        }
      } else {
        throw Exception('Failed to create customer: $statusCode');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  Future<Customer> updateCustomer(
    String id,
    Map<String, dynamic> customerData,
  ) async {
    try {
      List<http.MultipartFile> files = [];

      if (customerData['ktp-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'ktp-photo',
            (customerData['ktp-photo'] as XFile).path,
          ),
        );
      }

      if (customerData['location-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'location-photo',
            (customerData['location-photo'] as XFile).path,
          ),
        );
      }

      final fields = Map.fromEntries(
        customerData.entries
            .where(
              (entry) =>
                  entry.key != 'ktp-photo' && entry.key != 'location-photo',
            )
            .map((entry) => MapEntry(entry.key, entry.value.toString())),
      );

      final streamedResponse = await _http.putUpload(
        '$path/$id',
        fields: fields,
        files: files,
        requiresAuth: true,
      );

      final statusCode = streamedResponse.statusCode;

      if (statusCode >= 400) {
        if (statusCode == 401) {
          throw Exception('Session expired. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('You do not have permission.');
        } else if (statusCode == 422) {
          throw Exception('Validation failed.');
        } else if (statusCode >= 500) {
          throw Exception('Server error occurred.');
        } else {
          throw Exception('Failed to update customer: $statusCode');
        }
      }

      String responseBody = '';
      await for (String chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        responseBody += chunk;
      }

      if (statusCode == 200) {
        final jsonData = json.decode(responseBody);
        if (jsonData['success'] == true) {
          return Customer.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to update customer: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to update customer: $statusCode');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  Future<String> importCustomers(File file) async {
    try {
      final uploadFile = await http.MultipartFile.fromPath(
        'import-customer-file',
        file.path,
      );

      final streamedResponse = await _http.postUpload(
        'import-customer',
        files: [uploadFile],
        requiresAuth: true,
      );

      final statusCode = streamedResponse.statusCode;
      String responseBody = await streamedResponse.stream.bytesToString();
      final jsonData = json.decode(responseBody);

      if (statusCode == 200 && jsonData['success'] == true) {
        return jsonData['message'] ?? 'Import berhasil';
      } else {
        String message = jsonData['error'] != null
            ? (jsonData['error']['message'] ?? jsonData['message'])
            : jsonData['message'];
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Error importing customers: $e');
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      final response = await _http.delete('$path/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  Future<CustomerResponse> searchCustomers(String query) async {
    try {
      if (query.isEmpty) {
        return getAllCustomers(null, null, null);
      }

      final Map<String, dynamic> queryParams = {
        'search': query.toString().trim(),
      };

      final response = await _http.get(
        path,
        requiresAuth: true,
        parameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final customerResponse = CustomerResponse.fromJson(jsonData);

        if (!customerResponse.success && customerResponse.data.isEmpty) {
          return CustomerResponse(
            success: true,
            message: 'No customers found',
            data: [],
            error: null,
          );
        }

        return customerResponse;
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
        parameters: <String, dynamic>{'status': status},
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
