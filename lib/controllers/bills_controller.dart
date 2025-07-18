import 'package:flutter/foundation.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/bills_service.dart';

enum BillsState { initial, loading, loaded, error }

class BillsController extends ChangeNotifier {
  final BillsService _billsService = BillsService();

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

      final response = await _billsService.getBills();

      if (response.success) {
        _bills = response.data;
        _setState(BillsState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createBill(CreateBill createBill) async {
    try {
      _setState(BillsState.loading);

      final response = await _billsService.createBill(createBill);

      if (response.success) {
        if (response.data.isNotEmpty) {
          _bills.add(response.data.first);
        }
        _setState(BillsState.loaded);
        return true;
      } else {
        _setError(response.message);
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

      final response = await _billsService.getBillsByCustomerId(customerId);

      if (response.success) {
        _bills = response.data;
        _setState(BillsState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(e.toString());
    }
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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
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
}
