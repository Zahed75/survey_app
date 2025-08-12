class Site {
  final int id;
  final String siteCode;
  final String name;
  final String address;
  final String district;
  final String postCode;
  final String source;

  Site({
    required this.id,
    required this.siteCode,
    required this.name,
    required this.address,
    required this.district,
    required this.postCode,
    required this.source,
  });

  // Factory constructor for creating a Site from JSON
  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      siteCode: json['site_code'],
      name: json['name'],
      address: json['address']?.trim() ?? '',
      // Ensure address is fetched and trimmed
      district: json['district'] ?? '',
      postCode: json['post_code'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
