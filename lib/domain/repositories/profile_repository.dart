import '../models/profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    required String fullName,
    required String username,
    required String email,
  });

    Future<UserProfile> updateAvatar(String localPath);

  Future<UserProfile> setNotificationsEnabled(bool enabled);
}
