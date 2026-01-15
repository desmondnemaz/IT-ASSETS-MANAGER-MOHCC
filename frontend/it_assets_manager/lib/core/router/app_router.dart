import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_completion_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/admin/presentation/user_management_screen.dart';

import '../../features/auth/providers/auth_provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/', // Start at home, redirect will handle login
    refreshListenable: authProvider, // key: Listen to auth changes
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/profile-complete',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // 1. If not logged in and not on login/register page -> Redirect to Login
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // 2. If logged in...
      if (isLoggedIn) {
        // ...and still on login/register page -> Redirect to Home
        if (isLoggingIn || isRegistering) {
          // check profile status
          if (authProvider.user?.profileComplete == false) {
            return '/profile-complete';
          }
          return '/';
        }

        // ...check profile completion if trying to go elsewhere
        if (authProvider.user?.profileComplete == false &&
            state.uri.toString() != '/profile-complete') {
          return '/profile-complete';
        }
      }

      return null; // No redirect
    },
  );
}
