import 'package:flutter/material.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/screens/matches/match_game_screen.dart';
import 'package:sabadao/screens/matches/scheduled_match_screen.dart';

/// Roteador central para a tela de detalhes de partida.
///
/// Delega para [ScheduledMatchScreen] ou [MatchGameScreen] conforme o status.
/// Após uma edição que altere o status, as telas filhas devem chamar
/// [MatchDetailRouter.replace] para substituir a rota atual por uma nova
/// instância do roteador com o [Match] atualizado.
class MatchDetailRouter extends StatelessWidget {
  final Match match;

  const MatchDetailRouter({super.key, required this.match});

  /// Substitui a rota atual por um novo [MatchDetailRouter] com [updatedMatch].
  /// Use isso após editar uma partida para garantir que a tela correta seja exibida.
  static void replace(BuildContext context, Match updatedMatch) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailRouter(match: updatedMatch),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (match.status) {
      'scheduled' => ScheduledMatchScreen(match: match),
      'ongoing' || 'finished' => MatchGameScreen(match: match),
      _ => Scaffold(
          body: Center(
            child: Text('Status desconhecido: ${match.status}'),
          ),
        ),
    };
  }
}