/// App-wide configuration.
class AppConfig {
  /// Base URL of the Django backend.
  ///
  /// IMPORTANT - choose the right host for how you run the app:
  ///   * Android emulator  -> http://10.0.2.2:8000
  ///   * iOS simulator     -> http://127.0.0.1:8000
  ///   * Real phone (USB / same Wi-Fi) -> http://<YOUR-PC-LAN-IP>:8000
  ///       find it on Windows with `ipconfig` (IPv4 Address).
  //
  // Default = localhost via USB `adb reverse tcp:8000 tcp:8000` — immune to
  // Wi-Fi IP changes and firewalls (rock solid for demos with the cable in).
  // You can also override the server URL at runtime in Settings → Server
  // connection (handy for Wi-Fi with a static PC IP), no rebuild needed.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
