// lib/providers/bills_provider.dart
import 'package:flutter/foundation.dart';
import 'package:wifiber/controllers/bills_controller.dart';
import 'package:wifiber/models/bills.dart';

enum BillsState { initial, loading, loaded, error }

class BillsProvider extends ChangeNotifier {
  final BillsController _billsController = BillsController();

  List<Bills> _bills = [];
  BillsState _state = BillsState.initial;
  String _errorMessage = '';

  List<Bills> get bills => _bills;

  BillsState get state => _state;

  String get errorMessage => _errorMessage;

  List<Bills> get paidBills => _bills.where((bill) => bill.isPaid).toList();

  List<Bills> get unpaidBills => _bills.where((bill) => !bill.isPaid).toList();

  List<Bills> get overdueBills =>
      _bills.where((bill) => bill.isOverdue).toList();

  int get totalPaidAmount =>
      paidBills.fold(0, (sum, bill) => sum + bill.totalAmount);

  int get totalUnpaidAmount =>
      unpaidBills.fold(0, (sum, bill) => sum + bill.totalAmount);

  int get totalOverdueAmount =>
      overdueBills.fold(0, (sum, bill) => sum + bill.totalAmount);

  Future<void> fetchBills() async {
    try {
      _setState(BillsState.loading);

      final bills = await _billsController.fetchBills();
      _bills = bills;
      _setState(BillsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createBill(CreateBill createBill) async {
    try {
      _setState(BillsState.loading);

      final newBill = await _billsController.createBill(createBill);
      if (newBill != null) {
        _bills.add(newBill);
        _setState(BillsState.loaded);
        return true;
      } else {
        _setError('Failed to create bill');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchBillsByCustomerId(String customerId) async {
    try {
      _setState(BillsState.loading);

      final bills = await _billsController.fetchBillsByCustomerId(customerId);
      _bills = bills;
      _setState(BillsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchBills();
  }

  List<Bills> searchBills(String query) {
    if (query.isEmpty) return _bills;

    return _bills.where((bill) {
      return bill.invoice.toLowerCase().contains(query.toLowerCase()) ||
          bill.name.toLowerCase().contains(query.toLowerCase()) ||
          bill.customerId.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Bills> filterBillsByStatus(BillStatus status) {
    return _bills.where((bill) => bill.status == status).toList();
  }

  List<Bills> filterBillsByPeriod(String period) {
    return _bills.where((bill) => bill.period == period).toList();
  }

  Bills? getBillById(String id) {
    try {
      return _bills.firstWhere((bill) => bill.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearBills() {
    _bills.clear();
    _setState(BillsState.initial);
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setState(BillsState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = BillsState.error;
    notifyListeners();
  }
}
