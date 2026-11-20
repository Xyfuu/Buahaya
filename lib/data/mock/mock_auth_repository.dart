import '../../domain/models/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'mock_seed.dart';

/// Repository mock: menerima kredensial apa pun yang tidak kosong.
/// Ganti dengan implementasi API (POST /auth/login, dst).
class MockAuthRepository implements AuthRepository {
  UserProfile? _session;

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 450));

  @override
  Future<UserProfile?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _session;
  }

  @override
  Future<UserProfile> login({
    required String identifier,
    required String password,
    bool remember = true,
  }) async {
    await _latency();
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Incorrect email/username or password.');
    }
    return _session = MockSeed.profile;
  }

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    await _latency();
  }

  @override
  Future<void> requestPasswordReset(String email) => _latency();

  @override
  Future<UserProfile> resetPassword({required String token, required String newPassword}) async {
    await _latency();
    return _session = MockSeed.profile;
  }

  @override
  Future<void> logout() async {
    await _latency();
    _session = null;
  }
}
