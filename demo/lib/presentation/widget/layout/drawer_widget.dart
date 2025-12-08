import 'package:demo/config/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replace default DrawerHeader (which creates a large empty gap)
          // with a compact header so there's no big empty space.
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color:
                Theme.of(context).drawerTheme.backgroundColor ??
                Theme.of(context).primaryColor,
            child: Text(
              "Contenido",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...routerConfig.map(
            (e) => ListTile(
              title: Text(e.tittle),
              onTap: () {
                Navigator.pop(context);
                context.go(e.patch);
              },
              leading: Icon(e.icon),
              subtitle: Text(e.description),
            ),
          ),
        ],
      ),
    );
  }
}
