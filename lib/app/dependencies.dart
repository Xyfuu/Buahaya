import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/shopping_controller.dart';
import '../controllers/store_controller.dart';
import '../core/config/app_config.dart';
import '../data/mock/mock_auth_repository.dart';
import '../data/mock/mock_fruit_scan_repository.dart';
import '../data/mock/mock_notification_repository.dart';
import '../data/mock/mock_profile_repository.dart';
import '../data/mock/mock_shopping_repository.dart';
import '../data/mock/mock_store_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/fruit_scan_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/shopping_repository.dart';
import '../domain/repositories/store_repository.dart';

/// Titik tunggal wiring repository -> controller.
///
/// INTEGRASI BACKEND: buat implementasi interface di lib/domain/repositories/
/// (mis. ApiAuthRepository) lalu tukar di [_buildRepositories].
class AppDependencies {
  AppDependencies._(this.scanRepository, this.auth, this.profile, this.shopping,
      this.notifications, this.stores);

  final FruitScanRepository scanRepository;
  final AuthController auth;
  final ProfileController profile;
  final ShoppingController shopping;
  final NotificationController notifications;
  final StoreController stores;

  factory AppDependencies.create() {
    final r = _buildRepositories();
    return AppDependencies._(
      r.scan,
      AuthController(r.auth),
      ProfileController(r.profile),
      ShoppingController(r.shopping),
      NotificationController(r.notifications),
      StoreController(r.stores),
    );
  }

  static ({
    AuthRepository auth,
    ProfileRepository profile,
    ShoppingRepository shopping,
    NotificationRepository notifications,
    StoreRepository stores,
    FruitScanRepository scan,
  }) _buildRepositories() {
    if (!AppConfig.useMockData) {
      // TODO(backend): kembalikan implementasi API di sini.
      throw UnimplementedError('Isi implementasi repository API lalu hapus baris ini.');
    }
    return (
      auth: MockAuthRepository(),
      profile: MockProfileRepository(),
      shopping: MockShoppingRepository(),
      notifications: MockNotificationRepository(),
      stores: MockStoreRepository(),
      scan: MockFruitScanRepository(),
    );
  }
}
