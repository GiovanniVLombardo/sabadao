import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/ranking/ranking_tile.dart';
import 'package:sabadao/controllers/scout_controller.dart';

class RankingList extends StatelessWidget {
  const RankingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<ScoutController>(
        builder: (_, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF008CFF)),
            );
          }

          if (ctrl.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFF8A9BB0),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.error!,
                    style: const TextStyle(color: Color(0xFF8A9BB0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: ctrl.loadRanking,
                    child: const Text(
                      'Tentar novamente',
                      style: TextStyle(color: Color(0xFF008CFF)),
                    ),
                  ),
                ],
              ),
            );
          }

          if (ctrl.ranking.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma estatística ainda.',
                style: TextStyle(color: Color(0xFF8A9BB0)),
              ),
            );
          }

          final listPlayers = ctrl.ranking.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: listPlayers.length,
            itemBuilder: (context, index) {
              final player = listPlayers[index];
              final rank = index + 1;
              return RankingTile(player: player, rank: rank);
            },
          );
        },
      ),
    );
  }
}