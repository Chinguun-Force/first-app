import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/users/presentation/admin_dashboard.dart';
import '../../presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
    redirect: (context, state) {
      if (userProfileAsync.isLoading) return null;

      final isAuthenticated = authState != null;
      final user = userProfileAsync.value;
      final isLoggingIn = state.uri.toString() == '/login';
      final isAdminRoute = state.uri.toString().startsWith('/admin');

      if (!isAuthenticated) return isLoggingIn ? null : '/login';

      if (user != null && !user.isActive) {
        // Force logout if account deactivated
        ref.read(authRepositoryProvider).signOut(ref);
        return '/login';
      }

      if (isLoggingIn) return '/';

      if (isAdminRoute && user != null && !user.isAdmin) {
        return '/';
      }

      return null;
    },
  );
});
