// lib/services/menuCategoryApiService.dart

import 'dart:convert';
import 'dart:developer';

import 'package:frontend/models/menuCatefory-model.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';

class Menucategoryapiservice {
  static final Menucategoryapiservice _instance =
      Menucategoryapiservice._internal();
  factory Menucategoryapiservice() => _instance;
  Menucategoryapiservice._internal();

  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

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
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl${AppConstants.menuCategoryEndpoint}/restaurant/$restaurantId'),
        headers: _headers,
      );
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = body["menuCategories"];
        return data.map((e) => MenuCategory.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'An error occurred');
      }
    } catch (e) {
      throw Exception('Fetching categories failed: ${e.toString()}');
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
        body: json.encode(requestBody),
      );
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return MenuCategory.fromJson(body["menuCategory"]);
      } else {
        throw Exception(body['message'] ?? 'An error occurred');
      }
    } catch (e) {
      log("Error adding menu category: $e");
      rethrow;
    }
  }

  // --- NEW: UPDATE METHOD ---
  Future<MenuCategory> updateMenuCategory({
    required String categoryId,
    String? name,
    int? position,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (name != null) requestBody['name'] = name;
      if (position != null) requestBody['position'] = position;

      final response = await http.put(
        Uri.parse('$_baseUrl${AppConstants.menuCategoryEndpoint}/$categoryId'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final body = json.decode(response.body);
      log("Response from updating menu category: $body");

      if (response.statusCode == 200) {
        return MenuCategory.fromJson(body["menuCategory"]);
      } else {
        throw Exception(body['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      log("Error updating menu category: $e");
      rethrow;
    }
  }

  // --- NEW: DELETE METHOD ---
  Future<void> deleteMenuCategory({required String categoryId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl${AppConstants.menuCategoryEndpoint}/$categoryId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete category');
      }
      // No need to return anything on successful deletion
    } catch (e) {
      log("Error deleting menu category: $e");
      rethrow;
    }
  }


  Future<void> updateCategoryPositions(
      List<Map<String, dynamic>> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${AppConstants.menuCategoryEndpoint}/reorder'),
        headers: _headers,
        body: json.encode({'updates': updates}),
      );

      if (response.statusCode != 200) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Failed to reorder categories');
      }
    } catch (e) {
      log("Error reordering categories: $e");
      rethrow;
    }
  }
}