import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }

  // Register user
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${AppConstants.authEndpoint}${AppConstants.registerEndpoint}'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (phone != null) 'phone': phone,
        }),
      );

      final data = _handleResponse(response);
      return AuthResponseModel.fromJson(data);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${AppConstants.authEndpoint}${AppConstants.loginEndpoint}'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = _handleResponse(response);
      return AuthResponseModel.fromJson(data);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl${AppConstants.authEndpoint}/logout'),
        headers: _headers,
      );
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConstants.authEndpoint}/profile'),
        headers: _headers,
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${AppConstants.authEndpoint}/profile'),
        headers: _headers,
        body: json.encode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        }),
      );

      final data = _handleResponse(response);
      return UserModel.fromJson(data['user']);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
} 