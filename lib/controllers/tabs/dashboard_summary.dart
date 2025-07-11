import 'package:flutter/material.dart';

class DashboardSummaryController extends ChangeNotifier {
  bool obscureTotalCashFlow = true;
  bool obscureTotalIncome = true;
  bool obscureTotalExpense = true;
  num unpaidInvoiceCount = 10;

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
    return isObscured ? 'Rp ******' : value;
  }
}
