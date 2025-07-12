import 'package:flutter/foundation.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service;

  TransactionProvider(this._service);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _service.getTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    try {
      await _service.createTransaction(tx);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction(int id, Transaction tx) async {
    try {
      await _service.updateTransaction(id, tx);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);
      _transactions.removeWhere((tx) => tx.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Transaction? findById(int id) {
    try {
      return _transactions.firstWhere((tx) => tx.id == id);
    } catch (_) {
      return null;
    }
  }
}
