import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

/// Thin HTTP client for the AI Medical Assist backend.
///
/// Handles JSON, JWT bearer tokens, and token persistence.
class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // JWT lives in encrypted (Keystore-backed) storage, not plain prefs.
  static const FlutterSecureStorage _secure = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'username';
  static const _avatarKey = 'avatar_b64';
  static const _avatarColorKey = 'avatar_color';
  static const _baseUrlKey = 'api_base_url';
  String? _token;
  String? _refresh;
  String? _username;
  String _avatarB64 = '';
  String _avatarColor = '#20A57A';
  String? _baseOverride;

  /// Requests are given a ceiling so a sleeping free-tier server surfaces as
  /// a clear message rather than a spinner that never resolves.
  static const Duration _timeout = Duration(seconds: 60);

  /// Bumps whenever the cached avatar changes so avatar widgets can rebuild.
  final ValueNotifier<int> avatarRev = ValueNotifier<int>(0);

  /// Runtime server URL (Settings override) or the compile-time default.
  String get _base => (_baseOverride != null && _baseOverride!.isNotEmpty)
      ? _baseOverride!
      : AppConfig.apiBaseUrl;
  String get baseUrl => _base;

  Future<void> setBaseUrl(String url) async {
    url = url.trim();
    _baseOverride = url;
    final prefs = await SharedPreferences.getInstance();
    if (url.isEmpty) {
      await prefs.remove(_baseUrlKey);
    } else {
      await prefs.setString(_baseUrlKey, url);
    }
  }
  String get username => _username ?? 'there';
  String get avatarB64 => _avatarB64;
  String get avatarColor => _avatarColor;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _token = await _secure.read(key: _tokenKey);
      _refresh = await _secure.read(key: _refreshKey);
    } catch (_) {
      _token = null; // keystore hiccup → treat as logged out
      _refresh = null;
    }
    _username = prefs.getString(_userKey);
    _avatarB64 = prefs.getString(_avatarKey) ?? '';
    _avatarColor = prefs.getString(_avatarColorKey) ?? '#20A57A';
    _baseOverride = prefs.getString(_baseUrlKey);
  }

  /// Cache the avatar photo + colour locally (and notify listeners).
  Future<void> cacheAvatar({String? b64, String? color}) async {
    final prefs = await SharedPreferences.getInstance();
    if (b64 != null) {
      _avatarB64 = b64;
      await prefs.setString(_avatarKey, b64);
    }
    if (color != null && color.isNotEmpty) {
      _avatarColor = color;
      await prefs.setString(_avatarColorKey, color);
    }
    avatarRev.value++;
  }

  void _cacheAvatarFrom(Map<String, dynamic> profile) {
    cacheAvatar(
      b64: (profile['avatar'] ?? '') as String,
      color: (profile['avatar_color'] ?? '') as String,
    );
  }

  bool get isAuthenticated => _token != null;

  /// Raised when the session cannot be renewed and the user must sign in
  /// again. Screens catch this to send the user back to the login page
  /// instead of showing a misleading "cannot reach the server" message.
  static const sessionExpiredMessage =
      'Your session has expired. Please sign in again.';

  Future<void> _setToken(String? token, {String? refresh}) async {
    _token = token;
    if (token == null) {
      _refresh = null;
      await _secure.delete(key: _tokenKey);
      await _secure.delete(key: _refreshKey);
      return;
    }
    await _secure.write(key: _tokenKey, value: token);
    if (refresh != null) {
      _refresh = refresh;
      await _secure.write(key: _refreshKey, value: refresh);
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? {} : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = body is Map
        ? (body['detail'] ?? body.values.first).toString()
        : 'Request failed (${r.statusCode}).';
    throw ApiException(r.statusCode, msg);
  }

  /// Exchange the refresh token for a new access token.
  ///
  /// Returns false when the refresh token is missing or itself expired, which
  /// means the session is genuinely over.
  Future<bool> _renew() async {
    if (_refresh == null) return false;
    try {
      final r = await http
          .post(Uri.parse('$_base/api/auth/refresh/'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh': _refresh}))
          .timeout(_timeout);
      if (r.statusCode != 200) return false;
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final access = data['access'] as String?;
      if (access == null) return false;
      // Simple JWT may rotate the refresh token; keep the new one if sent.
      await _setToken(access, refresh: data['refresh'] as String?);
      return true;
    } catch (_) {
      return false;
    }
  }

  static const _wakingUpMessage =
      'Could not reach the server — it may be waking up from sleep. Please try again in a few seconds.';

  /// A free-tier server that has gone to sleep refuses the very first
  /// connection outright (not a timeout), rather than just answering slowly.
  /// One short wait-and-retry usually lands after it wakes, so this never
  /// needs to surface as a raw socket error.
  Future<http.Response> _attempt(Future<http.Response> Function() request,
      {bool retryOnRefusal = true}) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(0,
          'The server took too long to respond. It may be waking up — try again.');
    } on SocketException {
      if (!retryOnRefusal) throw ApiException(0, _wakingUpMessage);
      await Future.delayed(const Duration(seconds: 5));
      return _attempt(request, retryOnRefusal: false);
    } on http.ClientException {
      if (!retryOnRefusal) throw ApiException(0, _wakingUpMessage);
      await Future.delayed(const Duration(seconds: 5));
      return _attempt(request, retryOnRefusal: false);
    }
  }

  /// Run an authenticated request. If the access token has expired, renew it
  /// once and replay the request, so a long-idle session recovers silently
  /// rather than surfacing as a network error.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    var r = await _attempt(request);
    if (r.statusCode == 401 && _token != null) {
      if (await _renew()) {
        r = await _attempt(request);
      } else {
        await _setToken(null);
        throw ApiException(401, sessionExpiredMessage);
      }
    }
    return _decode(r);
  }

  // -- Auth ---------------------------------------------------------------
  Future<void> register(String username, String email, String password) async {
    final r = await http.post(Uri.parse('$_base/api/auth/register/'),
        headers: _headers,
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}));
    _decode(r);
  }

  Future<void> login(String username, String password) async {
    final r = await http.post(Uri.parse('$_base/api/auth/login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}));
    final data = _decode(r);
    await _setToken(data['access'] as String,
        refresh: data['refresh'] as String?);
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
  }

  /// Change the signed-in user's password. The server verifies the current
  /// one, so a borrowed unlocked phone cannot lock the owner out.
  Future<void> changePassword(String current, String next) async {
    await _send(() => http.post(Uri.parse('$_base/api/auth/password/'),
        headers: _headers,
        body: jsonEncode({'current_password': current, 'new_password': next})));
  }

  Future<void> logout() async {
    await _setToken(null);
    _avatarB64 = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarKey);
    avatarRev.value++;
  }

  // -- Predictions --------------------------------------------------------
  Future<Map<String, dynamic>> predict(Map<String, num> answers) async {
    return await _send(() => http.post(Uri.parse('$_base/api/predict/'),
        headers: _headers, body: jsonEncode(answers))) as Map<String, dynamic>;
  }

  Future<List<dynamic>> history() async {
    return await _send(() =>
        http.get(Uri.parse('$_base/api/history/'), headers: _headers))
        as List<dynamic>;
  }

  /// Live model card: architecture (introspected from the trained network) +
  /// real training metrics. Powers the "Under the Hood" transparency screen.
  Future<Map<String, dynamic>> modelCard() async {
    return await _send(() => http.get(Uri.parse('$_base/api/model/card/'),
        headers: _headers)) as Map<String, dynamic>;
  }

  // -- Profile ------------------------------------------------------------
  Future<Map<String, dynamic>> getProfile() async {
    final profile = await _send(() =>
        http.get(Uri.parse('$_base/api/profile/'), headers: _headers))
        as Map<String, dynamic>;
    _cacheAvatarFrom(profile);
    return profile;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final profile = await _send(() => http.patch(
        Uri.parse('$_base/api/profile/'),
        headers: _headers,
        body: jsonEncode(data))) as Map<String, dynamic>;
    _cacheAvatarFrom(profile);
    return profile;
  }

  // -- Chat ---------------------------------------------------------------
  Future<Map<String, dynamic>> sendChat(String message) async {
    return await _send(() => http.post(Uri.parse('$_base/api/chat/'),
        headers: _headers,
        body: jsonEncode({'message': message}))) as Map<String, dynamic>;
  }

  Future<List<dynamic>> chatHistory() async {
    return await _send(() => http.get(Uri.parse('$_base/api/chat/history/'),
        headers: _headers)) as List<dynamic>;
  }
}
