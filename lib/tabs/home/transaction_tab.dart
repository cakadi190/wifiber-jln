import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/options_bottom_sheet.dart';
import 'package:wifiber/components/ui/snackbars.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/helpers/role.dart';
import 'package:wifiber/screens/dashboard/transactions/transaction_form_screen.dart';

import 'package:wifiber/mixins/scroll_to_hide_fab_mixin.dart';
import 'package:wifiber/components/reusables/hideable_fab_wrapper.dart';

class TransactionTab extends StatefulWidget {
  final TransactionTabController controller;

  const TransactionTab({super.key, required this.controller});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab>
    with ScrollToHideFabMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Keuangan')),
      floatingActionButton: HideableFabWrapper(
        visible: isFabVisible,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
            );
            if (result == true) {
              widget.controller.refreshTransactions();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: RoleGuardWidget(
        permissions: 'finance',
        fallback: const Center(
          child: Text("Anda tidak memiliki akses ke bagian ini"),
        ),
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildFilter(context, provider),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
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
      builder: (context) => SafeArea(
        top: false,
        child: StatefulBuilder(
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildContent(BuildContext context, TransactionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _buildErrorWidget(context, provider.error!);
    }

    final transactions = widget.controller.filteredTransactions;

    return RefreshIndicator(
      onRefresh: () => widget.controller.refreshTransactions(),
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
                      onPressed: () => widget.controller.refreshTransactions(),
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
      controller: scrollController,
      itemCount: transactions.length,
      itemBuilder: (_, i) {
        final tx = transactions[i];
        final isIncome = tx.type == "income";

        return ListTile(
          onLongPress: () => _showTransactionOptions(context, tx),
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
            "#${tx.id.toString()} • ${DateHelper.formatDate(tx.createdAt)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            tx.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(CurrencyHelper.formatCurrency(tx.nominal)),
          onTap: () => _showTransactionDetailModal(context, tx),
        );
      },
    );
  }

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showOptionModalBottomSheet(
      context: context,
      header: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.wallet, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#${transaction.id.toString()} • ${DateHelper.formatDate(transaction.createdAt)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      items: [
        OptionMenuItem(
          title: 'Tampil Data',
          subtitle: 'Tampilkan informasi transaksi',
          icon: Icons.visibility,
          onTap: () => _showTransactionDetailModal(context, transaction),
        ),
        OptionMenuItem(
          title: 'Ubah Data',
          subtitle: 'Ubah informasi transaksi',
          icon: Icons.edit,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionFormScreen(transaction: transaction),
              ),
            );
            if (result == true) {
              widget.controller.refreshTransactions();
            }
          },
        ),
        OptionMenuItem(
          title: 'Hapus Data',
          subtitle: 'Hapus transaksi ini',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation(context, transaction);
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hapus Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apakah Anda yakin ingin menghapus data transaksi "#${transaction.id}" ini?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tindakan ini tidak dapat dibatalkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final provider = context.read<TransactionProvider>();
                          try {
                            await provider.deleteTransaction(transaction.id);
                            widget.controller.refreshTransactions();
                          } catch (e) {
                            if (context.mounted) {
                              SnackBars.error(
                                context,
                                'Gagal menghapus transaksi: $e',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ya, Hapus Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
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
                onPressed: () => widget.controller.logout(context),
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
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: Padding(
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
                  'ID Keuangan',
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
                  color: transaction.type == 'income'
                      ? Colors.green
                      : Colors.red,
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
                  'Dibuat Oleh',
                  transaction.createdBy ?? '-',
                  Icons.person,
                ),
                SizedBox(height: 16),

                _buildDetailRow(
                  context,
                  'Jumlah',
                  CurrencyHelper.formatCurrency(transaction.nominal),
                  Icons.attach_money,
                  color: transaction.type == 'income'
                      ? Colors.green
                      : Colors.red,
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
