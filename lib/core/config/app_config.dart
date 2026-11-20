/// Konfigurasi global. Ganti saat integrasi backend.
abstract final class AppConfig {
  static const appName = 'Buahaya';
  static const version = 'v1.1.0';
  static const supportEmail = 'support@buahaya.app';

  /// Base URL REST API backend (dipakai oleh implementasi repository nyata).
  static const apiBaseUrl = 'https://api.buahaya.app';

  /// true  -> pakai repository mock (data lokal in-memory).
  /// false -> pakai repository API (lihat lib/app/dependencies.dart).
  static const useMockData = true;

  /// Dipakai sebagai User-Agent tile OpenStreetMap & package id.
  static const packageId = 'com.buahaya.app';
}
