import 'package:demo/config/router/router_model.dart';
import 'package:demo/presentation/main_screen.dart';
import 'package:demo/presentation/profile/profile_screen.dart';
import 'package:demo/presentation/public/auth/auth_screen.dart';
import 'package:demo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final routerConfig = <RouterModel>[
  RouterModel(
    name: MainScreen.name,
    description: "Pantalla principal",
    patch: "/home",
    icon: Icons.home,
    screen: (context, state) => const MainScreen(),
    isVisible: true,
    tittle: "Products",
  ),
];

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final isAuthenticated = await AuthService.isAuthenticated();
    final isGoingToAuth = state.matchedLocation == '/';

    // Si no está autenticado y no va al login, redirigir al login
    if (!isAuthenticated && !isGoingToAuth) {
      return '/';
    }

    // Si está autenticado y va al login, redirigir al home
    if (isAuthenticated && isGoingToAuth) {
      return '/home';
    }

    return null; // No redirigir
  },
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      name: AuthScreen.name,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      builder: (context, state) => const ProfileScreen(),
    ),
    ...routerConfig.map(
      (e) => GoRoute(path: e.patch, name: e.name, builder: e.screen),
    ),
  ],
);
