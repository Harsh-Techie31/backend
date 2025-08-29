
import 'dart:convert';
import 'dart:developer';

import 'package:frontend/models/menuCatefory-model.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';

class Menucategoryapiservice {
  static final Menucategoryapiservice _instance = Menucategoryapiservice._internal();
  factory Menucategoryapiservice() => _instance;
  Menucategoryapiservice._internal();

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
  

  Future<List<MenuCategory>> getMenuCategories({
    required String restaurantId,
  })async{
    try {
    final response = await http.get(
      Uri.parse('$_baseUrl${AppConstants.menuCategoryEndpoint}/restaurant/$restaurantId'),//todo : change
      headers: _headers,
    );

    final body = json.decode(response.body);
    log("got response from getting the menu categories : $body");
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = body["menuCategories"];
      return data.map((e) => MenuCategory.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  } catch (e) {
    throw Exception('Fetching restaurants failed: ${e.toString()}');
  }
  }

 Future<MenuCategory> addMenuCategory({
  required String restaurantID,
  required String name,
  required int pos,
}) async {
  try {
    final requestBody = {
      "restaurantId": restaurantID,
      "name": name,
      "position": pos,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl${AppConstants.menuCategoryEndpoint}/create'),
      headers: _headers,
      body: json.encode(requestBody), // <-- send body as JSON
    );

    final body = json.decode(response.body);
    log("Response from creating menu category: $body");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body["menuCategory"]; // maybe it's singular, adjust if API returns differently
      return MenuCategory.fromJson(data);
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  } catch (e) {
    log("Error adding menu category: $e");
    rethrow;
  }
}


  
  
  
  
  
  
  }