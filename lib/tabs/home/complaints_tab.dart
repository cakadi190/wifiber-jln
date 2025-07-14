import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/complaint_tab_controller.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/complaint.dart';
import 'package:wifiber/providers/complaint_provider.dart';
import 'package:wifiber/screens/dashboard/complainment/create_complainment_screen.dart';
import 'package:wifiber/screens/dashboard/complainment/edit_complainment_screen.dart';

class ComplaintsTab extends StatefulWidget {
  final ComplaintTabController controller;

  const ComplaintsTab({super.key, required this.controller});

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });

    widget.controller.search('');
  }

  void _onSearchChanged(String query) {
    widget.controller.search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateComplaintScreen(),
            ),
          );
          widget.controller.loadComplaints();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari nomor pengaduan...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('Pengaduan & Keluhan'),
        actions: [
          if (_isSearching)
            IconButton(icon: const Icon(Icons.close), onPressed: _stopSearch)
          else
            IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildFilter(context, provider),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: "Semua",
              isSelected: provider.selectedComplaintFilter == null,
              onTap: () => provider.setComplaintFilter(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Menunggu",
              isSelected:
                  provider.selectedComplaintFilter == ComplaintStatus.pending,
              onTap: () => provider.setComplaintFilter(ComplaintStatus.pending),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Diproses",
              isSelected:
                  provider.selectedComplaintFilter == ComplaintStatus.ongoing,
              onTap: () => provider.setComplaintFilter(ComplaintStatus.ongoing),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Selesai",
              isSelected:
                  provider.selectedComplaintFilter == ComplaintStatus.completed,
              onTap: () =>
                  provider.setComplaintFilter(ComplaintStatus.completed),
            ),

            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(width: 12),

            _buildFilterChip(
              context,
              label: "Pendaftaran",
              isSelected:
                  provider.selectedComplaintTypeFilter ==
                  ComplaintType.registration,
              onTap: () =>
                  provider.setComplaintTypeFilter(ComplaintType.registration),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Keluhan",
              isSelected:
                  provider.selectedComplaintTypeFilter ==
                  ComplaintType.complaint,
              onTap: () =>
                  provider.setComplaintTypeFilter(ComplaintType.complaint),
            ),
            const SizedBox(width: 16),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      if (provider.error!.toLowerCase().contains("not found")) {
        return _buildEmptyState(context, provider);
      }

      return _buildErrorWidget(context, provider.error!);
    }

    final complaints = provider.complaints;

    return RefreshIndicator(
      onRefresh: () => widget.controller.loadComplaints(),
      child: _buildComplaintList(context, complaints, provider),
    );
  }

  Widget _buildComplaintList(
    BuildContext context,
    List<Complaint> complaints,
    ComplaintProvider provider,
  ) {
    if (complaints.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (_, i) {
          final complaint = complaints[i];
          return _buildComplaintCard(
            context,
            complaint,
            onTap: () => _showComplaintDetailModal(context, complaint),
            onLongPress: () => _buildOptionsMenu(context, complaint),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ComplaintProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              size: 64,
              color: Colors.black.withValues(alpha: 0.6),
            ),
            const Text(
              "Tidak ada pengaduan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black54,
              ),
            ),
            Text(
              "Tidak ada pengaduan yang sesuai dengan filter yang telah dipilih. Silahkan cari atau ganti opsi filter yang lainnya.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            _buildEmptyStateActions(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateActions(
    BuildContext context,
    ComplaintProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context,
          label: "Reset Filter",
          onPressed: () {
            provider.setComplaintFilter(null);
            provider.setComplaintTypeFilter(null);
            provider.setSearchQuery('');

            if (_isSearching) {
              _stopSearch();
            }
          },
          isOutlined: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "atau",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        _buildActionButton(
          context,
          label: "Muat Ulang",
          onPressed: () => widget.controller.loadComplaints(),
          isOutlined: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required bool isOutlined,
  }) {
    return SizedBox(
      height: 32,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    Complaint complaint, {
    VoidCallback? onLongPress,
    VoidCallback? onTap,
  }) {
    final statusColor = _getStatusColor(complaint.statusEnum);
    final typeIcon = _getTypeIcon(complaint.statusEnum);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildComplaintIcon(statusColor, typeIcon),
        title: Text(
          '#${complaint.number.toString()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onLongPress: onLongPress,
        subtitle: _buildComplaintSubtitle(complaint, statusColor),
        trailing: Text(
          DateHelper.formatDate(complaint.date),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildComplaintIcon(Color statusColor, IconData typeIcon) {
    return Container(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 40,
      width: 40,
      child: Center(child: Icon(typeIcon, color: statusColor, size: 20)),
    );
  }

  Widget _buildComplaintSubtitle(Complaint complaint, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(complaint.topic, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            const SizedBox(width: 8),
            Text(
              _getTypeText(complaint.typeEnum),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  void _buildOptionsMenu(BuildContext context, Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeLeft: true,
          removeRight: true,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                _buildComplaintCard(context, complaint),
                const SizedBox(height: 16),
                _buildButton(context, "Lihat Detail", () {
                  Navigator.pop(context);
                  _showComplaintDetailModal(context, complaint);
                }),
                _buildButton(
                  context,
                  "Tindak Lanjuti (Perbarui Laporan)",
                  () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditComplaintScreen(complaint: complaint),
                      ),
                    );
                    widget.controller.loadComplaints();
                  },
                ),
                _buildButton(context, "Hapus Pengaduan", () {
                  Navigator.pop(context);
                  _showComplaintDeleteModal(context, complaint);
                }, isDangerZone: true),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback? onPressed, {
    bool? isDangerZone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        visualDensity: VisualDensity.comfortable,
        title: Text(
          label,
          style: TextStyle(
            color: isDangerZone != null && isDangerZone ? Colors.red : null,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDangerZone != null && isDangerZone ? Colors.red : null,
        ),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildModalHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              color: error.contains('not found')
                  ? Colors.grey.shade600
                  : Colors.red,
              error.contains('not found') ? Icons.info : Icons.warning,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              error.contains("not found")
                  ? "Tidak Ditemukan"
                  : "Ada Kesalahan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: error.contains("not found")
                    ? Colors.grey.shade600
                    : Colors.red,
              ),
            ),
            Text(
              error.contains("not found")
                  ? "Data pengaduan yang anda cari tidak ditemukan. Coba cari dengan pendekatan yang lainnya ya!"
                  : error,
              textAlign: TextAlign.center,
            ),
            if (error.contains("not found"))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                    context,
                    "Muat Ulang",
                    () => widget.controller.loadComplaints(),
                  ),
                ],
              ),
            if (error.contains("401"))
              TextButton(
                onPressed: () => widget.controller.logout(context),
                child: const Text("Autentikasi ulang"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComplaintDeleteModal(
    BuildContext context,
    Complaint complaint, [
    VoidCallback? onSuccess,
  ]) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(
          bottom: 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(PhosphorIconsStyle.duotone),
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hapus Pengaduan?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            const Text('Apakah anda yakin ingin menghapus pengaduan ini?'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      int id = int.parse(complaint.id.toString());
                      final success = await widget.controller.removeComplaint(
                        id,
                      );
                      if (success) {
                        Navigator.pop(context);
                        onSuccess?.call();
                        SnackBars.success(
                          context,
                          "Pengaduan berhasil dihapus",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Ya', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
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
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.2,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildModalHandle(),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Nomor Pengaduan',
                    '#${complaint.number.toString()}',
                    Icons.tag,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Nama Pelanggan',
                    complaint.name ?? "Anonim",
                    Icons.subject,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Deskripsi',
                    complaint.topic,
                    Icons.topic,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Status',
                    _getStatusText(complaint.statusEnum),
                    Icons.info_outline,
                    color: _getStatusColor(complaint.statusEnum),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Tipe',
                    _getTypeText(complaint.typeEnum),
                    _getTypeIcon(complaint.statusEnum),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Tanggal',
                    DateHelper.formatDate(complaint.date, format: 'full'),
                    Icons.calendar_month,
                  ),
                  const SizedBox(height: 32),
                  _buildDetailModalActions(context, complaint),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailModalActions(BuildContext context, Complaint complaint) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _showComplaintDeleteModal(context, complaint, () {
                      Navigator.pop(context);
                    }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditComplaintScreen(complaint: complaint),
                    ),
                  );
                  widget.controller.loadComplaints();
                },
                child: const Text(
                  'Tindak Lanjuti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
    Widget? additionalDetails,
  }) {
    return Container(
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
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 20),
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
                if (additionalDetails != null) ...[
                  const SizedBox(height: 4),
                  additionalDetails,
                ]
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
      case ComplaintStatus.ongoing:
        return Colors.blue;
      case ComplaintStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'Menunggu';
      case ComplaintStatus.ongoing:
        return 'Diproses';
      case ComplaintStatus.completed:
        return 'Selesai';
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
