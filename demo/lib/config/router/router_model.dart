import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterModel{
  String name;
  GoRouterWidgetBuilder screen;
  String tittle;
  String patch;
  IconData icon;
  String description;
  bool isVisible;

  RouterModel({
    required this.name,
    required this.description,
    required this.patch,
    required this.icon,
    required this.screen,
    required this.isVisible,
    required this.tittle
  });
}
