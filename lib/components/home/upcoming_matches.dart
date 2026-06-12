import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/matches/match_card.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/screens/matches/match_detail_screen.dart';
import 'package:sabadao/services/match_service.dart';
import 'package:sabadao/models/match.dart';

class UpcomingMatches extends StatefulWidget {
  const UpcomingMatches({super.key});

  @override
  State<UpcomingMatches> createState() => _UpcomingMatchesState();
}

class _UpcomingMatchesState extends State<UpcomingMatches> {
  late final Future<List<Match>> _matchesFuture;

  // Guarda a resposta do usuário por partida: matchId -> true (dentro) / false (fora) / null
  final Map<String, bool?> _rsvp = {};

  @override
  void initState() {
    super.initState();
    _matchesFuture = MatchService().getUpcomingMatches();
  }

  Future<void> _handleRsvp(String matchId, bool isAttending) async {
    setState(() => _rsvp[matchId] = isAttending);

    try {
      // Chame seu endpoint/service aqui, ex:
      // await MatchService().updateRsvp(matchId: matchId, attending: isAttending);
    } catch (e) {
      // Reverte em caso de erro
      setState(() => _rsvp[matchId] = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao confirmar presença. Tente novamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    final Player? player = controller.value;
    return FutureBuilder<List<Match>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar partidas: ${snapshot.error}'),
          );
        }

        final matches = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Próximas Partidas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nenhuma partida agendada.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: matches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return MatchCard(
                    match: match,
                    rsvp: _rsvp[match.id],
                    onRsvp: (attending) => _handleRsvp(match.id, attending),
                    currentPlayerId: player!.id!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchDetailScreen(match: match),
                      ),
                    ),
                    showButtons: true,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
