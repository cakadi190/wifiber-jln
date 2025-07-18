class Bills {
  final String id;
  final String customerId;
  final String invoice;
  final String period;
  final BillStatus status;
  final int basePrice;
  final int tax;
  final String packageName;
  final String? paymentAt;
  final String? paymentReceivedBy;
  final String? paymentMethod;
  final String? additionalInfo;
  final String? createdAt;
  final int? discount;
  final String name;
  final String? nickname;
  final String? address;
  final String? phone;
  final int dueDate;
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

  factory Bills.fromJson(Map<String, dynamic> json) => Bills(
    id: json['id'].toString(),
    customerId: json['customer_id'].toString(),
    invoice: json['invoice'].toString(),
    period: json['period'].toString(),
    status: BillStatus.values.firstWhere(
      (status) => status.toString() == 'BillStatus.${json['status'].toString().toUpperCase()}',
    ),
    basePrice: json['base_price'],
    tax: json['tax'],
    packageName: json['package_name'].toString(),
    paymentAt: json['payment_at'].toString(),
    paymentReceivedBy: json['payment_received_by'].toString(),
    paymentMethod: json['payment_method'].toString(),
    additionalInfo: json['additional_info'].toString(),
    createdAt: json['created_at'].toString(),
    discount: json['discount'],
    name: json['name'].toString(),
    nickname: json['nickname'].toString(),
    address: json['address'].toString(),
    phone: json['phone'].toString(),
    dueDate: json['due_date'],
    ppoeSecret: json['pppoe_secret'].toString(),
    locationPhoto: json['location_photo'].toString(),
    routerId: json['router_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'invoice': invoice,
    'period': period,
    'status': status.toString(),
    'basePrice': basePrice,
    'tax': tax,
    'packageName': packageName,
    'paymentAt': paymentAt,
    'paymentReceivedBy': paymentReceivedBy,
    'paymentMethod': paymentMethod,
    'additionalInfo': additionalInfo,
    'createdAt': createdAt,
    'discount': discount,
    'name': name,
    'nickname': nickname,
    'address': address,
    'phone': phone,
    'dueDate': dueDate,
    'pppoeSecret': ppoeSecret,
    'locationPhoto': locationPhoto,
    'routerId': routerId,
  };
}

enum BillStatus { PAID, UNPAID }