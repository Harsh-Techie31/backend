import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// Provider for Storage Service
// This creates a singleton instance of StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
}); 