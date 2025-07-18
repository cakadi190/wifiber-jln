import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/components/widgets/customer_search_modal.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/providers/bills_provider.dart';
import 'package:wifiber/screens/dashboard/bills/bills_create_screen.dart';
import 'package:wifiber/services/http_service.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String _selectedFilter = 'all';
  String? _selectedCustomerName;

  final HttpService _http = HttpService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillsProvider>().fetchBills();
    });
  }

  void _onFilterChanged(String value) async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedFilter = value;
    });

    if (_selectedCustomerName != null) {
      await provider.searchBills(provider.searchQuery ?? '');

      await provider.filterBillsByPaymentStatus(value == 'all' ? null : value);
    } else {
      await provider.filterBillsByPaymentStatus(value == 'all' ? null : value);
    }
  }

  void _resetAllFilters() async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedFilter = 'all';
      _selectedCustomerName = null;
    });

    await provider.clearFilters();
    await provider.fetchBills();
  }

  void _onCustomerSelected(dynamic customer) async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedCustomerName = customer.name;
    });

    await provider.searchBills(customer.customerId);

    if (_selectedFilter != 'all') {
      await provider.filterBillsByPaymentStatus(_selectedFilter);
    }
  }

  void _clearCustomerSearch() async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedCustomerName = null;
    });

    await provider.searchBills('');

    if (_selectedFilter != 'all') {
      await provider.filterBillsByPaymentStatus(_selectedFilter);
    }
  }

  bool _hasActiveFilters() {
    return _selectedFilter != 'all' || _selectedCustomerName != null;
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiWrapper(
      style: SystemUiHelper.duotone(
        statusBarColor: AppColors.primary,
        navigationBarColor: Colors.white,
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BillsCreateScreen(),
              ),
            );

            if (result == true) {
              await context.read<BillsProvider>().refresh();
            }
          },
        ),
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: Text('Daftar Tagihan'),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    CustomerSearchModal.showModal(
                      context,
                      onCustomerSelected: _onCustomerSelected,
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Cari Pelanggan'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _showModalConfirmationCreateMonthlyBill,
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Buat Tagihan Bulanan'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('all', 'Semua'),
                                _buildFilterChip('paid', 'Lunas'),
                                _buildFilterChip('unpaid', 'Belum Lunas'),
                                if (_hasActiveFilters())
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: TextButton.icon(
                                      onPressed: _resetAllFilters,
                                      icon: const Icon(Icons.close),
                                      label: Text(
                                        'Reset semua filter',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        minimumSize: const Size(40, 40),
                                      ),
                                    ),
                                  ),
                                if (_selectedCustomerName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.primary.withAlpha(
                                            60,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedCustomerName!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: _clearCustomerSearch,
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Consumer<BillsProvider>(
                        builder: (context, billsProvider, child) {
                          if (billsProvider.state == BillsState.loading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (billsProvider.state == BillsState.error) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Terjadi kesalahan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    billsProvider.errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      billsProvider.clearError();
                                      await billsProvider.refresh();
                                    },
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<Bills> displayedBills = billsProvider.bills;

                          if (displayedBills.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _hasActiveFilters()
                                        ? 'Tidak ada tagihan yang sesuai filter'
                                        : 'Belum ada tagihan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hasActiveFilters()
                                        ? 'Coba ubah filter atau buat tagihan baru'
                                        : 'Tagihan akan muncul di sini',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (_hasActiveFilters())
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: ElevatedButton(
                                        onPressed: _resetAllFilters,
                                        child: const Text('Reset Filter'),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              await billsProvider.refresh();

                              if (_selectedFilter != 'all') {
                                await billsProvider.filterBillsByPaymentStatus(
                                  _selectedFilter,
                                );
                              }
                              if (_selectedCustomerName != null &&
                                  billsProvider.searchQuery != null) {
                                await billsProvider.searchBills(
                                  billsProvider.searchQuery!,
                                );
                              }
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: displayedBills.length,
                              itemBuilder: (context, index) {
                                final bill = displayedBills[index];
                                return _buildBillCard(bill);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        showCheckmark: false,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _onFilterChanged(value);
          }
        },
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        selectedColor: AppColors.primary,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildBillCard(Bills bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showComplaintDetailModal(context, bill),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bill.invoice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(bill),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateHelper.formatDate(
                          DateHelper.parse(bill.period),
                          format: 'long',
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(bill.totalAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bill.isPaid ? Colors.green[600] : Colors.red[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Bills bill) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (bill.isPaid) {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
      text = 'Lunas';
    } else {
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
      text = 'Belum Lunas';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
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

  void _createMonthlyBill() async {
    try {
      final response = await _http.post('/monthly-bills', requiresAuth: true);

      if (response.statusCode == 200) {
        SnackBars.success(context, 'Tagihan bulanan berhasil dibuat.');
      } else {
        SnackBars.error(context, 'Gagal membuat tagihan bulanan.');
      }
    } catch (_) {
      SnackBars.error(context, 'Gagal membuat tagihan bulanan.');
    }
  }

  void _showModalConfirmationCreateMonthlyBill() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildModalHandle(),
                const SizedBox(height: 8),
                const Text(
                  'Buatkan Tagihan Bulanan?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apakah anda yakin ingin membuat tagihan bulanan?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          _createMonthlyBill();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Ya, Buatkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComplaintDetailModal(BuildContext context, Bills bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => DraggableScrollableSheet(
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

                  _buildSectionTitle(context, 'Informasi Pelanggan'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Nama Pelanggan',
                    bill.name,
                    Icons.person,
                  ),
                  if (bill.nickname != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Nama Panggilan',
                      bill.nickname!,
                      Icons.badge,
                    ),
                  ],
                  if (bill.address != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Alamat',
                      bill.address!,
                      Icons.location_on,
                    ),
                  ],
                  if (bill.phone != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Nomor Telepon',
                      bill.phone!,
                      Icons.phone,
                    ),
                  ],

                  const SizedBox(height: 20),

                  _buildSectionTitle(context, 'Informasi Tagihan'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Tagihan',
                    bill.invoice,
                    Icons.receipt,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Periode',
                    bill.period,
                    Icons.calendar_month,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Paket',
                    bill.packageName,
                    Icons.wifi,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Status',
                    bill.status.displayName,
                    bill.isPaid ? Icons.check_circle : Icons.pending,
                    color: bill.isPaid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Jatuh Tempo',
                    DateHelper.formatDate(bill.dueDate, format: 'long'),
                    Icons.schedule,
                    color: bill.isOverdue ? Colors.red : null,
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context, 'Rincian Pembayaran'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Harga Dasar',
                    _formatCurrency(bill.basePrice),
                    Icons.money,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Pajak',
                    _formatCurrency(bill.tax),
                    Icons.receipt_long,
                  ),
                  if (bill.discount != null && bill.discount! > 0) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Diskon',
                      '- ${_formatCurrency(bill.discount ?? 0)}',
                      Icons.discount,
                      color: Colors.green,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Total Tagihan',
                    _formatCurrency(bill.totalAmount),
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),

                  if (bill.isPaid) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Detail Pembayaran'),
                    const SizedBox(height: 12),
                    if (bill.paymentAt != null)
                      _buildDetailRow(
                        context,
                        'Tanggal Pembayaran',
                        DateHelper.formatDate(bill.paymentAt!, format: 'long'),
                        Icons.event_available,
                        color: Colors.green,
                      ),
                    if (bill.paymentMethod != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        'Metode Pembayaran',
                        bill.paymentMethod!,
                        Icons.payment,
                      ),
                    ],
                    if (bill.paymentReceivedBy != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        'Diterima Oleh',
                        bill.paymentReceivedBy!,
                        Icons.person,
                      ),
                    ],
                  ],

                  if (bill.ppoeSecret != null || bill.routerId != null) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Informasi Teknis'),
                    const SizedBox(height: 12),
                    if (bill.ppoeSecret != null)
                      _buildDetailRow(
                        context,
                        'PPPoE Secret',
                        bill.ppoeSecret!,
                        Icons.vpn_key,
                      ),
                    if (bill.routerId != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        'Router ID',
                        bill.routerId.toString(),
                        Icons.router,
                      ),
                    ],
                  ],

                  if (bill.additionalInfo != null) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Informasi Tambahan'),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Catatan',
                      bill.additionalInfo!,
                      Icons.note,
                    ),
                  ],

                  if (bill.locationPhoto != null) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Foto Lokasi'),
                    const SizedBox(height: 12),
                    _buildLocationPhoto(context, bill.locationPhoto!),
                  ],

                  const SizedBox(height: 20),

                  _buildActionButtons(context, bill),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPhoto(BuildContext context, String photoUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gambar tidak dapat dimuat',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Bills bill) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            label: const Text('Tutup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return CurrencyHelper.formatCurrency(amount);
  }
}
