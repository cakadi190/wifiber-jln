import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/complaint_provider.dart';

class ComplaintTabController {
  final BuildContext context;
  late final ComplaintProvider _provider;

  ComplaintTabController(this.context) {
    _provider = Provider.of<ComplaintProvider>(context, listen: false);
  }

  // Get filtered complaints based on current filters
  List<Complaint> get filteredComplaints {
    return _provider.complaints;
  }

  Future<void> loadComplaints() async {
    await _provider.fetchComplaints();
  }

  Future<void> loadComplaintById(int id) async {
    await _provider.fetchComplaintById(id);
  }

  Future<bool> addComplaint({
    required String subject,
    required String topic,
    required DateTime date,
  }) async {
    final complaint = CreateComplaint(
      subject: subject,
      topic: topic,
      date: date,
    );

    return await _provider.createComplaint(complaint);
  }

  Future<bool> updateComplaintStatus(
      int id,
      String detail,
      String name,
      bool ticketIsDone,
      ) async {
    final updatedComplaint = UpdateComplaint(
      id: id,
      detail: detail,
      name: name,
      ticketIsDone: !ticketIsDone,
    );

    return await _provider.updateComplaint(id, updatedComplaint);
  }

  Future<bool> removeComplaint(int id) async {
    return await _provider.deleteComplaint(id);
  }

  Future<void> filterByStatus(ComplaintStatus status) async {
    await _provider.fetchComplaintsByStatus(status);
  }

  Future<void> filterByType(ComplaintType type) async {
    await _provider.fetchComplaintsByType(type);
  }

  List<Complaint> getComplaintsByStatus(ComplaintStatus status) {
    return _provider.getComplaintsByStatusLocal(status);
  }

  List<Complaint> getComplaintsByType(ComplaintType type) {
    return _provider.getComplaintsByTypeLocal(type);
  }

  void clearSelection() {
    _provider.clearSelectedComplaint();
  }

  void showSuccessMessage(String message) {
    SnackBars.success(context, message);
  }

  void showErrorMessage(String message) {
    SnackBars.error(context, message);
  }

  // Add logout method (you'll need to implement this based on your auth system)
  Future<void> logout(BuildContext context) async {
    // Implement logout logic here
    // This is just a placeholder
    Navigator.pushReplacementNamed(context, '/login');
  }
}