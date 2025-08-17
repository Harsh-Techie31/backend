import 'dart:convert';

import 'package:frontend/models/restaurant_model.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class RestaurantApiService {
  static final RestaurantApiService _instance = RestaurantApiService._internal();
  factory RestaurantApiService() => _instance;
  RestaurantApiService._internal();

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


  Future<List<Restaurant>> getRestaurantsByOwner() async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.restaurantEndpoint}/owner/my-restaurants'),
      headers: _headers,
    );

    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = body["restaurants"];
      return data.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  } catch (e) {
    throw Exception('Fetching restaurants failed: ${e.toString()}');
  }
}









}