import 'package:flutter/foundation.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/bills_service.dart';

enum BillsState { initial, loading, loaded, error }

class BillsProvider extends ChangeNotifier {
  final BillsService _billsService;

  BillsProvider(this._billsService);

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

  int get totalPaidAmount => paidBills.fold(
    0,
    (sum, bill) => sum + (int.tryParse(bill.totalAmount.toString()) ?? 0),
  );

  int get totalUnpaidAmount => unpaidBills.fold(
    0,
    (sum, bill) => sum + (int.tryParse(bill.totalAmount.toString()) ?? 0),
  );

  int get totalOverdueAmount => overdueBills.fold(
    0,
    (sum, bill) => sum + (int.tryParse(bill.totalAmount.toString()) ?? 0),
  );

  Future<void> fetchBills({
    String? customerId,
    String? period,
    String? status,
  }) async {
    try {
      _setState(BillsState.loading);

      final billResponse = await _billsService.getBills(
        customerId: customerId,
        period: period,
        status: status,
      );

      _bills = billResponse.data;
      _setState(BillsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createBill(CreateBill createBill) async {
    try {
      _setState(BillsState.loading);

      final billResponse = await _billsService.createBill(createBill);

      if (billResponse.success == true) {
        await fetchBills();
        return true;
      } else {
        _setError(billResponse.message);
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

      final billResponse = await _billsService.getBillsByCustomerId(customerId);

      _bills = billResponse.data;
      _setState(BillsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchBillsByStatus(String status) async {
    await fetchBills(status: status);
  }

  Future<void> fetchBillsByPeriod(String period) async {
    await fetchBills(period: period);
  }

  Future<void> fetchBillsByCustomerAndPeriod(
    String customerId,
    String period,
  ) async {
    await fetchBills(customerId: customerId, period: period);
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
