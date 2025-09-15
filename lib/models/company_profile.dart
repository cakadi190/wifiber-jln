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
}
