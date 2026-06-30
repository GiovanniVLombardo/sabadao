import 'package:flutter/material.dart';
import 'package:sabadao/components/ranking/build_ranking_avatar.dart';
import 'package:sabadao/components/ranking/stat_badge.dart';
import 'package:sabadao/models/player_ranking.dart';

class RankingTile extends StatelessWidget {
  final PlayerRanking player;
  final int rank;

  const RankingTile({super.key, required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Color(0xFF8A9BB0),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BuildRankingAvatar(
            url: player.avatarUrl,
            name: player.displayName,
            radius: 22,
            borderColor: Color(0xFF008CFF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: Color(0xFF8A9BB0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  StatBadge(emoji: '⚽', value: player.goals.toString()),
                  const SizedBox(width: 8),
                  StatBadge(emoji: '🏆', value: player.wins.toString()),
                ],
              ),
              StatBadge(emoji: '📈', value: '${player.winRate.toString()}%'),
            ],
          ),
        ],
      ),
    );
  }
}
