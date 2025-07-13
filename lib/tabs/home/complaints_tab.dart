import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/complaint_tab_controller.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/screens/dashboard/complainment/create_complainment_screen.dart';

class ComplaintsTab extends StatelessWidget {
  final ComplaintTabController controller;

  const ComplaintsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Pengaduan & Keluhan'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateComplaintScreen(),
                ),
              ),
            },
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildFilter(context, provider),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _buildContent(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilter(BuildContext context, ComplaintProvider provider) {
    return Container(
      height: 60,
      padding: EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: "Semua",
              isSelected: provider.selectedComplaintFilter == null,
              onTap: () => provider.setComplaintFilter(null),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Pending",
              isSelected:
                  provider.selectedComplaintFilter == ComplaintStatus.pending,
              onTap: () => provider.setComplaintFilter(ComplaintStatus.pending),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Diproses",
              isSelected:
                  provider.selectedComplaintFilter ==
                  ComplaintStatus.processing,
              onTap: () =>
                  provider.setComplaintFilter(ComplaintStatus.processing),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Selesai",
              isSelected:
                  provider.selectedComplaintFilter == ComplaintStatus.resolved,
              onTap: () =>
                  provider.setComplaintFilter(ComplaintStatus.resolved),
            ),
            SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            SizedBox(width: 12),
            _buildFilterChip(
              context,
              label: "Internet",
              isSelected:
                  provider.selectedComplaintTypeFilter ==
                  ComplaintType.internet,
              onTap: () =>
                  provider.setComplaintTypeFilter(ComplaintType.internet),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Billing",
              isSelected:
                  provider.selectedComplaintTypeFilter == ComplaintType.billing,
              onTap: () =>
                  provider.setComplaintTypeFilter(ComplaintType.billing),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Teknis",
              isSelected:
                  provider.selectedComplaintTypeFilter ==
                  ComplaintType.technical,
              onTap: () =>
                  provider.setComplaintTypeFilter(ComplaintType.technical),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.50),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? AppColors.primary : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ComplaintProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _buildErrorWidget(context, provider.error!);
    }

    final complaints = controller.filteredComplaints;

    return RefreshIndicator(
      onRefresh: () => controller.loadComplaints(),
      child: _buildComplaintList(context, complaints, provider),
    );
  }

  Widget _buildComplaintList(
    BuildContext context,
    List<Complaint> complaints,
    ComplaintProvider provider,
  ) {
    if (complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                size: 64,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              Text(
                "Tidak ada pengaduan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              Text(
                "Tidak ada pengaduan yang sesuai dengan filter yang telah dipilih. Silahkan cari atau ganti opsi filter yang lainnya.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        provider.setComplaintFilter(null);
                        provider.setComplaintTypeFilter(null);
                      },
                      child: Text(
                        "Reset Filter",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "atau",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => controller.loadComplaints(),
                      child: Text(
                        "Muat Ulang",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (_, i) {
        final complaint = complaints[i];
        final statusColor = _getStatusColor(complaint.statusEnum);
        final typeIcon = _getTypeIcon(complaint.typeEnum);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                border: Border.all(color: statusColor),
                borderRadius: BorderRadius.circular(12),
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(typeIcon, color: statusColor, size: 20),
              ),
            ),
            title: Text(
              complaint.subject ?? 'No Subject',
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(complaint.statusEnum),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getTypeText(complaint.typeEnum),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              DateHelper.formatDate(complaint.date),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            onTap: () => _showComplaintDetailModal(context, complaint),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(color: Colors.red, Icons.warning, size: 64),
            Text(
              "Ada Kesalahan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.red,
              ),
            ),
            Text(error, textAlign: TextAlign.center),

            if (error.contains("401"))
              TextButton(
                onPressed: () => controller.logout(context),
                child: Text("Autentikasi ulang"),
              ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetailModal(BuildContext context, Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 8),

              _buildDetailRow(
                context,
                'ID Pengaduan',
                '#${complaint.id.toString()}',
                Icons.tag,
              ),
              SizedBox(height: 16),

              // _buildDetailRow(
              //   context,
              //   'Subjek',
              //   complaint.subject,
              //   Icons.subject,
              // ),
              SizedBox(height: 16),

              _buildDetailRow(context, 'Topik', complaint.topic, Icons.topic),
              SizedBox(height: 16),

              // _buildDetailRow(
              //   context,
              //   'Status',
              //   _getStatusText(complaint.status),
              //   Icons.info_outline,
              //   color: _getStatusColor(complaint.status),
              // ),
              SizedBox(height: 16),

              // _buildDetailRow(
              //   context,
              //   'Tipe',
              //   _getTypeText(complaint.type),
              //   _getTypeIcon(complaint.type),
              // ),
              SizedBox(height: 16),

              _buildDetailRow(
                context,
                'Tanggal',
                DateHelper.formatDate(complaint.date, format: 'full'),
                Icons.calendar_month,
              ),
              SizedBox(height: 32),

              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton(
              //         onPressed: () async {
              //           final success = await controller.removeComplaint(complaint.id);
              //           if (success) {
              //             Navigator.pop(context);
              //             controller.showSuccessMessage('Pengaduan berhasil dihapus');
              //           } else {
              //             controller.showErrorMessage('Gagal menghapus pengaduan');
              //           }
              //         },
              //         style: OutlinedButton.styleFrom(
              //           padding: EdgeInsets.symmetric(vertical: 16),
              //           side: BorderSide(color: Colors.red),
              //         ),
              //         child: Text(
              //           'Hapus',
              //           style: TextStyle(color: Colors.red),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 16),
              //     Expanded(
              //       child: ElevatedButton(
              //         onPressed: () => Navigator.pop(context),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: AppColors.primary,
              //           padding: EdgeInsets.symmetric(vertical: 16),
              //         ),
              //         child: Text(
              //           'Tutup',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.processing:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.green;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.processing:
        return 'Diproses';
      case ComplaintStatus.resolved:
        return 'Selesai';
    }
  }

  IconData _getTypeIcon(ComplaintType type) {
    switch (type) {
      case ComplaintType.internet:
        return Icons.wifi;
      case ComplaintType.billing:
        return Icons.payment;
      case ComplaintType.technical:
        return Icons.build;
    }
  }

  String _getTypeText(ComplaintType type) {
    switch (type) {
      case ComplaintType.internet:
        return 'Internet';
      case ComplaintType.billing:
        return 'Billing';
      case ComplaintType.technical:
        return 'Teknis';
    }
  }
}
