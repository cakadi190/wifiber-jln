import 'package:wifiber/helpers/currency_helper.dart';
import 'package:wifiber/models/dashboard.dart';
import 'package:wifiber/services/dashboard_service.dart';
import 'package:wifiber/utils/safe_change_notifier.dart';

class DashboardSummaryController extends SafeChangeNotifier {
  final DashboardService _service = DashboardService();

  bool obscureTotalCashFlow = true;
  bool obscureTotalIncome = true;
  bool obscureTotalExpense = true;

  num _totalCashFlow = 0;
  num _totalIncome = 0;
  num _totalExpense = 0;
  num _unpaidInvoiceCount = 0;
  CustomerInfo? _customerInfo;

  bool _isLoading = false;
  String? _error;

  num get totalCashFlow => _totalCashFlow;

  num get totalIncome => _totalIncome;

  num get totalExpense => _totalExpense;

  num get unpaidInvoiceCount => _unpaidInvoiceCount;

  bool get isLoading => _isLoading;

  String? get error => _error;

  CustomerInfo? get customerInfo => _customerInfo;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardData = await _service.getDashboardData();

      if (dashboardData.success) {
        _totalIncome = dashboardData.data.currentMonth.finance.income;
        _totalExpense = dashboardData.data.currentMonth.finance.expense;
        _unpaidInvoiceCount = dashboardData.data.currentMonth.unpaidBills;
        _customerInfo = dashboardData.data.totalCustomer;

        _totalCashFlow = _totalIncome - _totalExpense;

        _error = null;
      } else {
        _error = dashboardData.error ?? 'Failed to load data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleCashFlowVisibility() {
    obscureTotalCashFlow = !obscureTotalCashFlow;
    notifyListeners();
  }

  void toggleIncomeVisibility() {
    obscureTotalIncome = !obscureTotalIncome;
    notifyListeners();
  }

  void toggleExpenseVisibility() {
    obscureTotalExpense = !obscureTotalExpense;
    notifyListeners();
  }

  String displayValue(String value, bool isObscured) {
    return isObscured ? 'Rp******' : value;
  }

  String getFormattedTotalCashFlow() {
    return CurrencyHelper.formatCurrency(_totalCashFlow);
  }

  String getFormattedTotalIncome() {
    return CurrencyHelper.formatCurrency(_totalIncome);
  }

  String getFormattedTotalExpense() {
    return CurrencyHelper.formatCurrency(_totalExpense);
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
