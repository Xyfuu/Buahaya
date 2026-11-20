import '../models/profile.dart';

/// Kontrak autentikasi. Implementasikan dengan API backend.
/// Lempar [AuthException] bila gagal (pesan ditampilkan ke pengguna).
abstract class AuthRepository {
  /// Cek token tersimpan. Null bila belum login / token kedaluwarsa.
  Future<UserProfile?> restoreSession();

  Future<UserProfile> login({
    required String identifier, // email atau username
    required String password,
    bool remember = true,
  });

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset(String email);

  /// Dipanggil dari halaman "Redirect pass page" (tautan email).
  Future<UserProfile> resetPassword({required String token, required String newPassword});

  Future<void> logout();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
