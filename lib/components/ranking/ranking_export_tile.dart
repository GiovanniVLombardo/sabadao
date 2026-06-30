import 'package:flutter/material.dart';
import 'package:sabadao/components/ranking/build_ranking_header.dart';
import 'package:sabadao/components/ranking/build_ranking_top_three.dart';
import 'package:sabadao/components/ranking/ranking_list.dart';
import 'package:sabadao/models/player_ranking.dart';

class RankingExportTile extends StatelessWidget {
  final PlayerRanking player;
  final int rank;

  const RankingExportTile({super.key, required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3C), // equivalente ao surfaceBright do tema
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3B4C)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildRankingHeader(),
            const SizedBox(height: 8),
            BuildRankingTopThree(),
            const SizedBox(height: 12),
            RankingList(),
          ],
        ),
    );
  }
}