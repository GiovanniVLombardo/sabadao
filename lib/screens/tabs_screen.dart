import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/main_drawer.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/screens/home/home_screen.dart';
import 'package:sabadao/screens/profile/profile_screen.dart';
import 'package:sabadao/screens/matches/matches_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedScreen = 0;
  late List<Map<String, Object>> _screens;

  @override
  void initState() {
    super.initState();
    
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayerId = context.watch<UserController>().value?.id ?? '';
    
    _screens = [
      {'title': 'SABADÃO F. C.', 'screen': const HomeScreen()},
      {'title': 'Partidas', 'screen': MatchesScreen()},
      {
        'title': 'Pagamentos',
        'screen': const Center(child: Text('Em breve...')),
      },
      {'title': 'Perfil do Usuário', 'screen': ProfileScreen(playerId: currentPlayerId)},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_screens[_selectedScreen]['title'] as String),
      ),
      body: _screens[_selectedScreen]['screen'] as Widget,
      drawer: MainDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _selectScreen,
        currentIndex: _selectedScreen,
        backgroundColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Pagamentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
