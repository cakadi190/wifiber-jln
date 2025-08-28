import 'dart:io';

import 'package:wifiber/models/transaction.dart';
import 'package:wifiber/services/transaction_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class TransactionProvider extends SafeChangeNotifier {
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

  Future<void> addTransaction({
    required int nominal,
    required String description,
    required String type,
    required DateTime createdAt,
    required String createdBy,
    File? image,
  }) async {
    // ValidationException akan di-throw langsung ke form
    await _service.createTransaction(
      nominal: nominal,
      description: description,
      type: type,
      createdAt: createdAt,
      createdBy: createdBy,
      image: image,
    );
    await loadTransactions();
  }

  Future<void> updateTransaction(
    int id, {
    required int nominal,
    required String description,
    required String type,
    required DateTime createdAt,
    required String createdBy,
    File? image,
  }) async {
    // ValidationException akan di-throw langsung ke form
    await _service.updateTransaction(
      id,
      nominal: nominal,
      description: description,
      type: type,
      createdAt: createdAt,
      createdBy: createdBy,
      image: image,
    );
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _service.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    _applyFilter();
    notifyListeners();
  }
}
