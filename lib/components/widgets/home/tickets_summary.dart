import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 0,
              left: 16,
              right: 0,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pengaduan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  onPressed: () => onTicketTap?.call(),
                  icon: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
