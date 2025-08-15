import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // State variables
  bool _isLoading = false;
  bool _isLoggedIn = false;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Initialize auth state
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
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
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
    _setLoading(true);
    _clearMessages();

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
      _currentUser = response.user;
      _isLoggedIn = true;
      _successMessage = AppConstants.registrationSuccess;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearMessages();

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
      _currentUser = response.user;
      _isLoggedIn = true;
      _successMessage = AppConstants.loginSuccess;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: $e');
    }

    // Clear local data
    await _storageService.clearAll();
    _apiService.clearAuthToken();

    // Update state
    _currentUser = null;
    _isLoggedIn = false;
    _successMessage = AppConstants.logoutSuccess;

    notifyListeners();
    _setLoading(false);
  }

  // Get user profile
  Future<void> getProfile() async {
    if (!_isLoggedIn) return;

    try {
      final user = await _apiService.getProfile();
      _currentUser = user;
      await _storageService.saveUser(user);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (!_isLoggedIn) return false;

    _setLoading(true);
    _clearMessages();

    try {
      final user = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      _currentUser = user;
      await _storageService.saveUser(user);
      _successMessage = 'Profile updated successfully!';

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Clear all messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Check if user is restaurant owner
  bool get isRestaurantOwner {
    return _currentUser?.role == AppConstants.ownerRole;
  }

  // Check if user is admin
  bool get isAdmin {
    return _currentUser?.role == AppConstants.adminRole;
  }

  // Check if user is customer
  bool get isCustomer {
    return _currentUser?.role == AppConstants.customerRole;
  }
} 