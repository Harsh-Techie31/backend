import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/providers/providers.dart';
import 'package:frontend/providers/restaurant_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user and restaurant data from providers
    final authState = ref.watch(authProvider);
    final resState = ref.watch(restaurantProvider);
    final user = authState.currentUser;
    final restaurantCount = resState.restaurants.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.h5),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            /// This is the Account Information section from your original code,
            /// now repurposed for the profile screen.
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile(Icons.person, 'Name', user?.name ?? 'N/A'),
                  _buildDivider(),
                  _buildInfoTile(Icons.email, 'Email', user?.email ?? 'N/A'),
                  _buildDivider(),
                  _buildInfoTile(Icons.phone, 'Phone', user?.phone ?? 'Not provided'),
                  _buildDivider(),
                  _buildInfoTile(Icons.verified_user, 'Role', user?.role ?? 'N/A'),
                   _buildDivider(),
                  _buildInfoTile(Icons.store_mall_directory, 'Restaurants', restaurantCount.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Helper widgets for this screen
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(value, style: AppTextStyles.bodyLarge), // Made value text larger
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildDivider() => Divider(
        height: 1,
        thickness: 0.6,
        color: AppColors.border.withOpacity(0.6),
        indent: 20,
        endIndent: 20,
      );
}