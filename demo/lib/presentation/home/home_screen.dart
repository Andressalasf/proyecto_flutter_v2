import 'package:demo/presentation/widget/layout/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const String name = "home_screen";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Hola home"),),
      drawer: DrawerWidget(),
      body: Center(
        child: SafeArea(
          child: FilledButton(onPressed: (){
            context.go("/product");
          }, child: Text("To product")),
        ),
      ),
    );
  }
}