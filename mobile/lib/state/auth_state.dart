import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

/// Holds authentication status and exposes login / register / logout.
class AuthState extends ChangeNotifier {
  final _api = ApiClient.instance;

  bool get isAuthenticated => _api.isAuthenticated;

  Future<void> login(String username, String password) async {
    await _api.login(username, password);
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    await _api.register(username, email, password);
    await _api.login(username, password); // auto-login after sign-up
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    notifyListeners();
  }
}
