/// App-wide configuration.
class AppConfig {
  /// Base URL of the backend.
  ///
  /// Defaults to the deployed Render service, so a fresh install works over
  /// the internet with no laptop, no cable and no setup.
  ///
  /// Settings > Server connection overrides this at runtime — point it at a PC
  /// on the LAN, or at http://127.0.0.1:8000 with `adb reverse tcp:8000
  /// tcp:8000` for offline development — with no rebuild needed.
  ///
  /// Override at build time instead with:
  ///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://aegis-health-jc2o.onrender.com',
  );
}
