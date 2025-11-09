import 'package:demo/config/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:go_router/go_router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(child: Text("Contenido")),
          ...routerConfig.map((e) => ListTile(

             title: Text(e.tittle),
             onTap: () {
               Navigator.pop(context);
               context.go(e.patch);
             },
             leading: Icon(e.icon),
             subtitle: Text(e.description),
          ))
        ],
      ),
    );
  }
}