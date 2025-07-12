import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/models/transaction.dart';

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
    if (provider.isLoading) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
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
          ],
        ),
      );
    }
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.10),
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
      child: ListView.builder(
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
            title: Text("#${tx.id.toString()}"),
            subtitle: Text(
              tx.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(CurrencyHelper.formatCurrency(tx.amount)),
            onTap: () => _showTransactionDetailModal(context, tx),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    if (error.contains("401")) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sesi anda telah habis. Mohon autentikasikan diri anda kembali.",
            ),
            TextButton(
              onPressed: () => controller.logout(context),
              child: Text("Logout"),
            ),
          ],
        ),
      );
    }

    return Center(child: Text("Ada kesalahan dari sistem. Mohon coba lagi."));
  }

  void _showTransactionDetailModal(BuildContext context, Transaction transaction) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            SizedBox(height: 24),

            // Transaction ID
            _buildDetailRow(
              context,
              'ID Transaksi',
              '#${transaction.id.toString()}',
              Icons.tag,
            ),
            SizedBox(height: 16),

            // Transaction Type
            _buildDetailRow(
              context,
              'Tipe Transaksi',
              transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
              transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.type == 'income' ? Colors.green : Colors.red,
            ),
            SizedBox(height: 16),

            // Description
            _buildDetailRow(
              context,
              'Deskripsi',
              transaction.description,
              Icons.description,
            ),
            SizedBox(height: 16),

            // Amount
            _buildDetailRow(
              context,
              'Jumlah',
              CurrencyHelper.formatCurrency(transaction.amount),
              Icons.attach_money,
              color: transaction.type == 'income' ? Colors.green : Colors.red,
            ),
            SizedBox(height: 32),

            // Close button
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
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 20,
            ),
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