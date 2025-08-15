import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import 'register_screen.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Get the auth notifier from Riverpod
    final authNotifier = ref.read(authProvider.notifier);
    
    final success = await authNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Get the current state to show success message
      final authState = ref.read(authProvider);
      CustomSnackBar.showSuccess(context, authState.successMessage!);
      
      // Navigate to appropriate screen based on user role
      _navigateBasedOnRole(authState.currentUser!.role);
    } else if (mounted) {
      // Get the current state to show error message
      final authState = ref.read(authProvider);
      CustomSnackBar.showError(context, authState.errorMessage!);
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case AppConstants.ownerRole:
        // Navigate to restaurant owner dashboard
        Navigator.pushReplacementNamed(context, '/owner-dashboard');
        break;
      case AppConstants.adminRole:
        // Navigate to admin dashboard
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case AppConstants.customerRole:
        // Navigate to customer dashboard
        Navigator.pushReplacementNamed(context, '/customer-dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state to get loading status
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // App Logo/Title
                Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppConstants.emailInvalid;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppConstants.passwordMinLength;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: authState.isLoading ? null : _login,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Role Selection Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your role during registration',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Customer: Browse and order from restaurants\n• Owner: Manage your restaurant\n• Admin: System administration',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 