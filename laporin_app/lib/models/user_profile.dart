import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final String? profileImagePath;

  @HiveField(2)
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    this.profileImagePath,
    required this.updatedAt,
  });

  UserProfile copyWith({
    int? userId,
    String? profileImagePath,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
