import 'dart:convert';

import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/services/http_service.dart';

class ComplaintService {
  final HttpService _http = HttpService();

  Future<ComplaintResponse> getAllComplaints() async {
    try {
      final response = await _http.get('/complaints', requiresAuth: true);

      if (response.statusCode == 200) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Complaint> getComplaintById(int id) async {
    try {
      final response = await _http.get('/complaints/$id', requiresAuth: true);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Complaint.fromJson(data['data']);
      } else {
        throw Exception('Failed to load complaint');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ComplaintResponse> createComplaint(CreateComplaint complaint) async {
    try {
      final response = await _http.post(
        '/complaint-tickets',
        body: json.encode(complaint.toJson()),
        requiresAuth: true,
      );

      if (response.statusCode == 201) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create complaint');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ComplaintResponse> updateComplaint(
    int id,
    UpdateComplaint complaint,
  ) async {
    try {
      final response = await _http.post(
        '/complaint-ticket-update',
        body: json.encode(complaint.toJson()),
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update complaint');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteComplaint(int id) async {
    try {
      final response = await _http.delete(
        '/complaint-tickets/$id',
        requiresAuth: true,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ComplaintResponse> getComplaintsByStatus(
    ComplaintStatus status,
  ) async {
    try {
      final response = await _http.get(
        '/complaints',
        requiresAuth: true,
        parameters: {'status': status.name},
      );

      if (response.statusCode == 200) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load complaints by status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ComplaintResponse> getComplaintsByType(ComplaintType type) async {
    try {
      final response = await _http.get(
        '/complaints',
        requiresAuth: true,
        parameters: {'type': type.name},
      );

      if (response.statusCode == 200) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load complaints by type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
