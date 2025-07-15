import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/ticket_component.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/services/complaint_service.dart';

class TicketSummary extends StatelessWidget {
  const TicketSummary({super.key, this.onTicketTap});

  final VoidCallback? onTicketTap;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintProvider(ComplaintService())..fetchComplaints(),
      child: _TicketSummaryView(onTicketTap: onTicketTap),
    );
  }
}

class _TicketSummaryView extends StatelessWidget {
  final VoidCallback? onTicketTap;

  const _TicketSummaryView({this.onTicketTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, _) {
        return SummaryCard(
          title: "Pengaduan",
          onTap: onTicketTap,
          margin: const EdgeInsets.only(
            top: 0,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          padding: EdgeInsets.zero,
          child: StateBuilder<List>(
            isLoading: provider.isLoading,
            error: null,
            data: provider.complaints,
            loadingBuilder: () => DefaultStates.loading(),
            errorBuilder: (error) => DefaultStates.error(message: error),
            emptyBuilder: () => DefaultStates.empty(
              message: "Belum ada pengaduan",
              icon: Icons.info,
            ),
            dataBuilder: (complaints) => _buildComplaintsList(complaints),
            isEmpty: (complaints) => complaints?.isEmpty ?? true,
          ),
        );
      },
    );
  }

  Widget _buildComplaintsList(List complaints) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: min(5, complaints.length),
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return ListTile(
          title: Text(
            '#${complaint.number.toString()}',
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _getTypeText(complaint.typeEnum),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(complaint.statusEnum).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getTypeIcon(complaint.statusEnum), color: _getStatusColor(complaint.statusEnum)),
          ),
          trailing: Text(
            DateHelper.formatDate(complaint.date),
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.ongoing:
        return Colors.blue;
      case ComplaintStatus.completed:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Icons.warning;
      case ComplaintStatus.ongoing:
        return Icons.info;
      case ComplaintStatus.completed:
        return Icons.check;
    }
  }

  String _getTypeText(ComplaintType type) {
    switch (type) {
      case ComplaintType.registration:
        return 'Registrasi';
      case ComplaintType.complaint:
        return 'Pengaduan';
    }
  }
}
