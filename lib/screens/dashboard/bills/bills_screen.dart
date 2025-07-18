import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
import 'package:wifiber/components/widgets/customer_search_modal.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/system_ui_helper.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/providers/bills_provider.dart';
import 'package:wifiber/screens/dashboard/bills/bills_create_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String _selectedFilter = 'all';
  String? _selectedCustomerName;

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

    // Pastikan tidak ada konflik dengan customer search
    if (_selectedCustomerName != null) {
      // Jika ada customer search aktif, filter berdasarkan customer dulu
      await provider.searchBills(provider.searchQuery ?? '');
      // Lalu terapkan filter payment status
      await provider.filterBillsByPaymentStatus(value == 'all' ? null : value);
    } else {
      // Jika tidak ada customer search, langsung filter payment status
      await provider.filterBillsByPaymentStatus(value == 'all' ? null : value);
    }
  }

  void _resetAllFilters() async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedFilter = 'all';
      _selectedCustomerName = null;
    });

    // Clear semua filter dan refresh data
    await provider.clearFilters();
    await provider.fetchBills(); // Pastikan data di-refresh
  }

  void _onCustomerSelected(dynamic customer) async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedCustomerName = customer.name;
    });

    // Search berdasarkan customer
    await provider.searchBills(customer.customerId);

    // Jika ada filter payment status aktif, terapkan juga
    if (_selectedFilter != 'all') {
      await provider.filterBillsByPaymentStatus(_selectedFilter);
    }
  }

  void _clearCustomerSearch() async {
    final provider = context.read<BillsProvider>();

    setState(() {
      _selectedCustomerName = null;
    });

    // Clear customer search
    await provider.searchBills('');

    // Jika ada filter payment status aktif, terapkan kembali
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
            IconButton(
              onPressed: () {
                CustomerSearchModal.showModal(
                  context,
                  onCustomerSelected: _onCustomerSelected,
                );
              },
              icon: Icon(Icons.search),
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
                    // Filter Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _buildFilterChip('all', 'Semua'),
                                    _buildFilterChip('paid', 'Lunas'),
                                    _buildFilterChip('unpaid', 'Belum Lunas'),
                                  ],
                                ),
                                if (_hasActiveFilters())
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: TextButton.icon(
                                      onPressed: _resetAllFilters,
                                      icon: Icon(Icons.close),
                                      label: Text(
                                        'Reset semua filter',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        minimumSize: Size(40, 40),
                                      ),
                                    ),
                                  ),
                                if (_selectedCustomerName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
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
                                          SizedBox(width: 8),
                                          Text(
                                            _selectedCustomerName!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 8),
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

                    // Bills List
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
                              // Terapkan kembali filter yang aktif
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to bill detail
        },
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
                          'Invoice: ${bill.invoice}',
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
                        'Periode: ${bill.period}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer ID: ${bill.customerId}',
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

  String _formatCurrency(int amount) {
    return CurrencyHelper.formatCurrency(amount);
  }
}
