
import 'package:flutter/material.dart';
import 'package:sabadao/services/auth_service.dart';
import 'package:sabadao/utils/app_routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget _createDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomCenter,
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'SABADÃO F. C.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _createDrawerItem(
            Icons.home,
            'Início',
            () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),_createDrawerItem(
            Icons.insert_chart,
            'Ranking',
            () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.ranking);
            },
          ),
          _createDrawerItem(
            Icons.settings,
            'Configurações',
            () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
            },
          ),
          _createDrawerItem(
            Icons.logout,
            'Sair',
            () {
              AuthService authService = AuthService();
              authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}