import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/restaurant_providers.dart';
import 'package:frontend/views/owner/ManageMenus/viewAllRestaurantsforMenus.dart';
import 'package:frontend/views/owner/ManageRestaurants/manageRestaurants.dart';
import 'package:frontend/views/owner/profileScreen.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_snackbar.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  bool _isAcceptingOrders = true; // State for the toggle

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final resState = ref.watch(restaurantProvider);
    final user = authState.currentUser;
    // final List<Restaurant> res = resState.restaurants; // Not used directly, but length is

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.h5.copyWith(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textWhite),
            onPressed: () => _showComingSoon(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      drawer: _buildAppDrawer(context, ref, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Compact Header & Actionable Toggle
            _buildDashboardHeader(user?.name ?? 'Owner'),
            const SizedBox(height: 24),

            /// 2. Key Performance Indicators (KPIs)
            _buildStatsGrid(),
            const SizedBox(height: 24),

            

            /// 4. Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(resState.restaurants.length),
            const SizedBox(height: 24),

            /// 3. Sales Overview Chart (Placeholder)
            _buildSalesChart(),
            const SizedBox(height: 24),

          
          ],
        ),
      ),
    );
  }

  /// --- UI Sections ---

  Widget _buildDashboardHeader(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName 👋',
                style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is your business snapshot.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Accepting Orders',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isAcceptingOrders ? AppColors.success : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Switch(
                value: _isAcceptingOrders,
                onChanged: (value) {
                  setState(() {
                    _isAcceptingOrders = value;
                  });
                  CustomSnackBar.showInfo(context,
                      "Restaurant is now ${_isAcceptingOrders ? 'ONLINE' : 'OFFLINE'}");
                },
                activeTrackColor: AppColors.success.withOpacity(0.5),
                activeColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Today\'s Revenue',
          '₹ 8,520', // Example Data
          Icons.account_balance_wallet,
          AppColors.primary,
        ),
        _buildStatCard(
          'Today\'s Orders',
          '42', // Example Data
          Icons.receipt_long,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Pending Orders',
          '3', // Example Data
          Icons.pending_actions,
          AppColors.warning,
        ),
        _buildStatCard(
          'Avg. Rating',
          '4.5 ★', // Example Data
          Icons.star,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Sales',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 8,
              )
            ],
          ),
          child: const Center(
            child: Text(
              // TODO: Integrate a chart library like 'fl_chart' or 'charts_flutter' here.
              'Sales Chart Placeholder',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(int restaurantCount) {
    return GridView.extent(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: 180,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          'View Orders',
          'Manage incoming orders',
          Icons.receipt_long,
          AppColors.success,
          () => _showComingSoon(context),
        ),
        _buildActionCard(
          context,
          'Manage Menu',
          'Add or edit items',
          Icons.menu_book,
          AppColors.secondary,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageMenusPage()),
          ),
        ),
        _buildActionCard(
          context,
          'My Restaurants',
          '$restaurantCount registered',
          Icons.store,
          AppColors.primary,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageRestaurantsScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Analytics',
          'View performance',
          Icons.analytics,
          AppColors.info,
          () => _showComingSoon(context),
        ),
      ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// --- Snackbars & Logout ---

  void _showComingSoon(BuildContext context) {
    CustomSnackBar.showInfo(
      context,
      'This feature is coming soon! Stay tuned for updates.',
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.logout();
    if (context.mounted) {
      final authState = ref.read(authProvider);
      CustomSnackBar.showSuccess(context, authState.successMessage ?? 'Logged out successfully!');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


Widget _buildAppDrawer(BuildContext context, WidgetRef ref, UserModel? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Restaurant Owner',
                  style: AppTextStyles.h6.copyWith(color: AppColors.textWhite),
                ),
                Text(
                  user?.email ?? 'No email',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primary),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer before navigating
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: const Text('Settings'),
            onTap: () {
              _showComingSoon(context);
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout(context, ref);
            },
          ),
        ],
      ),
    );
  }}