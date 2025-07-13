import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wifiber/models/complaint.dart';

class ComplaintService {
  static const String baseUrl = 'https://your-api-url.com/api';

  Future<ComplaintResponse> getAllComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

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
      final response = await http.get(
        Uri.parse('$baseUrl/complaints/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

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

  Future<ComplaintResponse> createComplaint(Complaint complaint) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode(complaint.toJson()),
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

  Future<ComplaintResponse> updateComplaint(int id, Complaint complaint) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode(complaint.toJson()),
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
      final response = await http.delete(
        Uri.parse('$baseUrl/complaints/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
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
      final response = await http.get(
        Uri.parse('$baseUrl/complaints?status=${status.name}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
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
      final response = await http.get(
        Uri.parse('$baseUrl/complaints?type=${type.name}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
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
