import 'package:flutter/foundation.dart';

import '../domain/models/profile.dart';
import '../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// State sesi pengguna. Metode mengembalikan pesan error (null = sukses).
class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _user;
  bool _busy = false;

  AuthStatus get status => _status;
  UserProfile? get user => _user;
  bool get busy => _busy;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> restoreSession() async {
    try {
      _user = await _repo.restoreSession();
    } catch (_) {
      _user = null;
    }
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<String?> login(String identifier, String password, {bool remember = true}) =>
      _run(() async {
        _user = await _repo.login(identifier: identifier, password: password, remember: remember);
        _status = AuthStatus.authenticated;
      });

  Future<String?> signUp({
    required String username,
    required String email,
    required String password,
  }) =>
      _run(() => _repo.signUp(username: username, email: email, password: password));

  Future<String?> requestPasswordReset(String email) =>
      _run(() => _repo.requestPasswordReset(email));

  Future<String?> resetPassword(String token, String newPassword) => _run(() async {
        _user = await _repo.resetPassword(token: token, newPassword: newPassword);
        _status = AuthStatus.authenticated;
      });

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
