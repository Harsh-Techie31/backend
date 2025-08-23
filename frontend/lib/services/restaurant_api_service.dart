import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:frontend/models/restaurant_model.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

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
    log("called here to get my res");
    log(body.toString());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = body["restaurants"];
      return data.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  } catch (e) {
    throw Exception('Fetching restaurants failed: ${e.toString()}');
  }}




  Future<Restaurant> addNewRestaurant({
    required String name,
    required String description,
    required String address,
    required double lat,
    required double lng,
    required List<File> images,
  }) async {
    if (_authToken == null) throw Exception("Auth token not set");

    final uri = Uri.parse('$_baseUrl${AppConstants.restaurantEndpoint}/create');
    log("[log] URL : $uri");
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_authToken'
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['address'] = address
      ..fields['lat'] = lat.toString()
      ..fields['lng'] = lng.toString();

    // Attach images
    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'images', // key as expected by backend
        stream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      log("RAW RESPONSE: $respStr");
      final body = json.decode(respStr);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Restaurant.fromJson(body['restaurant']);
      } else {
        throw Exception(body['message'] ?? 'Failed to create restaurant');
      }
    } catch (e) {
      throw Exception('Add restaurant failed: $e');
    }
  }

Future<Restaurant> updateRestaurant({
  required String id,
  String? name,
  String? description,
  String? address,
  double? lat,
  double? lng,
  List<File>? images,
}) async {
  if (_authToken == null) throw Exception("Auth token not set");

  final uri = Uri.parse('$_baseUrl${AppConstants.restaurantEndpoint}/$id');

  var request = http.MultipartRequest('PUT', uri)
    ..headers['Authorization'] = 'Bearer $_authToken';

  // Only add fields if they are non-null
  if (name != null) request.fields['name'] = name;
  if (description != null) request.fields['description'] = description;
  if (address != null) request.fields['address'] = address;
  if (lat != null) request.fields['lat'] = lat.toString();
  if (lng != null) request.fields['lng'] = lng.toString();

  // Attach images if provided
  if (images != null) {
    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: image.path.split('/').last,
      );
      request.files.add(multipartFile);
    }
  }

  final response = await request.send();
  final respStr = await response.stream.bytesToString();
  final body = json.decode(respStr);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return Restaurant.fromJson(body['restaurant']);
  } else {
    throw Exception(body['message'] ?? 'Failed to update restaurant');
  }
}


Future<void> deleteRestaurant(
    {required String id,}
)async{
  if (_authToken == null) throw Exception("Auth token not set");
  try{
    final uri = Uri.parse('$_baseUrl${AppConstants.restaurantEndpoint}/$id');
  final  response = await http.delete(uri , headers: _headers);
  final body = json.decode(response.body);
  log("res from deletion api is $body");
  if (response.statusCode >= 200 && response.statusCode < 300) {
      //final List<dynamic> data = body["restaurants"];
      return;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }catch(e){
     throw Exception('Fetching restaurants failed: ${e.toString()}');
  }
  

}





  



}