import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/owner/owner_dashboard_screen.dart';
import 'views/customer/customer_dashboard_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          titleTextStyle: AppTextStyles.h5.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.textWhite,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputFocusBorder, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: AppTextStyles.inputHint,
          labelStyle: AppTextStyles.inputLabel,
          errorStyle: AppTextStyles.error,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.h1,
          displayMedium: AppTextStyles.h2,
          displaySmall: AppTextStyles.h3,
          headlineMedium: AppTextStyles.h4,
          headlineSmall: AppTextStyles.h5,
          titleLarge: AppTextStyles.h6,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            );
          case '/owner-dashboard':
            return MaterialPageRoute(
              builder: (context) => const OwnerDashboardScreen(),
            );
          case '/customer-dashboard':
            return MaterialPageRoute(
              builder: (context) => const CustomerDashboardScreen(),
            );
          case '/admin-dashboard':
            return MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const AuthWrapper(),
            );
        }
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state from Riverpod
    final authState = ref.watch(authProvider);
    
    // Show loading screen while checking auth state
    if (authState.isLoading) {
      return const SplashScreen();
    }
    
    // If user is logged in, navigate to appropriate dashboard
    if (authState.isLoggedIn) {
      final user = authState.currentUser;
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (user.role) {
            case AppConstants.ownerRole:
              Navigator.pushReplacementNamed(context, '/owner-dashboard');
              break;
            case AppConstants.adminRole:
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
              break;
            case AppConstants.customerRole:
              Navigator.pushReplacementNamed(context, '/customer-dashboard');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    }
    
    // Show login screen if not logged in
    return const LoginScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 100,
              color: AppColors.textWhite,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textWhite.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
