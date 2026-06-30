import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/matches/match_card.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/routers/match_detail_router.dart';
import 'package:sabadao/services/match_service.dart';
import 'package:sabadao/models/match.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final Future<List<Match>> _matchesFuture;


  @override
  void initState() {
    super.initState();
    _matchesFuture = MatchService().getFinishedMatches();
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

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
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
                          currentPlayerId: player!.id!,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchDetailRouter(match: match),
                            ),
                          ),
                          showButtons: false,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
