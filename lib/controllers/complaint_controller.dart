import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/complaint_provider.dart';

class ComplaintController {
  final BuildContext context;
  late final ComplaintProvider _provider;

  ComplaintController(this.context) {
    _provider = Provider.of<ComplaintProvider>(context, listen: false);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
