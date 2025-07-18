class Bills {
  final String id;
  final String customerId;
  final String invoice;
  final String period;
  final BillStatus status;
  final int basePrice;
  final int tax;
  final String packageName;
  final DateTime? paymentAt;
  final String? paymentReceivedBy;
  final String? paymentMethod;
  final String? additionalInfo;
  final DateTime? createdAt;
  final int? discount;
  final String name;
  final String? nickname;
  final String? address;
  final String? phone;
  final DateTime dueDate;
  final String? ppoeSecret;
  final String? locationPhoto;
  final int? routerId;

  Bills({
    required this.id,
    required this.customerId,
    required this.invoice,
    required this.period,
    required this.status,
    required this.basePrice,
    required this.tax,
    required this.packageName,
    this.paymentAt,
    this.paymentReceivedBy,
    this.paymentMethod,
    this.additionalInfo,
    this.createdAt,
    this.discount,
    required this.name,
    this.nickname,
    this.address,
    this.phone,
    required this.dueDate,
    this.ppoeSecret,
    this.locationPhoto,
    this.routerId,
  });

  factory Bills.fromJson(Map<String, dynamic> json) {
    print(json);

    return Bills(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      invoice: json['invoice'].toString(),
      period: json['period'].toString(),
      status: BillStatus.values.firstWhere(
            (status) => status.name.toUpperCase() == json['status'].toString().toUpperCase(),
        orElse: () => BillStatus.UNPAID,
      ),
      basePrice: json['base_price'] ?? 0,
      tax: json['tax'] ?? 0,
      packageName: json['package_name']?.toString() ?? '',
      paymentAt: json['payment_at'] != null ? DateTime.tryParse(json['payment_at'].toString()) : null,
      paymentReceivedBy: json['payment_received_by']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      additionalInfo: json['additional_info']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      discount: json['discount'],
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      dueDate: DateTime.parse(json['due_date'].toString()),
      ppoeSecret: json['pppoe_secret']?.toString(),
      locationPhoto: json['location_photo']?.toString(),
      routerId: json['router_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'invoice': invoice,
    'period': period,
    'status': status.name.toLowerCase(),
    'base_price': basePrice,
    'tax': tax,
    'package_name': packageName,
    'payment_at': paymentAt?.toIso8601String(),
    'payment_received_by': paymentReceivedBy,
    'payment_method': paymentMethod,
    'additional_info': additionalInfo,
    'created_at': createdAt?.toIso8601String(),
    'discount': discount,
    'name': name,
    'nickname': nickname,
    'address': address,
    'phone': phone,
    'due_date': dueDate.toIso8601String(),
    'pppoe_secret': ppoeSecret,
    'location_photo': locationPhoto,
    'router_id': routerId,
  };

  int get totalAmount => basePrice + tax - (discount ?? 0);

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == BillStatus.UNPAID;

  bool get isPaid => status == BillStatus.PAID;

  Bills copyWith({
    String? id,
    String? customerId,
    String? invoice,
    String? period,
    BillStatus? status,
    int? basePrice,
    int? tax,
    String? packageName,
    DateTime? paymentAt,
    String? paymentReceivedBy,
    String? paymentMethod,
    String? additionalInfo,
    DateTime? createdAt,
    int? discount,
    String? name,
    String? nickname,
    String? address,
    String? phone,
    DateTime? dueDate,
    String? ppoeSecret,
    String? locationPhoto,
    int? routerId,
  }) {
    return Bills(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      invoice: invoice ?? this.invoice,
      period: period ?? this.period,
      status: status ?? this.status,
      basePrice: basePrice ?? this.basePrice,
      tax: tax ?? this.tax,
      packageName: packageName ?? this.packageName,
      paymentAt: paymentAt ?? this.paymentAt,
      paymentReceivedBy: paymentReceivedBy ?? this.paymentReceivedBy,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      discount: discount ?? this.discount,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      dueDate: dueDate ?? this.dueDate,
      ppoeSecret: ppoeSecret ?? this.ppoeSecret,
      locationPhoto: locationPhoto ?? this.locationPhoto,
      routerId: routerId ?? this.routerId,
    );
  }

  @override
  String toString() {
    return 'Bills(id: $id, customerId: $customerId, invoice: $invoice, status: $status, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bills && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BillResponse {
  final List<Bills> data;
  final String message;
  final bool success;

  BillResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) => BillResponse(
    data: List<Bills>.from(json['data'].map((x) => Bills.fromJson(x))),
    message: json['message'],
    success: json['success'],
  );

  Map<String, dynamic> toJson() => {
    'data': data.map((x) => x.toJson()).toList(),
    'message': message,
    'success': success,
  };
}

enum BillStatus {
  PAID,
  UNPAID;

  String get displayName {
    switch (this) {
      case BillStatus.PAID:
        return 'Terbayar';
      case BillStatus.UNPAID:
        return 'Belum Terbayar';
    }
  }
}

class CreateBill {
  final String customerId;
  final String period;
  final bool? isPaid;
  final bool? openIsolir;
  final String? paymentMethod;
  final DateTime paymentAt;
  final String? paymentProof;
  final String? paymentNote;

  CreateBill({
    required this.customerId,
    required this.period,
    this.isPaid,
    this.openIsolir,
    this.paymentMethod,
    required this.paymentAt,
    this.paymentProof,
    this.paymentNote,
  });

  factory CreateBill.fromJson(Map<String, dynamic> json) => CreateBill(
    customerId: json['customer_id'].toString(),
    period: json['period'].toString(),
    isPaid: json['is_paid'],
    openIsolir: json['open_isolir'],
    paymentMethod: json['payment_method']?.toString(),
    paymentAt: DateTime.parse(json['payment_at'].toString()),
    paymentProof: json['payment_proof']?.toString(),
    paymentNote: json['payment_note']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'period': period,
    'is_paid': isPaid,
    'open_isolir': openIsolir,
    'payment_method': paymentMethod,
    'payment_at': paymentAt.toIso8601String(),
    'payment_proof': paymentProof,
    'payment_note': paymentNote,
  };

  @override
  String toString() {
    return 'CreateBill(customerId: $customerId, period: $period, isPaid: $isPaid)';
  }
}