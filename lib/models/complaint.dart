class Complaint {
  int? id;
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
    this.id,
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
  final List<Complaint> data;
  final Map<String, dynamic>? error;

  ComplaintResponse({
    required this.success,
    required this.message,
    required this.data,
    this.error,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) =>
      ComplaintResponse(
        success: json['success'],
        message: json['message'],
        data: List<Complaint>.from(
          json['data'].map((x) => Complaint.fromJson(x)),
        ),
        error: json['error'],
      );
}

enum ComplaintStatus { pending, ongoing, completed }

enum ComplaintType { complaint, registration }
