import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/home/upcoming_matches.dart';
import 'package:sabadao/controllers/match_controller.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/screens/matches/create_match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openCreateMatchScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MatchController(),
          child: CreateMatchScreen(),
        ),
      ),
    );
    if (mounted) {
      await context.read<MatchController>().loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserController>().value?.isAdmin ?? false;
    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openCreateMatchScreen,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Criar Partida'),
            )
          : null,
      // Scaffold é necessário para layout correto
      body: SafeArea(
        child: SingleChildScrollView(
          // permite scroll caso a lista cresça
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height:
                      160, // Tamanho ideal para destacar sem quebrar em telas menores
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              UpcomingMatches(),
              const SizedBox(height: 75)
            ],
          ),
        ),
      ),
    );
  }
}
