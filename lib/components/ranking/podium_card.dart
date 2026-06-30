import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/ranking/build_ranking_avatar.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/models/player_ranking.dart';

class PodiumCard extends StatelessWidget {
  final PlayerRanking player; 
  final int position;
  final double height;
  const PodiumCard({super.key, required this.player, required this.position, required this.height});
  

  @override
  Widget build(BuildContext context) {
    String getStatValue(PlayerRanking player) {
    final ctrl = context.read<ScoutController>();
    switch (ctrl.currentFilter) {
      case RankingFilter.goals:
        return '${player.goals} gols';
      case RankingFilter.wins:
        return '${player.wins} Vitórias';
      case RankingFilter.winRate:
        return '${player.winRate}%';
    }
  }
    final colors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFB0BEC5),
      3: const Color(0xFFFF8C42),
    };
    final color = colors[position]!;

    final value = getStatValue(player);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          BuildRankingAvatar(url: player.avatarUrl, name: player.displayName, radius: 36, borderColor: color),
          const SizedBox(height: 6),
          Text(
            player.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

