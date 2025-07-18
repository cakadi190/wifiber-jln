import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/system_ui_wrapper.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillsProvider>().fetchBills();
    });
  }

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
              context.read<BillsProvider>().refresh();
            }
          },
        ),
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Cari tagihan...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {});
            },
          )
              : const Text('Daftar Tagihan'),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _stopSearch,
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _startSearch,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'Semua'),
                            _buildFilterChip('paid', 'Lunas'),
                            _buildFilterChip('unpaid', 'Belum Lunas'),
                            _buildFilterChip('overdue', 'Jatuh Tempo'),
                          ],
                        ),
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
                                    onPressed: () {
                                      billsProvider.clearError();
                                      billsProvider.refresh();
                                    },
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<Bills> filteredBills = _getFilteredBills(
                            billsProvider,
                          );

                          if (filteredBills.isEmpty) {
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
                                    'Belum ada tagihan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tagihan akan muncul di sini',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: billsProvider.refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredBills.length,
                              itemBuilder: (context, index) {
                                final bill = filteredBills[index];
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
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        selectedColor: AppColors.primary,
        side: BorderSide.none,
      ),
    );
  }

  List<Bills> _getFilteredBills(BillsProvider provider) {
    List<Bills> bills = provider.bills;

    if (_searchController.text.isNotEmpty) {
      bills = provider.searchBills(_searchController.text);
    }

    switch (_selectedFilter) {
      case 'paid':
        bills = bills.where((bill) => bill.isPaid).toList();
        break;
      case 'unpaid':
        bills = bills.where((bill) => !bill.isPaid).toList();
        break;
      case 'overdue':
        bills = bills.where((bill) => bill.isOverdue).toList();
        break;
      default:
        break;
    }

    return bills;
  }

  Widget _buildBillCard(Bills bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
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
                    'Rp ${_formatCurrency(bill.totalAmount)}',
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
    } else if (bill.isOverdue) {
      backgroundColor = Colors.red[100]!;
      textColor = Colors.red[800]!;
      text = 'Jatuh Tempo';
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