import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/users/presentation/admin_dashboard.dart';

// Simple Home Screen for non-admins
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: userAsync.when(
          data: (user) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, ${user?.displayName ?? 'User'}!'),
              if (user?.isAdmin == true)
                ElevatedButton(
                  onPressed: () => context.go('/admin'),
                  child: const Text('Go to Admin Panel'),
                ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('Error: $e'),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
    redirect: (context, state) {
      final isLoading = authState.isLoading || userProfileAsync.isLoading;
      if (isLoading) return null; // Let it load

      final isAuthenticated = authState.value != null;
      final user = userProfileAsync.value;
      final isLoggingIn = state.uri.toString() == '/login';
      final isAdminRoute = state.uri.toString().startsWith('/admin');

      // 1. Not logged in -> Redirect to Login
      if (!isAuthenticated) return isLoggingIn ? null : '/login';

      // 2. Logged in but inactive -> Force Logout or Block (Simple: Redirect to Login)
      if (user != null && !user.isActive) {
        // ideally show a blocked screen, for now just logout
        ref.read(authRepositoryProvider).signOut();
        return '/login';
      }

      // 3. Logged in and trying to login -> Redirect to Home
      if (isLoggingIn) return '/';

      // 4. Admin Guard
      if (isAdminRoute) {
        if (user != null && !user.isAdmin) {
          return '/'; // Kick back to home if not admin
        }
      }

      return null;
    },
  );
});
