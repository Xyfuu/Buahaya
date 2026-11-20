import '../models/profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    required String fullName,
    required String username,
    required String email,
  });

  /// [localPath] = path file hasil image picker. Kembalikan profil terbaru.
  Future<UserProfile> updateAvatar(String localPath);

  Future<UserProfile> setNotificationsEnabled(bool enabled);
}
