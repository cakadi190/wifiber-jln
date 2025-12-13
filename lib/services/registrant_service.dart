import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/services/http_service.dart';

enum RegistrantStatus { registrant, inactive, free, isolir }

class RegistrantService {
  static final HttpService _http = HttpService();
  static const String path = 'registrants';

  Future<RegistrantResponse> getAllRegistrants(
    RegistrantStatus? status,
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
        return RegistrantResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load registrants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registrants: $e');
    }
  }

  Future<Registrant> getRegistrantById(String id) async {
    try {
      final response = await _http.get('$path/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return Registrant.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to get registrant: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to load registrant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching registrant: $e');
    }
  }

  Future<bool> createRegistrant(Map<String, dynamic> registrantData) async {
    try {
      List<http.MultipartFile> files = [];

      if (registrantData['ktp-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'ktp-photo',
            (registrantData['ktp-photo'] as XFile).path,
          ),
        );
      }

      if (registrantData['location-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'location-photo',
            (registrantData['location-photo'] as XFile).path,
          ),
        );
      }

      final streamedResponse = await _http.postUpload(
        path,
        fields: Map.fromEntries(
          registrantData.entries
              .where(
                (entry) =>
                    entry.key != 'ktp-photo' &&
                    entry.key != 'location-photo' &&
                    entry.value != null,
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
          throw Exception('Failed to create registrant: $statusCode');
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

        if (jsonData is Map<String, dynamic>) {
          if (jsonData['success'] == true) {
            return true;
          } else {
            throw Exception(
              'Failed to create registrant: ${jsonData['message'] ?? 'Unknown error'}',
            );
          }
        } else {
          throw Exception('Invalid JSON response format');
        }
      } else {
        final jsonData = json.decode(responseBody);
        final message = jsonData is Map<String, dynamic>
            ? (jsonData['message'] ?? 'Unknown error')
            : 'Failed to create registrant: $statusCode';
        throw Exception(message);
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error creating registrant: $e');
    }
  }

  Future<Registrant> updateRegistrant(
    String id,
    Map<String, dynamic> registrantData,
  ) async {
    try {
      List<http.MultipartFile> files = [];

      if (registrantData['ktp-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'ktp-photo',
            (registrantData['ktp-photo'] as XFile).path,
          ),
        );
      }

      if (registrantData['location-photo'] != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'location-photo',
            (registrantData['location-photo'] as XFile).path,
          ),
        );
      }

      final fields = Map.fromEntries(
        registrantData.entries
            .where(
              (entry) =>
                  entry.key != 'ktp-photo' &&
                  entry.key != 'location-photo' &&
                  entry.value != null,
            )
            .map((entry) => MapEntry(entry.key, entry.value.toString())),
      );

      final streamedResponse = await _http.postUpload(
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
          throw Exception('Failed to update registrant: $statusCode');
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
          return Registrant.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to update registrant: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to update registrant: $statusCode');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error updating registrant: $e');
    }
  }

  Future<bool> deleteRegistrant(String id) async {
    try {
      final response = await _http.delete('$path/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        throw Exception('Failed to delete registrant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting registrant: $e');
    }
  }

  Future<RegistrantResponse> searchRegistrants(
    String query, {
    RegistrantStatus? status,
    int? routerId,
    int? areaId,
  }) async {
    try {
      if (query.isEmpty) {
        return getAllRegistrants(status, routerId, areaId);
      }

      final Map<String, dynamic> queryParams = {
        'search': query.toString().trim(),
      };

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
        final registrantResponse = RegistrantResponse.fromJson(jsonData);

        if (!registrantResponse.success && registrantResponse.data.isEmpty) {
          return RegistrantResponse(
            success: true,
            message: 'No registrants found',
            data: [],
            error: null,
          );
        }

        return registrantResponse;
      } else {
        throw Exception('Failed to search registrants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching registrants: $e');
    }
  }

  Future<RegistrantResponse> getRegistrantsByStatus(String status) async {
    try {
      final response = await _http.get(
        path,
        requiresAuth: true,
        parameters: <String, dynamic>{'status': status},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RegistrantResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load registrants by status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching registrants by status: $e');
    }
  }
}
