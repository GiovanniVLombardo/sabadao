// ranking_export_widget.dart
import 'package:flutter/material.dart';
import 'package:sabadao/models/player_ranking.dart';

class RankingExportWidget extends StatelessWidget {
  final List<PlayerRanking> ranking;
  const RankingExportWidget({super.key, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      color: const Color(0xFF0D1B2A), // mesma cor de fundo do app
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho
          const Text(
            'Artilheiros',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Lista completa — sem ListView, usa Column para capturar tudo
          ...ranking.asMap().entries.map((e) {
            final player = e.value;
            final rank = e.key + 1;
            return _RankingExportTile(player: player, rank: rank);
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RankingExportTile extends StatelessWidget {
  final PlayerRanking player;
  final int rank;

  const _RankingExportTile({required this.player, required this.rank});

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
      child: Row(
        children: [
          // Posição
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
          // Avatar
          _buildAvatar(player.avatarUrl, player.nickname ?? player.displayName),
          const SizedBox(width: 12),
          // Nome e posição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.nickname ?? player.displayName,
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
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _statBadge('⚽', player.goals.toString()),
                  const SizedBox(width: 8),
                  _statBadge('🏆', player.wins.toString()),
                ],
              ),
              const SizedBox(height: 4),
              _statBadge('📈', '${player.winRate}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, String name) {
    const borderColor = Color(0xFF008CFF);
    const radius = 22.0;
    return CircleAvatar(
      radius: radius,
      backgroundColor: borderColor.withValues(alpha: 0.2),
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }

  Widget _statBadge(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}