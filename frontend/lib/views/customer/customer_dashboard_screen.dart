import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_snackbar.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to get user information
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Customer Dashboard',
          style: AppTextStyles.h5.copyWith(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome, ${user?.name ?? 'Customer'}!',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Customer features coming soon...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _logout(context, ref),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    
    if (context.mounted) {
      final authState = ref.read(authProvider);
      CustomSnackBar.showSuccess(context, authState.successMessage!);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
} 