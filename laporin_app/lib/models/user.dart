class User {
  final int? id;
  final String fullname;
  final String phoneNumber;
  final String? password;
  final String? deviceInfo;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.fullname,
    required this.phoneNumber,
    this.password,
    this.deviceInfo,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      phoneNumber: json['phone_number'],
      deviceInfo: json['device_info'],
      isActive: json['is_active'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'password': password,
      'device_info': deviceInfo,
      'is_active': isActive,
    };
  }
}
