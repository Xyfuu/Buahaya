import '../models/profile.dart';

abstract class AuthRepository {
    Future<UserProfile?> restoreSession();

  Future<UserProfile> login({
    required String identifier,
    required String password,
    bool remember = true,
  });

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset(String email);

    Future<UserProfile> resetPassword({required String token, required String newPassword});

  Future<void> logout();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
