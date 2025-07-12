import 'package:flutter/foundation.dart';
import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service;

  TransactionProvider(this._service);

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  List<Transaction> get transactions => _filteredTransactions;

  List<Transaction> get allTransactions => _transactions;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get selectedFilter => _selectedFilter;

  DateTime? get startDate => _startDate;

  DateTime? get endDate => _endDate;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _service.getTransactions();
      _error = null;
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    loadTransactions();
    _applyFilter();
    notifyListeners();
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    loadTransactions();
    _applyFilter();
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    loadTransactions();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<Transaction> filtered = List.from(_transactions);

    switch (_selectedFilter) {
      case 'income':
        filtered = filtered.where((tx) => tx.type == 'income').toList();
        break;
      case 'expense':
        filtered = filtered.where((tx) => tx.type == 'expense').toList();
        break;
      case 'all':
      default:
        break;
    }

    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((tx) {
        final txDate = tx.createdAt;
        return txDate.isAfter(_startDate!.subtract(Duration(days: 1))) &&
            txDate.isBefore(_endDate!.add(Duration(days: 1)));
      }).toList();
    }

    _filteredTransactions = filtered;
  }

  Transaction? findById(int id) {
    try {
      return _transactions.firstWhere((tx) => tx.id == id);
    } catch (_) {
      return null;
    }
  }
}
