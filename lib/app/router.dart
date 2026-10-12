import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/screens/confirm_order_screen.dart';
import '../features/recipes/presentation/screens/food_detail_screen.dart';
import '../features/recipes/presentation/screens/home_screen.dart';
import '../features/recipes/presentation/screens/menu_screen.dart';
import '../features/recipes/presentation/screens/search_filter_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final status = authState.status;
      final isLoggingIn = state.matchedLocation == '/login';

      if (status == AuthStatus.initial) {
        // While determining session, stay or wait
        return null;
      }

      final isAuthenticated = status == AuthStatus.authenticated;

      // If not logged in and attempting to access protected screens, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If logged in and trying to access login, redirect to home
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchFilterScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '1';
          final id = int.tryParse(idStr) ?? 1;
          return FoodDetailScreen(recipeId: id);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/confirm_order',
        builder: (context, state) => const ConfirmOrderScreen(),
      ),
    ],
  );
});
