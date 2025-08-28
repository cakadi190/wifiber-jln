import 'dart:convert';

import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/services/http_service.dart';

class ComplaintService {
  final HttpService _http = HttpService();

  Future<ComplaintResponse> getComplaints({
    ComplaintStatus? status,
    ComplaintType? type,
    String? search,
  }) async {
    try {
      final parameters = <String, String>{};
      if (status != null) parameters['status'] = status.name;
      if (type != null) parameters['type'] = type.name;
      if (search != null && search.isNotEmpty) parameters['search'] = search;

      final response = await _http.get(
        '/complaint-tickets',
        requiresAuth: true,
        parameters: parameters,
      );

      if (response.statusCode == 200) {
        return ComplaintResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load complaints');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Complaint> getComplaintById(int id) async {
    try {
      final response = await _http.get(
        '/complaint-tickets/$id',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Complaint.fromJson(data['data']);
      } else {
        throw Exception('Failed to load complaint');
      }
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ComplaintResponse> createComplaint(CreateComplaint complaint) async {
    try {
      final response = await _http.postForm(
        '/complaint-tickets',
        fields: {
          'subject': complaint.subject,
          'topic': complaint.topic,
          'date': complaint.date.toIso8601String(),
        },
        requiresAuth: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return ComplaintResponse.fromJson(responseData);
        } else {
          return ComplaintResponse(
            success: true,
            message: 'Complaint created successfully',
            data: [],
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create complaint');
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
      final response = await _http.postForm(
        '/complaint-ticket-update',
        fields: {
          'id': id.toString(),
          'detail': complaint.detail,
          'name': complaint.name,
          'is-ticket-done': complaint.ticketIsDone.toString(),
        },
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
}
