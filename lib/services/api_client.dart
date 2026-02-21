import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // 🔧 Change this to your Render URL after deploying
  // static const String baseUrl = 'https://carded-api.onrender.com';
  // For local dev: static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator
  // static const String baseUrl = 'https://carded-backend.onrender.com';
  static const String baseUrl = 'https://carded-backend.vercel.app';
  static const String _tokenKey = 'carded_auth_token';


  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();
  ApiClient._();

  // ─── Token management ─────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─── Headers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── HTTP helpers ─────────────────────────────────────────────────────────

  Future<ApiResponse> get(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      return ApiResponse.from(res);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return ApiResponse.from(res);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return ApiResponse.from(res);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 15));
      return ApiResponse.from(res);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
}

// ─── Response wrapper ─────────────────────────────────────────────────────────

class ApiResponse {
  final bool success;
  final int statusCode;
  final Map<String, dynamic> data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.data,
    this.message,
  });

  factory ApiResponse.from(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ApiResponse(
      success: res.statusCode >= 200 && res.statusCode < 300 && (body['success'] == true),
      statusCode: res.statusCode,
      data: body,
      message: body['message'] as String?,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      statusCode: 0,
      data: {},
      message: message,
    );
  }
}
