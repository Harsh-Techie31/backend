import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/menuCategoryApiService.dart';
import 'package:frontend/services/restaurant_api_service.dart';
import '../services/api_service.dart';

// Provider for API Service
// This creates a singleton instance of ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
}); 

final restaurantApiServiceProvider = Provider<RestaurantApiService>((ref) {
  return RestaurantApiService();
});

final menuCategoryApiServiceProvider = Provider<Menucategoryapiservice>((ref) {
  return Menucategoryapiservice();
});
