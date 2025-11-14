import 'package:demo/config/router/router_model.dart';
import 'package:demo/presentation/home/home_screen.dart';
import 'package:demo/presentation/products/products_screen.dart';
import 'package:demo/presentation/list_products/list_products.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final routerConfig = <RouterModel> [
  RouterModel(
    name: HomeScreen.name,
    description: "Home Screen",
    patch: "/",
    icon: Icons.home_work, 
    screen: (context, state) => const HomeScreen(),
    isVisible: true,
    tittle: "Home"),
    RouterModel(
    name: ProductsScreen.name,
    description: "Crear producto",
    patch: "/product",
    icon: Icons.production_quantity_limits, 
    screen: (context, state) => const ProductsScreen(),
    isVisible: true,
    tittle: "Product"),
    RouterModel(
    name: ListProducts.name,
    description: "Listar productos",
    patch: "/list_products",
    icon: Icons.list,
    screen: (context, state) => const ListProducts(),
    isVisible: true,
    tittle: "List Products"),
];

final router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute> [
    ...routerConfig.map((e) => GoRoute(path: e.patch, name: e.name, builder: e.screen))
  ]
  
  );
