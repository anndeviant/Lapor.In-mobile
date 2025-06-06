class GovernmentAgency {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phoneNumber;

  GovernmentAgency({
    required this.id,
    required this.name,
    required this.description,
    this.address = '',
    this.phoneNumber = '',
  });

  factory GovernmentAgency.fromJson(Map<String, dynamic> json) {
    return GovernmentAgency(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}
