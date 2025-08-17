import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/services/restaurant_api_service.dart';

class RestaurantState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final String? errorMessage;

  const RestaurantState({
    this.isLoading = false,
    this.restaurants = const [],
    this.errorMessage,
  });

  RestaurantState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    String? errorMessage,
  }) {
    return RestaurantState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RestaurantNotifier extends StateNotifier<RestaurantState> {
  final RestaurantApiService _resApiService;


  RestaurantNotifier(this._resApiService) : super(const RestaurantState());
   Future<void> initialize() async {
    await getOwnerRestaurants();
  }

  Future<void> getOwnerRestaurants() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final restaurantss = await _resApiService.getRestaurantsByOwner();
      state = state.copyWith(restaurants: restaurantss);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }



}


final restaurantProvider  = StateNotifierProvider<RestaurantNotifier, RestaurantState>((ref) {
  final apiService = ref.watch(restaurantApiServiceProvider);
  
  final notifier = RestaurantNotifier(apiService);
  notifier.initialize();
  
  
  return notifier;
}); 
