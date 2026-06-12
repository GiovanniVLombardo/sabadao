import 'package:flutter/material.dart';
import 'package:sabadao/components/home/upcoming_matches.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ],
          ),
        ),
      ),
    );
  }
}
