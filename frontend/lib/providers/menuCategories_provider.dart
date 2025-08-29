// lib/providers/menuCategories_provider.dart

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menuCatefory-model.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/providers/storage_provider.dart';
import 'package:frontend/services/menuCategoryApiService.dart';
import 'package:frontend/services/storage_service.dart';

// --- STATE CLASS (No changes needed) ---
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

// --- NOTIFIER CLASS (Updated) ---
class MenuCategoriesNotifier extends StateNotifier<MenuCategoriesState> {
  final Menucategoryapiservice _apiService;
  final StorageService _storageService;

  MenuCategoriesNotifier(this._apiService, this._storageService)
      : super(const MenuCategoriesState());

  Future<void> initialize() async {
    final token = _storageService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> loadCategories(String restaurantId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories =
          await _apiService.getMenuCategories(restaurantId: restaurantId);
      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addCategory(
      {required String catname, required String resID, required int pos}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newCat = await _apiService.addMenuCategory(
          name: catname, restaurantID: resID, pos: pos);
      state = state.copyWith(
        isLoading: false,
        categories: [...state.categories, newCat],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- NEW: UPDATE CATEGORY METHOD ---
  Future<void> updateCategory(
      {required String categoryId, String? name, int? position}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedCategory = await _apiService.updateMenuCategory(
        categoryId: categoryId,
        name: name,
        position: position,
      );
      state = state.copyWith(
        isLoading: false,
        categories: state.categories.map((c) {
          return c.id == categoryId ? updatedCategory : c;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- UPDATED: DELETE CATEGORY METHOD ---
  Future<void> deleteCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.deleteMenuCategory(categoryId: categoryId);
      state = state.copyWith(
        isLoading: false,
        categories: state.categories.where((c) => c.id != categoryId).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// --- PROVIDER (No changes needed) ---
final menuCategoriesProvider =
    StateNotifierProvider.family<MenuCategoriesNotifier, MenuCategoriesState, String>(
  (ref, restaurantId) {
    final apiService = ref.watch(menuCategoryApiServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final notifier = MenuCategoriesNotifier(apiService, storageService);

    notifier.initialize();
    notifier.loadCategories(restaurantId);

    return notifier;
  },
);