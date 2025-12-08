import 'package:demo/presentation/products/products_screen.dart';
import 'package:demo/presentation/list_products/list_products.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static const String name = "main_screen";
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  final List<Widget> _screens = [const ProductsScreen(), const ListProducts()];

  void _onItemTapped(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[index],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Consultar'),
          ],
          currentIndex: index,
          selectedItemColor: Colors.indigo,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
