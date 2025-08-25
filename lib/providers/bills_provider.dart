import 'package:flutter/foundation.dart';
import 'package:wifiber/exceptions/string_exceptions.dart';
import 'package:wifiber/exceptions/validation_exceptions.dart';
import 'package:wifiber/models/bills.dart';
import 'package:wifiber/services/bills_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

enum BillsState { initial, loading, loaded, error }

class BillsProvider extends SafeChangeNotifier {
  final BillsService _billsService;

  BillsProvider(this._billsService);

  List<Bills> _bills = [];
  BillsState _state = BillsState.initial;
  String _errorMessage = '';
  String _currentSearchQuery = '';
  String? _currentStatusFilter;

  String? _currentCustomerId;
  String? _currentPeriod;

  List<Bills> get bills => _bills;

  BillsState get state => _state;

  String? get searchQuery => _currentSearchQuery;

  String get errorMessage => _errorMessage;

  List<Bills> get paidBills => _bills.where((bill) => bill.isPaid).toList();

  List<Bills> get unpaidBills => _bills.where((bill) => !bill.isPaid).toList();

  int get totalPaidAmount => paidBills.fold(
    0,
    (sum, bill) => sum + (int.tryParse(bill.totalAmount.toString()) ?? 0),
  );

  int get totalUnpaidAmount => unpaidBills.fold(
    0,
    (sum, bill) => sum + (bill.totalAmount.toInt()),
  );

  Future<void> fetchBills({
    String? customerId,
    String? period,
    String? status,
    String? searchQuery,
  }) async {
    try {
      _setState(BillsState.loading);

      _currentCustomerId = customerId ?? '';
      _currentPeriod = period ?? '';
      _currentStatusFilter = status ?? '';
      _currentSearchQuery = searchQuery ?? '';

      final billResponse = await _billsService.getBills(
        customerId: customerId,
        period: period,
        status: status,
        searchQuery: searchQuery,
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
        await refresh();
        return true;
      } else {
        _setError(billResponse.message);
        return false;
      }
    } on ValidationException catch (e) {
      _setError(e.message);
      rethrow;
    } on StringException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> fetchBillsByCustomerId(String customerId) async {
    await fetchBills(
      customerId: customerId,
      status: _currentStatusFilter,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
  }

  Future<void> fetchBillsByStatus(String status) async {
    await fetchBills(
      customerId: _currentCustomerId,
      period: _currentPeriod,
      status: status,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
  }

  Future<void> fetchBillsByPeriod(String period) async {
    await fetchBills(
      customerId: _currentCustomerId,
      period: period,
      status: _currentStatusFilter,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
  }

  Future<void> fetchBillsByCustomerAndPeriod(
    String customerId,
    String period,
  ) async {
    await fetchBills(
      customerId: customerId,
      period: period,
      status: _currentStatusFilter,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
  }

  Future<void> refresh() async {
    await fetchBills(
      customerId: _currentCustomerId,
      period: _currentPeriod,
      status: _currentStatusFilter,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
  }

  Future<void> searchBills(String query) async {
    _currentSearchQuery = query;
    await fetchBills(
      customerId: _currentCustomerId,
      period: _currentPeriod,
      status: _currentStatusFilter,
      searchQuery: query.isNotEmpty ? query : null,
    );
  }

  Future<void> filterBillsByPaymentStatus(String? status) async {
    _currentStatusFilter = status;
    await fetchBills(
      customerId: _currentCustomerId,
      period: _currentPeriod,
      status: status,
      searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
    );
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
    _currentSearchQuery = '';
    _currentStatusFilter = null;
    _currentCustomerId = null;
    _currentPeriod = null;
    _setState(BillsState.initial);
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> clearFilters() async {
    _currentSearchQuery = '';
    _currentStatusFilter = null;
    await fetchBills(customerId: _currentCustomerId, period: _currentPeriod);
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
