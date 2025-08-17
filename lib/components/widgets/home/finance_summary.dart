import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifiber/components/reusables/ticket_component.dart';
import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/helpers/datetime_helper.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';
import 'package:wifiber/services/transaction_service.dart';

class FinanceSummary extends StatelessWidget {
  const FinanceSummary({super.key, this.onFinanceTap});

  final VoidCallback? onFinanceTap;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TransactionProvider(TransactionService())..loadTransactions(),
      child: _FinanceSummaryView(onFinanceTap: onFinanceTap),
    );
  }
}

class _FinanceSummaryView extends StatelessWidget {
  final VoidCallback? onFinanceTap;

  const _FinanceSummaryView({this.onFinanceTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SummaryCard(
          title: 'Keuangan',
          onTap: onFinanceTap,
          margin: const EdgeInsets.only(
            top: 0,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          padding: EdgeInsets.zero,
          child: StateBuilder<List<Transaction>>(
            isLoading: provider.isLoading,
            error: provider.error,
            data: provider.transactions,
            loadingBuilder: () => DefaultStates.loading(),
            errorBuilder: (error) => DefaultStates.error(message: error),
            emptyBuilder: () => DefaultStates.empty(
              message: 'Belum ada transaksi',
              icon: Icons.info,
            ),
            dataBuilder: (transactions) => _buildTransactionsList(transactions),
            isEmpty: (transactions) => transactions?.isEmpty ?? true,
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: min(5, transactions.length),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.type == 'income';
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            CurrencyHelper.formatCurrency(tx.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            tx.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Text(
            DateHelper.formatDate(tx.createdAt),
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
