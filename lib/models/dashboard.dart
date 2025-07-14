class DashboardData {
  final bool success;
  final DashboardInfo data;
  final String? error;

  DashboardData({
    required this.success,
    required this.data,
    this.error,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      success: json['success'] ?? false,
      data: DashboardInfo.fromJson(json['data'] ?? {}),
      error: json['error'],
    );
  }
}

class DashboardInfo {
  final CustomerInfo totalCustomer;
  final num totalUnpaidBills;
  final CurrentMonthInfo currentMonth;
  final TicketInfo totalTicket;

  DashboardInfo({
    required this.totalCustomer,
    required this.totalUnpaidBills,
    required this.currentMonth,
    required this.totalTicket,
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    return DashboardInfo(
      totalCustomer: CustomerInfo.fromJson(json['total_customer'] ?? {}),
      totalUnpaidBills: json['total_unpaid_bills'] ?? 0,
      currentMonth: CurrentMonthInfo.fromJson(json['current_month'] ?? {}),
      totalTicket: TicketInfo.fromJson(json['total_ticket'] ?? {}),
    );
  }
}

class CustomerInfo {
  final int active;
  final int newCustomer;
  final int inactive;
  final int isolir;
  final int free;

  CustomerInfo({
    required this.active,
    required this.newCustomer,
    required this.inactive,
    required this.isolir,
    required this.free,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      active: json['active'] ?? 0,
      newCustomer: json['new'] ?? 0,
      inactive: json['inactive'] ?? 0,
      isolir: json['isolir'] ?? 0,
      free: json['free'] ?? 0,
    );
  }
}

class CurrentMonthInfo {
  final int unpaidBills;
  final FinanceInfo finance;

  CurrentMonthInfo({
    required this.unpaidBills,
    required this.finance,
  });

  factory CurrentMonthInfo.fromJson(Map<String, dynamic> json) {
    return CurrentMonthInfo(
      unpaidBills: json['unpaid_bills'] ?? 0,
      finance: FinanceInfo.fromJson(json['finance'] ?? {}),
    );
  }
}

class FinanceInfo {
  final num income;
  final num expense;

  FinanceInfo({
    required this.income,
    required this.expense,
  });

  factory FinanceInfo.fromJson(Map<String, dynamic> json) {
    return FinanceInfo(
      income: json['income'] ?? 0,
      expense: json['expense'] ?? 0,
    );
  }
}

class TicketInfo {
  final int uncompleted;
  final int pending;
  final int ongoing;
  final int completed;

  TicketInfo({
    required this.uncompleted,
    required this.pending,
    required this.ongoing,
    required this.completed,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      uncompleted: json['uncompleted'] ?? 0,
      pending: json['pending'] ?? 0,
      ongoing: json['ongoing'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}