import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/image_preview.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/registrant.dart';
import 'package:wifiber/providers/auth_provider.dart';

class RegistrantDetailModal extends StatelessWidget {
  final Registrant registrant;

  const RegistrantDetailModal({super.key, required this.registrant});

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'registrant':
        return 'Calon Pelanggan';
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
      case 'registrant':
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
        final token = authProvider.user?.accessToken;
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
                headers: {'Authorization': 'Bearer $token'},
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: {'Authorization': 'Bearer $token'},
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
    if (registrant.latitude != null && registrant.longitude != null) {
      final lat = double.parse(registrant.latitude!);
      final lng = double.parse(registrant.longitude!);
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
                          'Detail Calon Pelanggan',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow(
                          context,
                          'Nama',
                          registrant.name,
                          Icons.person,
                        ),
                        if (registrant.nickname != null &&
                            registrant.nickname!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            'Nama Panggilan',
                            registrant.nickname!,
                            Icons.person_outline,
                          ),
                        _buildDetailRow(
                          context,
                          'Telepon',
                          registrant.phone,
                          Icons.phone,
                        ),
                        _buildDetailRow(
                          context,
                          'No. Identitas',
                          registrant.identityNumber,
                          Icons.badge,
                        ),
                        _buildDetailRow(
                          context,
                          'Alamat',
                          registrant.address,
                          Icons.location_on,
                        ),
                        _buildDetailRow(
                          context,
                          'Status',
                          _getStatusDisplayName(registrant.status),
                          Icons.info,
                          color: _getStatusColor(registrant.status),
                        ),
                        const SizedBox(height: 8),

                        if (registrant.ktpPhoto != null)
                          _buildPhotoSection('Foto KTP', registrant.ktpPhoto!),
                        if (registrant.locationPhoto != null)
                          _buildPhotoSection(
                            'Foto Lokasi',
                            registrant.locationPhoto!,
                          ),

                        _buildDetailRow(
                          context,
                          'Paket',
                          registrant.packageName,
                          Icons.wifi,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'Harga Paket',
                          CurrencyHelper.formatCurrency(
                            int.parse(registrant.packagePrice),
                          ),
                          Icons.monetization_on,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'PPN Paket',
                          '${registrant.packagePpn}%',
                          Icons.percent,
                          color: AppColors.primary,
                        ),
                        _buildDetailRow(
                          context,
                          'Diskon',
                          '${registrant.discount}%',
                          Icons.local_offer,
                        ),
                        _buildDetailRow(
                          context,
                          'Tanggal Tempo Tiap Bulannya',
                          "Tanggal ${registrant.dueDate}",
                          Icons.calendar_month,
                        ),
                        _buildDetailRow(
                          context,
                          'Dibuat Pada',
                          DateHelper.formatDate(
                            DateTime.parse(registrant.createdAt),
                            format: 'full',
                          ),
                          Icons.schedule,
                        ),

                        if (registrant.routerName != null)
                          _buildDetailRow(
                            context,
                            'Router',
                            registrant.routerName!,
                            Icons.router,
                          ),
                        if (registrant.routerHost != null)
                          _buildDetailRow(
                            context,
                            'Router Host',
                            registrant.routerHost!,
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
  static void show(BuildContext context, Registrant registrant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RegistrantDetailModal(registrant: registrant),
    );
  }
}
