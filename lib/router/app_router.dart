import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_test/repositories/auth/auth_repository_impl.dart';
import 'package:socket_test/router/go_router_refresh_stream.dart';
import 'package:socket_test/screens/home_screen.dart';
import 'package:socket_test/screens/login_screen.dart';
import 'package:socket_test/screens/register_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoutes {
  home,
  login,
  register,
  settings,
  profile,
  editPhoto,
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return goRouter(ref);
});

GoRouter goRouter(ProviderRef ref) {
  final auth = ref.watch(authRepositoryProvider(null));

  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final path = state.uri.path;

      if (auth.user == null) {
        await auth.autoLogin();
      }

      final isLoggedIn = auth.user != null;

      if (isLoggedIn) {
        if (path == '/login' || path == '/register') {
          return '/home';
        }
      } else {
        if (path != '/login' && path != '/register') {
          return '/login';
        }
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(auth.onAuthStateChanged()),
    routes: [
      GoRoute(
        path: '/register',
        name: AppRoutes.register.name,
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: RegisterScreen(),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login.name,
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomeScreen(),
        ),
      ),
    ],
  );
}
