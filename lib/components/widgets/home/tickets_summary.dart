import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/services/complaint_service.dart';

class TicketSummary extends StatelessWidget {
  const TicketSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintProvider(ComplaintService())..fetchComplaints(),
      child: _TicketSummaryView(),
    );
  }
}

class _TicketSummaryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
