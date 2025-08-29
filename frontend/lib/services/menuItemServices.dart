import 'dart:convert';
import 'dart:developer';
import 'package:frontend/models/menu_item_model.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class MenuItemApiService {
  static final MenuItemApiService _instance = MenuItemApiService._internal();
  factory MenuItemApiService() => _instance;
  MenuItemApiService._internal();

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
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, String> get _multipartHeaders {
    final headers = <String, String>{};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<List<MenuItem>> getMenuItemsByCategory(String categoryId) async {
    log("called");
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.menuItemEndpoint}/category/$categoryId');
      final response = await http.get(uri, headers: _headers);
      final body = json.decode(response.body);
      log("response afterring refreshing :: $body");
      if (response.statusCode == 200) {
        log("point 1");
        final List<dynamic> data = body['menuItems'];
        log("point 2");
        return data.map((itemJson) => MenuItem.fromJson(itemJson)).toList();
        
      } else {
        throw Exception(body['message'] ?? 'Failed to load menu items');
      }
    } catch (e) {
      log('Error fetching menu items by category: $e');
      rethrow;
    }
  }

  Future<MenuItem> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required String restaurantId,
    String? imagePath,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.menuItemEndpoint}/create');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_multipartHeaders);

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['categoryId'] = categoryId;
      request.fields['restaurantId'] = restaurantId;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = json.decode(response.body);

      log("Create Menu Item Response: $body");

      if (response.statusCode == 201) {
        return MenuItem.fromJson1(body['menuItem']);
      } else {
        throw Exception(body['message'] ?? 'Failed to create menu item');
      }
    } catch (e) {
      log('Error creating menu item: $e');
      rethrow;
    }
  }

  Future<MenuItem> updateMenuItem({
    required String id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    bool? isAvailable,
    String? imagePath,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.menuItemEndpoint}/$id');
      final request = http.MultipartRequest('PUT', uri);

      request.headers.addAll(_multipartHeaders);

      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (price != null) request.fields['price'] = price.toString();
      if (categoryId != null) request.fields['categoryId'] = categoryId;
      if (isAvailable != null) request.fields['isAvailable'] = isAvailable.toString();

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = json.decode(response.body);

      log("Update Menu Item Response: $body");

      if (response.statusCode == 200) {
        return MenuItem.fromJson1(body['menuItem']);
      } else {
        throw Exception(body['message'] ?? 'Failed to update menu item');
      }
    } catch (e) {
      log('Error updating menu item: $e');
      rethrow;
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl${AppConstants.menuItemEndpoint}/$id');
      final response = await http.delete(uri, headers: _headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        log(body['message']);
        return true;
      } else {
        throw Exception(body['message'] ?? 'Failed to delete menu item');
      }
    } catch (e) {
      log('Error deleting menu item: $e');
      rethrow;
    }
  }
}