class AppConstants {
  // API Constants
  static const String baseUrl = 'http://192.168.137.32:5000/api';
  static const String authEndpoint = '/auth';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String restaurantEndpoint = '/restaurant';
  static const String menuCategoryEndpoint = '/menucat';
  static const String menuItemEndpoint = '/menuitem';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';
  
  // User Roles
  static const String customerRole = 'CUSTOMER';
  static const String ownerRole = 'OWNER';
  static const String adminRole = 'ADMIN';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String loginFailed = 'Login failed. Please check your credentials.';
  static const String registrationFailed = 'Registration failed. Please try again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String logoutSuccess = 'Logged out successfully!';
  
  // App Info
  static const String appName = 'Restaurant Manager';
  static const String appVersion = '1.0.0';
} 