import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/controllers/tabs/transaction_tab.dart';
import 'package:wifiber/providers/transaction_provider.dart';

class TransactionTab extends StatelessWidget {
  final TransactionTabController controller;

  const TransactionTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi & Keuangan')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = controller.filteredTransactions;

          return RefreshIndicator(
            onRefresh: () => controller.refreshTransactions(),
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, i) {
                final tx = transactions[i];

                if(provider.error != null) {
                  if(kDebugMode) {
                    debugPrint(provider.error);
                  }

                  return Center(child: Text("Ada kesalahan dari sistem. Mohon coba lagi."));
                }

                return ListTile(
                  title: Text("#${tx.id.toString()}"),
                  subtitle: Text(tx.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text("Rp ${tx.amount}"),
                );
              },
            ),
          );
        },
      ),
    );
  }
}