import 'dart:convert';
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
  static const _userKey = 'username';
  static const _avatarKey = 'avatar_b64';
  static const _avatarColorKey = 'avatar_color';
  static const _baseUrlKey = 'api_base_url';
  String? _token;
  String? _username;
  String _avatarB64 = '';
  String _avatarColor = '#20A57A';
  String? _baseOverride;

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
    } catch (_) {
      _token = null; // keystore hiccup → treat as logged out
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

  Future<void> _setToken(String? token) async {
    _token = token;
    if (token == null) {
      await _secure.delete(key: _tokenKey);
    } else {
      await _secure.write(key: _tokenKey, value: token);
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
    await _setToken(data['access'] as String);
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
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
    final r = await http.post(Uri.parse('$_base/api/predict/'),
        headers: _headers, body: jsonEncode(answers));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<List<dynamic>> history() async {
    final r =
        await http.get(Uri.parse('$_base/api/history/'), headers: _headers);
    return _decode(r) as List<dynamic>;
  }

  /// Live model card: architecture (introspected from the trained network) +
  /// real training metrics. Powers the "Under the Hood" transparency screen.
  Future<Map<String, dynamic>> modelCard() async {
    final r = await http.get(Uri.parse('$_base/api/model/card/'),
        headers: _headers);
    return _decode(r) as Map<String, dynamic>;
  }

  // -- Profile ------------------------------------------------------------
  Future<Map<String, dynamic>> getProfile() async {
    final r = await http.get(Uri.parse('$_base/api/profile/'), headers: _headers);
    final profile = _decode(r) as Map<String, dynamic>;
    _cacheAvatarFrom(profile);
    return profile;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final r = await http.patch(Uri.parse('$_base/api/profile/'),
        headers: _headers, body: jsonEncode(data));
    final profile = _decode(r) as Map<String, dynamic>;
    _cacheAvatarFrom(profile);
    return profile;
  }

  // -- Chat ---------------------------------------------------------------
  Future<Map<String, dynamic>> sendChat(String message) async {
    final r = await http.post(Uri.parse('$_base/api/chat/'),
        headers: _headers, body: jsonEncode({'message': message}));
    return _decode(r) as Map<String, dynamic>;
  }

  Future<List<dynamic>> chatHistory() async {
    final r = await http.get(Uri.parse('$_base/api/chat/history/'),
        headers: _headers);
    return _decode(r) as List<dynamic>;
  }
}
