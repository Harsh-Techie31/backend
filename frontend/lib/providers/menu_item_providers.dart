import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/menu_item_model.dart';
import 'package:frontend/providers/api_provider.dart';
import 'package:frontend/services/menuItemServices.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/providers/storage_provider.dart';

/// -----------------------------
/// STATE CLASS
/// -----------------------------
class MenuItemsState {
  final bool isLoading;
  final List<MenuItem> items;
  final String? errorMessage;

  const MenuItemsState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  MenuItemsState copyWith({
    bool? isLoading,
    List<MenuItem>? items,
    String? errorMessage,
  }) {
    return MenuItemsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage, // Allow setting errorMessage to null
    );
  }
}

/// -----------------------------
/// NOTIFIER CLASS
/// -----------------------------
class MenuItemsNotifier extends StateNotifier<MenuItemsState> {
  final MenuItemApiService _apiService;
  final StorageService _storageService;

  MenuItemsNotifier(this._apiService, this._storageService)
      : super(const MenuItemsState());

  Future<void> initialize() async {
    final token = _storageService.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> loadItems(String categoryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _apiService.getMenuItemsByCategory(categoryId);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required String restaurantId,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newItem = await _apiService.createMenuItem(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        restaurantId: restaurantId,
        imagePath: imagePath,
      );
      state = state.copyWith(
        isLoading: false,
        items: [...state.items, newItem],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateMenuItem({
    required String id,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedItem = await _apiService.updateMenuItem(
        id: id,
        name: name,
        description: description,
        price: price,
        isAvailable: isAvailable,
        imagePath: imagePath,
      );
      state = state.copyWith(
        isLoading: false,
        items: state.items.map((item) {
          return item.id == id ? updatedItem : item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteMenuItem(String menuItemId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiService.deleteMenuItem(menuItemId);
      state = state.copyWith(
        isLoading: false,
        items: state.items.where((item) => item.id != menuItemId).toList(),
      );
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
final menuItemsProvider =
    StateNotifierProvider.family<MenuItemsNotifier, MenuItemsState, String>(
  (ref, categoryId) {
    final apiService = ref.watch(menuitemApiServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final notifier = MenuItemsNotifier(apiService, storageService);

    notifier.initialize();      // Setup token
    notifier.loadItems(categoryId); // Load initial items for this category

    return notifier;
  },
);