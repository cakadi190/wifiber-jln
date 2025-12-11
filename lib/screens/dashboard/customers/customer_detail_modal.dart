import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/customer.dart';
import 'package:wifiber/providers/auth_provider.dart';
import 'package:wifiber/components/reusables/image_preview.dart';

class CustomerDetailModal extends StatelessWidget {
  final Customer customer;

  const CustomerDetailModal({super.key, required this.customer});

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
        return 'Pelanggan';
      case 'inactive':
        return 'Tidak Aktif';
      case 'free':
        return 'Gratis';
      case 'isolir':
        return 'Isolir';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'customer':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'free':
        return Colors.blue;
      case 'isolir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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

  Widget _buildPhotoSection(String label, String imageUrl) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => showImagePreview(
                context,
                imageUrl: imageUrl,
                headers: {
                  'Authorization': 'Bearer ${authProvider.user?.accessToken}',
                },
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: {
                    'Authorization': 'Bearer ${authProvider.user?.accessToken}',
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _openMaps() {
    if (customer.latitude != null && customer.longitude != null) {
      final lat = double.parse(customer.latitude!);
      final lng = double.parse(customer.longitude!);
      if (lat != 0 && lng != 0) {
        MapsLauncher.launchCoordinates(lat, lng);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Pelanggan',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow(
                          context,
                          'Nama',
                          customer.name,
                          Icons.person,
                        ),
                        if (customer.nickname != null &&
                            customer.nickname!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            'Nama Panggilan',
                            customer.nickname!,
                            Icons.person_outline,
                          ),
                        _buildDetailRow(
                          context,
                          'Telepon',
                          customer.phone,
                          Icons.phone,
                        ),
                        _buildDetailRow(
                          context,
                          'No. Identitas',
                          customer.identityNumber,
                          Icons.badge,
                        ),
                        _buildDetailRow(
                          context,
                          'Alamat',
                          customer.address,
                          Icons.location_on,
                        ),
                        _buildDetailRow(
                          context,
                          'Status',
                          _getStatusDisplayName(customer.status),
                          Icons.info,
                          color: _getStatusColor(customer.status),
                        ),
                        const SizedBox(height: 8),

                        if (customer.ktpPhoto != null)
                          _buildPhotoSection('Foto KTP', customer.ktpPhoto!),
                        if (customer.locationPhoto != null)
                          _buildPhotoSection(
                            'Foto Lokasi',
                            customer.locationPhoto!,
                          ),

                        _buildDetailRow(
                          context,
                          'Paket',
                          customer.packageName,
                          Icons.wifi,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'Harga Paket',
                          CurrencyHelper.formatCurrency(
                            int.parse(customer.packagePrice),
                          ),
                          Icons.monetization_on,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'PPN Paket',
                          '${customer.packagePpn}%',
                          Icons.percent,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'Diskon',
                          '${customer.discount}%',
                          Icons.local_offer,
                        ),
                        _buildDetailRow(
                          context,
                          'Tanggal Tempo Tiap Bulannya',
                          "Tanggal ${customer.dueDate}",
                          Icons.calendar_month,
                        ),
                        _buildDetailRow(
                          context,
                          'Dibuat Pada',
                          DateHelper.formatDate(
                            DateTime.parse(customer.createdAt),
                            format: 'full',
                          ),
                          Icons.schedule,
                        ),

                        if (customer.routerName != null)
                          _buildDetailRow(
                            context,
                            'Router',
                            customer.routerName!,
                            Icons.router,
                          ),
                        if (customer.routerHost != null)
                          _buildDetailRow(
                            context,
                            'Router Host',
                            customer.routerHost!,
                            Icons.dns,
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openMaps,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Buka Di Maps',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Static method to show the modal
  static void show(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomerDetailModal(customer: customer),
    );
  }
}
