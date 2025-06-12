import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../utils/hive_box.dart';

class ProfileService {
  static Box<UserProfile>? _profileBox;

  static Future<Box<UserProfile>> get _box async {
    _profileBox ??= await Hive.openBox<UserProfile>(HiveBox.userProfiles);
    return _profileBox!;
  }

  // Save profile image for specific user
  static Future<void> saveProfileImage(int userId, String imagePath) async {
    try {
      final box = await _box;
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_images');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Create unique filename with user ID
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${profileDir.path}/$fileName';

      // Copy image to app directory
      final imageFile = File(imagePath);
      await imageFile.copy(savedImagePath);

      // Get existing profile or create new one
      UserProfile? existingProfile = box.get(userId);

      // Delete old image if exists
      if (existingProfile?.profileImagePath != null) {
        final oldFile = File(existingProfile!.profileImagePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      // Save new profile
      final userProfile = UserProfile(
        userId: userId,
        profileImagePath: savedImagePath,
        updatedAt: DateTime.now(),
      );

      await box.put(userId, userProfile);
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  // Get profile image path for specific user
  static Future<String?> getProfileImagePath(int userId) async {
    try {
      final box = await _box;
      final userProfile = box.get(userId);

      if (userProfile?.profileImagePath != null) {
        final file = File(userProfile!.profileImagePath!);
        if (await file.exists()) {
          return userProfile.profileImagePath;
        } else {
          // Clean up if file doesn't exist
          await box.delete(userId);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete profile image for specific user
  static Future<void> deleteProfileImage(int userId) async {
    try {
      final box = await _box;
      final userProfile = box.get(userId);

      if (userProfile?.profileImagePath != null) {
        final file = File(userProfile!.profileImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await box.delete(userId);
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  // Check if user has profile image
  static Future<bool> hasProfileImage(int userId) async {
    final imagePath = await getProfileImagePath(userId);
    return imagePath != null;
  }
}
