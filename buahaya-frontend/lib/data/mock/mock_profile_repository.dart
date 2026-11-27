import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'mock_seed.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile _profile = MockSeed.profile;

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<UserProfile> getProfile() async {
    await _latency();
    return _profile;
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String username,
    required String email,
  }) async {
    await _latency();
    return _profile = _profile.copyWith(fullName: fullName, username: username, email: email);
  }

  @override
  Future<UserProfile> updateAvatar(String localPath) async {
    await _latency();
    return _profile = _profile.copyWith(avatarUrl: localPath);
  }

  @override
  Future<UserProfile> setNotificationsEnabled(bool enabled) async {
    await _latency();
    return _profile = _profile.copyWith(notificationsEnabled: enabled);
  }
}
