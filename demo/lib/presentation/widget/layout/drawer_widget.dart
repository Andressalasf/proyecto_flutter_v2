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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Creadores',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildStudentInfo(
                  'assets/images/andres.jpeg',
                  '192164',
                  'Andres Felipe Salas Niño',
                  'afsalasn@ufpso.edu.co',
                ),
                const SizedBox(height: 20),
                _buildStudentInfo(
                  'assets/images/brian.jpeg',
                  '192219',
                  'Brian Matheo Alvarez Pacheco',
                  'bmalvarezp@ufpso.edu.co',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text('Perfil'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
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
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(
    String imagePath,
    String code,
    String name,
    String email,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          '$code - $name',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
