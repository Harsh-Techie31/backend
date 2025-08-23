
import '../core/constants/app_constants.dart';

class Menucategoryapiservice {
  static final Menucategoryapiservice _instance = Menucategoryapiservice._internal();
  factory Menucategoryapiservice() => _instance;
  Menucategoryapiservice._internal();

  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  
  
  
  
  
  
  }