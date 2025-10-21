import 'package:demo/presentation/home/home_screen.dart';
import 'package:demo/presentation/products/products_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute> [
    GoRoute(path: '/', name: 'home', builder: (context, state){
      return const HomeScreen();
    }),
    GoRoute(path: '/product', name: 'producto', builder: (context, state){
      return const ProductsScreen();
    })
  ]
  
  );
