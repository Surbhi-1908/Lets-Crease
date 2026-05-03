import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/difficulty/difficulty_selection_screen.dart';
import '../../features/main/main_screen.dart';
import '../../features/blog/blog_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/demo_auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final demoAuthState = ref.watch(demoAuthProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null || demoAuthState;
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      
      // If on splash, let it handle the redirect logic
      if (isOnSplash) return null;
      
      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isOnAuth) {
        return '/login';
      }
      
      // If logged in and on auth screens, redirect to main
      if (isLoggedIn && isOnAuth) {
        return '/main';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/difficulty-selection',
        builder: (context, state) => const DifficultySelectionScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/blog',
        builder: (context, state) => const BlogScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
