class Employee {
  final String id;
  final String name;
  final String? email;
  final String? username;
  final String? role;
  final String? picture;

  Employee({
    required this.id,
    required this.name,
    this.email,
    this.username,
    this.role,
    this.picture,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'],
      username: json['username'],
      role: json['role']?.toString(),
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role,
      'picture': picture,
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
