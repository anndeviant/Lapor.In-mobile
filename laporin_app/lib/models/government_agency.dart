class GovernmentAgency {
  final int id;
  final String name;
  final String description;
  final String contactInfo;
  final String address;

  GovernmentAgency({
    required this.id,
    required this.name,
    required this.description,
    this.contactInfo = '',
    this.address = '',
  });

  factory GovernmentAgency.fromJson(Map<String, dynamic> json) {
    return GovernmentAgency(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contactInfo: json['contact_info'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'contact_info': contactInfo,
      'address': address,
    };
  }
}
