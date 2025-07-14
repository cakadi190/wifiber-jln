class Complaint {
  String id;
  String? number;
  String? customerId;
  String? subject;
  String? type;
  String? status;
  String? createdAt;
  String? name;
  String? nickname;
  String? phone;
  String? address;
  String? locationPhoto;

  Complaint({
    required this.id,
    this.number,
    this.customerId,
    this.subject,
    this.type,
    this.status,
    this.createdAt,
    this.name,
    this.nickname,
    this.phone,
    this.address,
    this.locationPhoto,
  });

  String get topic => subject ?? '';

  DateTime get date => DateTime.tryParse(createdAt ?? '') ?? DateTime.now();

  ComplaintStatus get statusEnum {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'ongoing':
      case 'processing':
        return ComplaintStatus.processing;
      case 'completed':
      case 'resolved':
        return ComplaintStatus.resolved;
      default:
        return ComplaintStatus.pending;
    }
  }

  ComplaintType get typeEnum {
    switch (type?.toLowerCase()) {
      case 'complaint':
        return ComplaintType.complaint;
      case 'registration':
        return ComplaintType.registration;
      default:
        return ComplaintType.complaint;
    }
  }

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'],
    number: json['number'],
    customerId: json['customer_id'],
    subject: json['subject'],
    type: json['type'],
    status: json['status'],
    createdAt: json['created_at'],
    name: json['name'],
    nickname: json['nickname'],
    phone: json['phone'],
    address: json['address'],
    locationPhoto: json['location_photo'],
  );

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() => {
    'id': id,
    'number': number,
    'customer_id': customerId,
    'subject': subject,
    'type': type,
    'status': status,
    'created_at': createdAt,
    'name': name,
    'nickname': nickname,
    'phone': phone,
    'address': address,
    'location_photo': locationPhoto,
  };
}

class CreateComplaint {
  final String subject;
  final String topic;
  final DateTime date;

  CreateComplaint({
    required this.subject,
    required this.topic,
    required this.date,
  });

  factory CreateComplaint.fromJson(Map<String, dynamic> json) =>
      CreateComplaint(
        subject: json['subject'],
        topic: json['topic'],
        date: DateTime.parse(json['date']),
      );

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'topic': topic,
    'date': date.toIso8601String(),
  };
}

class UpdateComplaint {
  final int id;
  final String detail;
  final String name;
  final bool ticketIsDone;

  UpdateComplaint({
    required this.id,
    required this.detail,
    required this.name,
    required this.ticketIsDone,
  });

  factory UpdateComplaint.fromJson(Map<String, dynamic> json) =>
      UpdateComplaint(
        id: json['id'],
        detail: json['detail'],
        name: json['name'],
        ticketIsDone: json['ticket_is_done'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'detail': detail,
    'name': name,
    'ticket_is_done': ticketIsDone,
  };
}

class ComplaintResponse {
  final bool success;
  final String message;
  final List<Complaint>? data;

  ComplaintResponse({required this.success, required this.message, this.data});

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
                .map((item) => Complaint.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

enum ComplaintStatus { pending, processing, resolved }

enum ComplaintType { registration, complaint }
