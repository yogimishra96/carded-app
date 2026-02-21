import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  static const String _userCacheKey = 'carded_user_cache';

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await ApiClient.instance.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    }, auth: false);

    if (res.success) {
      await ApiClient.instance.saveToken(res.data['token']);
      final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
      await _cacheUser(user);
      return AuthResult(success: true, user: user);
    }
    return AuthResult(success: false, message: res.message ?? 'Registration failed');
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String emailOrPhone, String password) async {
    final res = await ApiClient.instance.post('/auth/login', {
      'emailOrPhone': emailOrPhone,
      'password': password,
    }, auth: false);

    if (res.success) {
      await ApiClient.instance.saveToken(res.data['token']);
      final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
      await _cacheUser(user);
      return AuthResult(success: true, user: user);
    }
    return AuthResult(success: false, message: res.message ?? 'Invalid credentials');
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }

  // ─── Is logged in ─────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final token = await ApiClient.instance.getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── Get user (cache-first, then API) ────────────────────────────────────

  Future<AppUser?> getUser() async {
    final cached = await _getCachedUser();
    if (cached != null) return cached;
    return _fetchUserFromApi();
  }

  Future<AppUser?> _fetchUserFromApi() async {
    final res = await ApiClient.instance.get('/auth/me');
    if (res.success) {
      final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
      await _cacheUser(user);
      return user;
    }
    return null;
  }

  Future<AppUser?> _getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userCacheKey);
      if (raw == null) return null;
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user.toJson()));
  }

  // ─── Change password ──────────────────────────────────────────────────────

  Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    final res = await ApiClient.instance.put('/auth/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (res.success) return AuthResult(success: true);
    return AuthResult(success: false, message: res.message ?? 'Failed to change password');
  }

  // ─── Forgot password ──────────────────────────────────────────────────────

  Future<bool> forgotPassword(String emailOrPhone) async {
    final res = await ApiClient.instance.post('/auth/forgot-password', {
      'emailOrPhone': emailOrPhone,
    }, auth: false);
    return res.success;
  }
}

class AuthResult {
  final bool success;
  final AppUser? user;
  final String? message;
  AuthResult({required this.success, this.user, this.message});
}
