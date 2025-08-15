import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'api_provider.dart';
import 'storage_provider.dart';

// Auth State - represents the current authentication state
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserModel? currentUser;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.currentUser,
    this.errorMessage,
    this.successMessage,
  });

  // Create a copy of the state with updated values
  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserModel? currentUser,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

// Auth Notifier - manages authentication state and business logic
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(const AuthState());

  // Initialize auth state (check if user is already logged in)
  Future<void> initialize() async {
    await _storageService.init();
    await _checkAuthState();
  }

  // Check if user is already logged in
  Future<void> _checkAuthState() async {
    final token = _storageService.getToken();
    final user = _storageService.getUser();

    if (token != null && user != null) {
      _apiService.setAuthToken(token);
      state = state.copyWith(
        currentUser: user,
        isLoggedIn: true,
      );
    }
  }

  // Register user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      // Save user data and token
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      await _storageService.saveUserRole(response.user.role);

      // Update state
      _apiService.setAuthToken(response.token);
      state = state.copyWith(
        currentUser: response.user,
        isLoggedIn: true,
        successMessage: AppConstants.registrationSuccess,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      // Save user data and token
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      await _storageService.saveUserRole(response.user.role);

      // Update state
      _apiService.setAuthToken(response.token);
      state = state.copyWith(
        currentUser: response.user,
        isLoggedIn: true,
        successMessage: AppConstants.loginSuccess,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    }

    // Clear local data
    await _storageService.clearAll();
    _apiService.clearAuthToken();

    // Update state
    state = state.copyWith(
      currentUser: null,
      isLoggedIn: false,
      successMessage: AppConstants.logoutSuccess,
      isLoading: false,
    );
  }

  // Get user profile
  Future<void> getProfile() async {
    if (!state.isLoggedIn) return;

    try {
      final user = await _apiService.getProfile();
      await _storageService.saveUser(user);
      state = state.copyWith(currentUser: user);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (!state.isLoggedIn) return false;

    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      final user = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      await _storageService.saveUser(user);
      state = state.copyWith(
        currentUser: user,
        successMessage: 'Profile updated successfully!',
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
      return false;
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  // Check if user is restaurant owner
  bool get isRestaurantOwner {
    return state.currentUser?.role == AppConstants.ownerRole;
  }

  // Check if user is admin
  bool get isAdmin {
    return state.currentUser?.role == AppConstants.adminRole;
  }

  // Check if user is customer
  bool get isCustomer {
    return state.currentUser?.role == AppConstants.customerRole;
  }
}

// Auth Provider - main provider for authentication
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  final notifier = AuthNotifier(apiService, storageService);
  notifier.initialize();
  
  return notifier;
}); 