import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  // Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token operations
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
  }

  UserModel? getUser() {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  // User role operations
  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.userRoleKey, role);
  }

  String? getUserRole() {
    return _prefs.getString(AppConstants.userRoleKey);
  }

  Future<void> removeUserRole() async {
    await _prefs.remove(AppConstants.userRoleKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null && getUser() != null;
  }

  // Get user ID
  String? getUserId() {
    final user = getUser();
    return user?.id;
  }

  // Get user email
  String? getUserEmail() {
    final user = getUser();
    return user?.email;
  }

  // Get user name
  String? getUserName() {
    final user = getUser();
    return user?.name;
  }
} 