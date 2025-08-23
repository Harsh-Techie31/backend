import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/providers/storage_provider.dart';
import 'package:frontend/services/restaurant_api_service.dart';
import 'package:frontend/services/storage_service.dart';

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
  final StorageService _storageService;


  RestaurantNotifier(this._resApiService , this._storageService) : super(const RestaurantState());
   Future<void> initialize() async {
    final token = _storageService.getToken();
    log("[log] token ${token }");
    _resApiService.setAuthToken(token!);
    await getOwnerRestaurants();
  }

  Future<void> getOwnerRestaurants() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final restaurantss = await _resApiService.getRestaurantsByOwner();
      state = state.copyWith(restaurants: restaurantss,isLoading: false);
      
    } catch (e) {
      state = state.copyWith(isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  //View-model calls to the api to add new restaurant
  Future<void> addRestaurant({
    required String name,
    required String description,
    required String address,
    required double lat,
    required double lng,
    required List<File> images,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call your API function
      final newRestaurant = await _resApiService.addNewRestaurant(
        name: name,
        description: description,
        address: address,
        lat: lat,
        lng: lng,
        images: images,
      );

      // Optimistically update the list
      final updatedList = List<Restaurant>.from(state.restaurants)..add(newRestaurant);
      state = state.copyWith(restaurants: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }


  Future<void> editRestaurant({
  required String id,
  String? name,
  String? description,
  String? address,
  double? lat,
  double? lng,
  List<File>? images,
}) async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    final updatedRestaurant = await _resApiService.updateRestaurant(
      id: id,
      name: name,
      description: description,
      address: address,
      lat: lat,
      lng: lng,
      images: images,
    );

    // Update the local list
    final updatedList = state.restaurants.map((res) {
      return res.id == id ? updatedRestaurant : res;
    }).toList();

    state = state.copyWith(restaurants: updatedList, isLoading: false);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: e.toString().replaceAll('Exception: ', ''),
    );
  }
}





}



final restaurantProvider  = StateNotifierProvider<RestaurantNotifier, RestaurantState>((ref) {
  final apiService = ref.watch(restaurantApiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  final notifier = RestaurantNotifier(apiService,storageService);
  notifier.initialize();
  
  
  return notifier;
}); 
