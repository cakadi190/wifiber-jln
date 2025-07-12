import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/providers/transaction_provider.dart';

enum TransactionFilter { all, income, expense }

class TransactionTabController {
  final TransactionProvider provider;

  TransactionFilter _currentFilter = TransactionFilter.all;

  TransactionFilter get currentFilter => _currentFilter;

  TransactionTabController(this.provider);

  List<Transaction> get filteredTransactions {
    switch (_currentFilter) {
      case TransactionFilter.income:
        return provider.transactions
            .where((tx) => tx.type == 'income')
            .toList();
      case TransactionFilter.expense:
        return provider.transactions
            .where((tx) => tx.type == 'expense')
            .toList();
      case TransactionFilter.all:
        return provider.transactions;
    }
  }

  void setFilter(TransactionFilter filter) {
    _currentFilter = filter;
    // Notifier tidak perlu karena UI akan watch provider
  }

  Future<void> refreshTransactions() async {
    await provider.loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await provider.deleteTransaction(id);
  }

  Future<void> addTransaction(Transaction tx) async {
    await provider.addTransaction(tx);
  }
}
