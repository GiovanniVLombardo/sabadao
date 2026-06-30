import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/ranking/podium_card.dart';
import 'package:sabadao/controllers/scout_controller.dart';

class BuildRankingTopThree extends StatelessWidget {
  const BuildRankingTopThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoutController>(
      builder: (_, ctrl, _) {
        if (ctrl.isLoading || ctrl.ranking.isEmpty) {
          return const SizedBox.shrink();
        }

        final top = ctrl.ranking.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (top.length > 1) Expanded(child: PodiumCard(player: top[1], position: 2,  height: 80)),
              Expanded(child: PodiumCard(player: top[0], position: 1, height: 100)),
              if (top.length > 2) Expanded(child: PodiumCard(player: top[2], position: 3, height: 64)),
            ],
          ),
        );
      },
    );
  }
}
