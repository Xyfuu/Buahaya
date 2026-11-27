import 'package:flutter/foundation.dart';

import '../domain/models/profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repo);

  final ProfileRepository _repo;

  UserProfile? profile;
  bool saving = false;

  Future<void> load() async {
    try {
      profile = await _repo.getProfile();
    } catch (_) {}
    notifyListeners();
  }

  void reset() {
    profile = null;
    notifyListeners();
  }

    Future<String?> update({
    required String fullName,
    required String username,
    required String email,
  }) async {
    saving = true;
    notifyListeners();
    try {
      profile = await _repo.updateProfile(fullName: fullName, username: username, email: email);
      return null;
    } catch (_) {
      return 'Could not save your changes. Please try again.';
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> setAvatar(String localPath) async {
    try {
      profile = await _repo.updateAvatar(localPath);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    final current = profile;
    if (current == null) return;
    profile = current.copyWith(notificationsEnabled: enabled);
    notifyListeners();
    try {
      profile = await _repo.setNotificationsEnabled(enabled);
    } catch (_) {
      profile = current;
    }
    notifyListeners();
  }
}
