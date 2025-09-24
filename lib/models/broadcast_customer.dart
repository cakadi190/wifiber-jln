class BroadcastCustomer {
  final int id;
  final String name;
  final String phone;
  final String? status;
  final String? areaName;
  final String? customerCode;
  final Map<String, dynamic> raw;

  const BroadcastCustomer({
    required this.id,
    required this.name,
    required this.phone,
    this.status,
    this.areaName,
    this.customerCode,
    this.raw = const <String, dynamic>{},
  });

  factory BroadcastCustomer.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['customer_id'] ?? json['customerId'];
    final name = _stringOrFallback(
      json['name'] ??
          json['customer_name'] ??
          json['full_name'] ??
          json['username'],
      fallback: 'Tanpa Nama',
    );
    final phone = _stringOrFallback(
      json['phone'] ??
          json['phone_number'] ??
          json['whatsapp'] ??
          json['wa_number'],
    );
    final status = _stringOrNull(
      json['status'] ?? json['customer_status'],
    );
    final area = _stringOrNull(
      json['area'] ?? json['area_name'] ?? json['areaName'],
    );
    final customerCode = _stringOrNull(
      json['customer_code'] ??
          json['customerId'] ??
          json['customer_id'],
    );

    return BroadcastCustomer(
      id: _parseInt(rawId),
      name: name,
      phone: phone,
      status: status,
      areaName: area,
      customerCode: customerCode,
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static String _stringOrFallback(dynamic value, {String fallback = ''}) {
    final result = _stringOrNull(value);
    return result ?? fallback;
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.trim().isEmpty ? null : value;
    }
    return value.toString();
  }
}
