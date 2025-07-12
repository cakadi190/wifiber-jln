import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';

class TransactionTab extends StatelessWidget {
  final TransactionTabController controller;

  const TransactionTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Transaksi & Keuangan')),
      body: Consumer<TransactionProvider>(
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

  Widget _buildFilter(BuildContext context, TransactionProvider provider) {
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
              isSelected:
                  provider.selectedFilter == 'all' ||
                  provider.selectedFilter == null,
              onTap: () => provider.setFilter('all'),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Pemasukan",
              isSelected: provider.selectedFilter == 'income',
              onTap: () => provider.setFilter('income'),
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: "Pengeluaran",
              isSelected: provider.selectedFilter == 'expense',
              onTap: () => provider.setFilter('expense'),
            ),
            SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            SizedBox(width: 12),

            _buildDateFilterChip(
              context,
              provider,
              onTap: () => _showDateFilterModal(context, provider),
            ),

            if (provider.startDate != null && provider.endDate != null) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => provider.clearDateFilter(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.clear, color: AppColors.primary, size: 16),
                ),
              ),
            ],

            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(
    BuildContext context,
    TransactionProvider provider, {
    required VoidCallback onTap,
  }) {
    final hasDateFilter =
        provider.startDate != null && provider.endDate != null;

    String label = "Pilih Tanggal";
    if (hasDateFilter) {
      final startDate = provider.startDate!;
      final endDate = provider.endDate!;

      label =
          "${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}";
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(minWidth: 120, maxWidth: 160),
        decoration: BoxDecoration(
          color: hasDateFilter
              ? Colors.white
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDateFilter ? Colors.white : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              color: hasDateFilter ? AppColors.primary : Colors.white,
              size: 14,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hasDateFilter ? AppColors.primary : Colors.white,
                  fontSize: 12,
                  fontWeight: hasDateFilter
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFilterModal(
    BuildContext context,
    TransactionProvider provider,
  ) {
    DateTime? tempStartDate = provider.startDate;
    DateTime? tempEndDate = provider.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Tanggal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),

              _buildDatePickerTile(
                context,
                'Tanggal Mulai',
                tempStartDate,
                Icons.calendar_today,
                () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempStartDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      tempStartDate = date;
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              _buildDatePickerTile(
                context,
                'Tanggal Akhir',
                tempEndDate,
                Icons.calendar_today,
                () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempEndDate ?? DateTime.now(),
                    firstDate: tempStartDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      tempEndDate = date;
                    });
                  }
                },
              ),
              SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.clearDateFilter();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: tempStartDate != null && tempEndDate != null
                          ? () {
                              provider.setDateFilter(
                                tempStartDate,
                                tempEndDate,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Terapkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
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
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : "Pilih tanggal",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
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
            color: isSelected ? Colors.white : Colors.grey.shade300,
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

  Widget _buildContent(BuildContext context, TransactionProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _buildErrorWidget(context, provider.error!);
    }

    final transactions = controller.filteredTransactions;

    return RefreshIndicator(
      onRefresh: () => controller.refreshTransactions(),
      child: _buildTransactionList(context, transactions, provider),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<Transaction> transactions,
    TransactionProvider provider,
  ) {
    if (transactions.isEmpty) {
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
                "Tidak ada transaksi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              Text(
                "Tidak ada transaksi yang sesuai dengan filter yang telah dipilih. Silahkan cari atau ganti opsi filter yang lainnya.",
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
                      onPressed: () => _showDateFilterModal(context, provider),
                      child: Text(
                        "Pilih tanggal",
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
                      onPressed: () => controller.refreshTransactions(),
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
      itemCount: transactions.length,
      itemBuilder: (_, i) {
        final tx = transactions[i];
        final isIncome = tx.type == "income";

        return ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: isIncome ? Colors.green : Colors.red,
              border: Border.all(color: isIncome ? Colors.green : Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 40,
            width: 40,
            child: Center(
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            DateHelper.formatDate(tx.createdAt),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            tx.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(CurrencyHelper.formatCurrency(tx.amount)),
          onTap: () => _showTransactionDetailModal(context, tx),
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
            TextButton(
              onPressed: () => controller.logout(context),
              child: Text("Autentikasi ulang"),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetailModal(
    BuildContext context,
    Transaction transaction,
  ) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Transaksi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 8),

              _buildDetailRow(
                context,
                'ID Transaksi',
                '#${transaction.id.toString()}',
                Icons.tag,
              ),
              SizedBox(height: 16),

              _buildDetailRow(
                context,
                'Tipe Transaksi',
                transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                transaction.type == 'income'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.type == 'income' ? Colors.green : Colors.red,
              ),
              SizedBox(height: 16),

              _buildDetailRow(
                context,
                'Deskripsi',
                transaction.description,
                Icons.description,
              ),
              SizedBox(height: 16),

              _buildDetailRow(
                context,
                'Jumlah',
                CurrencyHelper.formatCurrency(transaction.amount),
                Icons.attach_money,
                color: transaction.type == 'income' ? Colors.green : Colors.red,
              ),
              SizedBox(height: 16),

              _buildDetailRow(
                context,
                'Tanggal',
                DateHelper.formatDate(transaction.createdAt, format: 'full'),
                Icons.calendar_month,
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
}
