class RouterModel {
  final int id;
  final String name;
  final String ip;
  final String host;
  final int toleranceDays;
  final String status;
  final String action;
  final String isolirProfile;
  final String createdAt;

  RouterModel({
    required this.id,
    required this.name,
    required this.ip,
    required this.host,
    required this.toleranceDays,
    required this.status,
    required this.action,
    required this.isolirProfile,
    required this.createdAt,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: json['id'],
      name: json['name'],
      ip: json['ip'],
      host: json['host'],
      toleranceDays: json['tolerance_days'],
      status: json['status'],
      action: json['action'],
      isolirProfile: json['isolir_profile'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ip': ip,
      'host': host,
      'tolerance_days': toleranceDays,
      'status': status,
      'action': action,
      'isolir_profile': isolirProfile,
      'created_at': createdAt,
    };
  }
}

class AddRouterModel {
  final String name;
  final String hostname;
  final String username;
  final String password;
  final String port;
  final int toleranceDays;
  final String isolateAction;
  final String? isolateProfile;
  final bool isAutoIsolate;

  AddRouterModel({
    required this.name,
    required this.hostname,
    required this.username,
    required this.password,
    required this.port,
    required this.toleranceDays,
    required this.isolateAction,
    this.isolateProfile,
    this.isAutoIsolate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hostname': hostname,
      'username': username,
      'password': password,
      'port': port,
      'tolerance_days': toleranceDays,
      'isolate_action': isolateAction,
      'isolate_profile': isolateProfile,
      'is_auto_isolate': isAutoIsolate,
    };
  }
}

class UpdateRouterModel {
  final String name;
  final String hostname;
  final String username;
  final String password;
  final String port;
  final int toleranceDays;
  final String isolateAction;
  final String? isolateProfile;
  final bool isAutoIsolate;

  UpdateRouterModel({
    required this.name,
    required this.hostname,
    required this.username,
    required this.password,
    required this.port,
    required this.toleranceDays,
    required this.isolateAction,
    this.isolateProfile,
    this.isAutoIsolate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hostname': hostname,
      'username': username,
      'password': password,
      'port': port,
      'tolerance_days': toleranceDays,
      'isolate_action': isolateAction,
      'isolate_profile': isolateProfile,
      'is_auto_isolate': isAutoIsolate,
    };
  }
}