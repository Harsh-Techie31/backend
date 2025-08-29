import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menuCatefory-model.dart';

import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/providers/storage_provider.dart';
import 'package:frontend/services/menuCategoryApiService.dart';
import 'package:frontend/services/storage_service.dart';

/// -----------------------------
/// STATE CLASS
/// -----------------------------
class MenuCategoriesState {
  final bool isLoading;
  final List<MenuCategory> categories;
  final String? errorMessage;

  const MenuCategoriesState({
    this.isLoading = false,
    this.categories = const [],
    this.errorMessage,
  });

  MenuCategoriesState copyWith({
    bool? isLoading,
    List<MenuCategory>? categories,
    String? errorMessage,
  }) {
    return MenuCategoriesState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

/// -----------------------------
/// NOTIFIER CLASS
/// -----------------------------
class MenuCategoriesNotifier extends StateNotifier<MenuCategoriesState> {
  final Menucategoryapiservice  _apiService;
  final StorageService _storageService;

  MenuCategoriesNotifier(this._apiService, this._storageService)
      : super(const MenuCategoriesState());

  Future<void> initialize() async {
    final token = _storageService.getToken();
    log("[log] menu token: $token");
    _apiService.setAuthToken(token!);
  }

  Future<void> loadCategories(String restaurantId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories =
          await _apiService.getMenuCategories(restaurantId: restaurantId);
      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addCategory({
    required String catname,
    required String resID,
    required int pos

  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newCat = await _apiService.addMenuCategory(name: catname,restaurantID:resID,pos:pos);
      log("finished calling the api call from provider for adding a new category this is the resposne : $newCat");
      state = state.copyWith(
        isLoading: false,
        categories: [...state.categories, newCat],
      );
      //state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      // await _apiService.deleteMenuCategory(categoryId);
      // state = state.copyWith(
      //   isLoading: false,
      //   categories: state.categories.where((c) => c.id != categoryId).toList(),
      // );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// -----------------------------
/// PROVIDER
/// -----------------------------
// final menuCategoriesProvider =
//     StateNotifierProvider<MenuCategoriesNotifier, MenuCategoriesState>((ref) {
//   final apiService = ref.watch(menuCategoryApiServiceProvider);
//   final storageService = ref.watch(storageServiceProvider);

//   final notifier = MenuCategoriesNotifier(apiService, storageService);
//   notifier.initialize();
//   return notifier;
// });

final menuCategoriesProvider = 
    StateNotifierProvider.family<MenuCategoriesNotifier, MenuCategoriesState, String>(
  (ref, restaurantId) {
    final apiService = ref.watch(menuCategoryApiServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final notifier = MenuCategoriesNotifier(apiService, storageService);

    notifier.initialize();        // setup token
    notifier.loadCategories(restaurantId); // load categories for this restaurant

    return notifier;
  },
);
