import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wifiber/models/company_profile.dart';
import 'package:wifiber/services/http_service.dart';

class DataNullException implements Exception {
  final String message;

  DataNullException(this.message);

  @override
  String toString() => message;
}

class CompanyService {
  static final HttpService _http = HttpService();
  static const String profilePath = 'company-profile';

  Future<CompanyProfile?> getCompany() async {
    try {
      final response = await _http.get(profilePath, requiresAuth: true);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          if (data is Map<String, dynamic>) {
            return CompanyProfile.fromJson(data);
          }
          return null;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load company');
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null;
      }
      throw Exception('Error fetching company: $e');
    }
  }

  Future<CompanyProfile> createCompany(Map<String, dynamic> data) async {
    return _submitCompany(data);
  }

  Future<CompanyProfile> updateCompany(Map<String, dynamic> data) async {
    return _submitCompany(data);
  }

  Future<CompanyProfile> _submitCompany(Map<String, dynamic> data) async {
    try {
      List<http.MultipartFile> files = [];

      if (data['logo'] != null && data['logo'] is XFile) {
        files.add(
          await http.MultipartFile.fromPath(
            'logo',
            (data['logo'] as XFile).path,
          ),
        );
      }

      final fields = <String, String>{};
      data.forEach((key, value) {
        if (key != 'logo' && value != null) {
          fields[key] = value.toString();
        }
      });

      final streamedResponse = await _http.postUpload(
        profilePath,
        fields: fields,
        files: files,
        requiresAuth: true,
      );

      final statusCode = streamedResponse.statusCode;
      String responseBody = await streamedResponse.stream.bytesToString();

      final jsonData = json.decode(responseBody);

      if ((statusCode == 200 || statusCode == 201) &&
          jsonData['success'] == true) {
        if (jsonData['data'] != null &&
            jsonData['data'] is Map<String, dynamic>) {
          return CompanyProfile.fromJson(jsonData['data']);
        } else {
          throw DataNullException('Update successful but data is null');
        }
      } else {
        final errorMessage = jsonData['message'] ?? 'Failed to submit company';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error submitting company: $e');
    }
  }
}
