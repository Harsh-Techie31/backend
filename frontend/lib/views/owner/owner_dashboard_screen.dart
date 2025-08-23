import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/restaurant_model.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:frontend/views/owner/manageRestaurants.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_snackbar.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final resState = ref.watch(restaurantProvider);
    final user = authState.currentUser;
    final List<Restaurant> res = resState.restaurants;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Restaurant Owner Dashboard',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.textWhite,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.name ?? 'Restaurant Owner',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textWhite.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            GridView.extent(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              //crossAxisCount: 2,
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
              children: [
                _buildActionCard(
                  context,
                  'Manage Restaurant',
                  'Add or edit restaurant details',
                  Icons.store,
                  AppColors.primary,
                  () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageRestaurantsScreen(),
              ),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Menu Management',
                  'Manage your menu items',
                  Icons.menu_book,
                  AppColors.secondary,
                  () => _showComingSoon(context),
                ),
                _buildActionCard(
                  context,
                  'Orders',
                  'Track and manage orders',
                  Icons.receipt_long,
                  AppColors.success,
                  () => _showComingSoon(context),
                ),
                _buildActionCard(
                  context,
                  'Analytics',
                  'Track performance',
                  Icons.analytics,
                  AppColors.info,
                  () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// Account Info
            Text(
              'Account Information',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
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
                  _buildInfoTile(Icons.store_mall_directory, 'Restaurants', res.length.toString()),
                  _buildDivider(),
                  _buildInfoTile(Icons.email, 'Email', user?.email ?? 'N/A'),
                  _buildDivider(),
                  _buildInfoTile(Icons.phone, 'Phone', user?.phone ?? 'Not provided'),
                  _buildDivider(),
                  _buildInfoTile(Icons.verified_user, 'Role', user?.role ?? 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- UI Helpers ---

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

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
      subtitle: Text(value, style: AppTextStyles.bodyMedium),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() => Divider(
        height: 1,
        thickness: 0.6,
        color: AppColors.border.withOpacity(0.6),
        indent: 20,
        endIndent: 20,
      );

  /// --- Snackbars & Logout ---

  void _showComingSoon(BuildContext context) {
    CustomSnackBar.showInfo(
      context,
      'This feature is coming soon! Stay tuned for updates.',
    );
  }

  void _showComingSoon1(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    CustomSnackBar.showInfo(
      context,
      'This feature is coming soon! Stay tuned for updates.',
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    log("reached here");
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    log("reached here1");
    if (context.mounted) {
      final authState = ref.read(authProvider);
      CustomSnackBar.showSuccess(context, authState.successMessage!);
      Navigator.pushReplacementNamed(context, '/login');
    }
    log("reached here2");
  }
}
