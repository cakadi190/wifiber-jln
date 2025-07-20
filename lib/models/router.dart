class RouterModel {
  final int id;
  final String name;
  final String host;
  final int toleranceDays;
  final String status;
  final String action;
  final String isolirProfile;
  final String createdAt;

  RouterModel({
    required this.id,
    required this.name,
    required this.host,
    required this.toleranceDays,
    required this.status,
    required this.action,
    required this.isolirProfile,
    required this.createdAt,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: int.parse(json['id']),
      name: json['name'],
      host: json['host'],
      toleranceDays: int.parse(json['tolerance_days']),
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

class ToggleRouterModel {
  final String ppoeSecret;
  final String routerId;
  final String action;

  ToggleRouterModel({
    required this.ppoeSecret,
    required this.routerId,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'ppoe_secret': ppoeSecret,
      'router_id': routerId,
      'action': action,
    };
  }
}

enum ToggleRouterAction { enable, disable }