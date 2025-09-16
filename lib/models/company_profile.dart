class CompanyProfile {
  final String name;
  final String shortName;
  final String slogan;
  final String email;
  final String address;
  final String csPhone;
  final String? logo;

  CompanyProfile({
    required this.name,
    required this.shortName,
    required this.slogan,
    required this.email,
    required this.address,
    required this.csPhone,
    this.logo,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['name'] ?? '',
      shortName: json['short-name'] ?? json['short_name'] ?? '',
      slogan: json['slogan'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      csPhone: json['cs-phone'] ?? json['cs_phone'] ?? '',
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'short-name': shortName,
      'slogan': slogan,
      'email': email,
      'address': address,
      'cs-phone': csPhone,
      'logo': logo,
    };
  }

  bool get hasLogo => logo != null && logo!.isNotEmpty;

  String get displayName => shortName.isNotEmpty ? shortName : name;

  CompanyProfile copyWith({
    String? name,
    String? shortName,
    String? slogan,
    String? email,
    String? address,
    String? csPhone,
    String? logo,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      slogan: slogan ?? this.slogan,
      email: email ?? this.email,
      address: address ?? this.address,
      csPhone: csPhone ?? this.csPhone,
      logo: logo ?? this.logo,
    );
  }

  @override
  String toString() {
    return 'CompanyProfile(name: $name, shortName: $shortName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanyProfile &&
        other.name == name &&
        other.shortName == shortName &&
        other.slogan == slogan &&
        other.email == email &&
        other.address == address &&
        other.csPhone == csPhone &&
        other.logo == logo;
  }

  @override
  int get hashCode {
    return Object.hash(name, shortName, slogan, email, address, csPhone, logo);
  }
}