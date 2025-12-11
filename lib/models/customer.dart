import 'package:flutter/cupertino.dart';
import 'package:wifiber/helpers/currency_helper.dart';

class Customer {
  final String id;
  final String customerId;
  final String name;
  final String? nickname;
  final String phone;
  final String identityNumber;
  final String address;
  final String status;
  final String? ktpPhoto;
  final String? locationPhoto;
  final String packageId;
  final String areaId;
  final String? routerId;
  final String pppoeSecret;
  final String dueDate;
  final String createdAt;
  final String? odpId;
  final String? latitude;
  final String? longitude;
  final String discount;
  final String packageName;
  final String packagePrice;
  final String packagePpn;
  final String? routerName;
  final String? routerHost;
  final String? areaName;

  Customer({
    required this.id,
    required this.customerId,
    required this.name,
    this.nickname,
    required this.phone,
    required this.identityNumber,
    required this.address,
    required this.status,
    this.ktpPhoto,
    this.locationPhoto,
    required this.packageId,
    required this.areaId,
    this.routerId,
    required this.pppoeSecret,
    required this.dueDate,
    required this.createdAt,
    this.odpId,
    this.latitude,
    this.longitude,
    required this.discount,
    required this.packageName,
    required this.packagePrice,
    required this.packagePpn,
    this.routerName,
    this.routerHost,
    this.areaName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    debugPrint(json.toString());

    return Customer(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      name: json['name'],
      nickname: json['nickname'],
      phone: json['phone'],
      identityNumber: json['identity_number'],
      address: json['address'],
      status: json['status'],
      ktpPhoto: json['ktp_photo'],
      locationPhoto: json['location_photo'],
      packageId: json['package_id'].toString(),
      areaId: json['area_id'].toString(),
      routerId: json['router_id']?.toString(),
      pppoeSecret: json['pppoe_secret'],
      dueDate: json['due_date'].toString(),
      createdAt: json['created_at'],
      odpId: json['odp_id']?.toString(),
      latitude: json['latitude'],
      longitude: json['longitude'],
      discount: json['discount'].toString(),
      packageName: json['package_name'],
      packagePrice: json['package_price'].toString(),
      packagePpn: json['package_ppn'].toString(),
      routerName: json['router_name'],
      routerHost: json['router_host'],
      areaName: json['area_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'identity_number': identityNumber,
      'address': address,
      'status': status,
      'ktp_photo': ktpPhoto,
      'location_photo': locationPhoto,
      'package_id': packageId,
      'area_id': areaId,
      'router_id': routerId,
      'pppoe_secret': pppoeSecret,
      'due_date': dueDate,
      'created_at': createdAt,
      'odp_id': odpId,
      'latitude': latitude,
      'longitude': longitude,
      'discount': discount,
      'package_name': packageName,
      'package_price': packagePrice,
      'package_ppn': packagePpn,
      'router_name': routerName,
      'router_host': routerHost,
      'area_name': areaName,
    };
  }
}

class CustomerResponse {
  final bool success;
  final String message;
  final List<Customer> data;
  final Map<String, dynamic>? error;

  CustomerResponse({
    required this.success,
    required this.message,
    required this.data,
    this.error,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'],
      message: json['message'],
      data: List<Customer>.from(json['data'].map((x) => Customer.fromJson(x))),
      error: json['error'],
    );
  }
}

extension CustomerExtension on Customer {
  bool hasValidCoordinates() {
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    return lat != null && lng != null;
  }

  double? get lat => double.tryParse(latitude ?? '');
  double? get lng => double.tryParse(longitude ?? '');

  String get statusDisplay {
    switch (status) {
      case 'customer':
        return 'Pelanggan';
      case 'registrant':
        return 'Pendaftar';
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'suspended':
        return 'Suspend';
      default:
        return status;
    }
  }

  String get formattedPrice {
    final price = int.tryParse(packagePrice) ?? 0;
    final disc = int.tryParse(discount) ?? 0;
    final total = price - disc;
    return CurrencyHelper.formatCurrency(total);
  }

  String get formattedDiscount {
    final disc = int.tryParse(discount) ?? 0;
    if (disc == 0) return '-';
    return CurrencyHelper.formatCurrency(disc);
  }
}
