import 'dart:collection';

class RouterPppoeSecrets {
  final Map<String, RouterPppoeSecret> activeSecrets;
  final Map<String, RouterPppoeSecret> inactiveSecrets;

  RouterPppoeSecrets({
    required this.activeSecrets,
    required this.inactiveSecrets,
  });

  factory RouterPppoeSecrets.fromJson(Map<String, dynamic> json) {
    return RouterPppoeSecrets(
      activeSecrets: _parseSecrets(json['active_secrets']),
      inactiveSecrets: _parseSecrets(json['inactive_secrets']),
    );
  }

  static Map<String, RouterPppoeSecret> _parseSecrets(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map(
        (key, value) => MapEntry(
          key,
          RouterPppoeSecret.fromJson(value as Map<String, dynamic>, nameOverride: key),
        ),
      );
    }
    return {};
  }

  UnmodifiableListView<RouterPppoeSecret> get activeList =>
      UnmodifiableListView(activeSecrets.values);

  UnmodifiableListView<RouterPppoeSecret> get inactiveList =>
      UnmodifiableListView(inactiveSecrets.values);
}

class RouterPppoeSecret {
  final String? id;
  final String name;
  final String service;
  final String? callerId;
  final String? password;
  final String profile;
  final String? routes;
  final String? ipv6Routes;
  final String? limitBytesIn;
  final String? limitBytesOut;
  final String? lastLoggedOut;
  final String? lastCallerId;
  final String? lastDisconnectReason;
  final bool disabled;
  final String? uptime;

  RouterPppoeSecret({
    required this.id,
    required this.name,
    required this.service,
    this.callerId,
    this.password,
    required this.profile,
    this.routes,
    this.ipv6Routes,
    this.limitBytesIn,
    this.limitBytesOut,
    this.lastLoggedOut,
    this.lastCallerId,
    this.lastDisconnectReason,
    required this.disabled,
    this.uptime,
  });

  factory RouterPppoeSecret.fromJson(
    Map<String, dynamic> json, {
    String? nameOverride,
  }) {
    return RouterPppoeSecret(
      id: json['.id']?.toString(),
      name: (nameOverride ?? json['name'] ?? '').toString(),
      service: json['service']?.toString() ?? '-',
      callerId: json['caller-id']?.toString(),
      password: json['password']?.toString(),
      profile: json['profile']?.toString() ?? '-',
      routes: json['routes']?.toString(),
      ipv6Routes: json['ipv6-routes']?.toString(),
      limitBytesIn: json['limit-bytes-in']?.toString(),
      limitBytesOut: json['limit-bytes-out']?.toString(),
      lastLoggedOut: json['last-logged-out']?.toString(),
      lastCallerId: json['last-caller-id']?.toString(),
      lastDisconnectReason: json['last-disconnect-reason']?.toString(),
      disabled: _parseBool(json['disabled']),
      uptime: json['uptime']?.toString(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  bool get isActive => !disabled;
}
