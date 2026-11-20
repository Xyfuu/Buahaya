/// Seluruh path route aplikasi (sesuai flow prototype Figma).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/login/forgot';
  static const terms = '/terms'; // ?view=1 -> mode baca saja
  static const resetPassword = '/reset-password'; // ?token=xxx (tautan email)

  // Tab utama (bottom navigation)
  static const home = '/home';
  static const lists = '/lists'; // ?tab=history
  static const explore = '/explore';
  static const profile = '/profile';

  // Layar penuh
  static const scan = '/scan';
  static const createList = '/lists/create';
  static const addToList = '/lists/add';
  static const editProfile = '/profile/edit';
  static const help = '/profile/help';
}
