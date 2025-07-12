import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/config/app_colors.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/helpers/currency_helper.dart';
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
          if (provider.isLoading) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final transactions = controller.filteredTransactions;

          return RefreshIndicator(
            onRefresh: () => controller.refreshTransactions(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final tx = transactions[i];

                  if (provider.error != null) {
                    if (kDebugMode) {
                      debugPrint(provider.error);
                    }

                    return Center(
                      child: Text(
                        "Ada kesalahan dari sistem. Mohon coba lagi.",
                      ),
                    );
                  }

                  return ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: tx.type == "income" ? Colors.green : Colors.red,
                        border: Border.all(
                          color: tx.type == "income"
                              ? Colors.green
                              : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Icon(
                          tx.type == "income"
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
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
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
