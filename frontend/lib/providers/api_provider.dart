import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Provider for API Service
// This creates a singleton instance of ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
}); 