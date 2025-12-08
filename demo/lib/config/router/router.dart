import 'package:demo/config/router/router_model.dart';
import 'package:demo/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final routerConfig = <RouterModel>[
  RouterModel(
    name: MainScreen.name,
    description: "Pantalla principal",
    patch: "/",
    icon: Icons.home,
    screen: (context, state) => const MainScreen(),
    isVisible: true,
    tittle: "Products",
  ),
];

final router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    ...routerConfig.map(
      (e) => GoRoute(path: e.patch, name: e.name, builder: e.screen),
    ),
  ],
);
