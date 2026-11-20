abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isEmail(String v) => _email.hasMatch(v.trim());

  /// Minimal 8 karakter dan mengandung karakter spesial.
  static bool isStrongPassword(String v) =>
      v.length >= 8 && RegExp(r'[^A-Za-z0-9]').hasMatch(v);
}
