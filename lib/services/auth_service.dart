import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  static const String _userCacheKey = 'carded_user_cache';

  Future<AuthResult> register({required String fullName, required String email,
      required String phone, required String password}) async {
    final res = await ApiClient.instance.post('/auth/register',
        {'fullName': fullName, 'email': email, 'phone': phone, 'password': password}, auth: false);
    if (res.success) {
      await ApiClient.instance.saveToken(res.data['token']);
      final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
      await _cacheUser(user);
      return AuthResult(success: true, user: user);
    }
    return AuthResult(success: false, message: res.message ?? 'Registration failed');
  }

  Future<AuthResult> login(String emailOrPhone, String password) async {
    final res = await ApiClient.instance.post('/auth/login',
        {'emailOrPhone': emailOrPhone, 'password': password}, auth: false);
    if (res.success) {
      await ApiClient.instance.saveToken(res.data['token']);
      final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
      await _cacheUser(user);
      return AuthResult(success: true, user: user);
    }
    return AuthResult(success: false, message: res.message ?? 'Invalid credentials');
  }

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await ApiClient.instance.getToken();
    return token != null && token.isNotEmpty;
  }

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
    } catch (_) { return null; }
  }

  Future<void> _cacheUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user.toJson()));
  }

  Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    final res = await ApiClient.instance.put('/auth/password',
        {'currentPassword': currentPassword, 'newPassword': newPassword});
    if (res.success) return AuthResult(success: true);
    return AuthResult(success: false, message: res.message ?? 'Failed to change password');
  }

  // ─── Reset Password — Step 1: Email bhejo ─────────────────
  Future<AuthResult> forgotPassword(String email) async {
    final res = await ApiClient.instance.post('/auth/forgot-password',
        {'email': email}, auth: false);
    if (res.success) return AuthResult(success: true);
    return AuthResult(success: false, message: res.message ?? 'Failed to send code');
  }

  // ─── Reset Password — Step 2: OTP verify karo ─────────────
  Future<AuthResult> verifyOtp(String email, String otp) async {
    final res = await ApiClient.instance.post('/auth/verify-otp',
        {'email': email, 'otp': otp}, auth: false);
    if (res.success) {
      return AuthResult(success: true, resetToken: res.data['resetToken'] as String?);
    }
    return AuthResult(success: false, message: res.message ?? 'Invalid code');
  }

  // ─── Reset Password — Step 3: Naya password set karo ──────
  Future<AuthResult> resetPassword(String resetToken, String newPassword) async {
    final res = await ApiClient.instance.post('/auth/reset-password',
        {'resetToken': resetToken, 'newPassword': newPassword}, auth: false);
    if (res.success) return AuthResult(success: true);
    return AuthResult(success: false, message: res.message ?? 'Failed to reset password');
  }
}

class AuthResult {
  final bool success;
  final AppUser? user;
  final String? message;
  final String? resetToken;
  AuthResult({required this.success, this.user, this.message, this.resetToken});
}