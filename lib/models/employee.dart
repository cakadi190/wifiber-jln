class Employee {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? position;

  Employee({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.position,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
    };
  }
}

class EmployeeResponse {
  final bool success;
  final String message;
  final List<Employee> data;
  final Map<String, dynamic>? error;

  EmployeeResponse({
    required this.success,
    required this.message,
    required this.data,
    this.error,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<Employee>.from(
              (json['data'] as List).map((e) => Employee.fromJson(e)),
            )
          : <Employee>[],
      error: json['error'],
    );
  }
}
