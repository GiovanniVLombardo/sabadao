import 'package:flutter/material.dart';
import 'package:sabadao/components/team/team_badge.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/team_score.dart';
import 'package:sabadao/screens/profile/profile_screen.dart';

/// Seção de presença reutilizável (Confirmados / Ausentes / Pendentes).
///
/// [trailingBuilder] define os controles de ação por jogador (pode ser null).
///
/// [teamAssignments] é um mapa { playerId → teamId } opcional. Quando fornecido
/// junto com [teams], exibe uma badge colorida com a sigla do time à esquerda
/// do trailing de cada jogador que tiver time atribuído.
class AttendanceSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<Player> players;
  final Widget? Function(Player player)? trailingBuilder;

  /// Mapa de distribuição: { playerId → teamId }. Opcional.
  final Map<String, int>? teamAssignments;

  /// Times da partida — necessário para resolver cor e sigla a partir do teamId.
  final List<TeamScore>? teams;

  const AttendanceSection({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.players,
    this.trailingBuilder,
    this.teamAssignments,
    this.teams,
  });

  // Resolve o TeamScore a partir do teamId do jogador, ou null se não houver.
  TeamScore? _teamFor(Player player) {
    if (teamAssignments == null || teams == null || player.id == null) {
      return null;
    }
    final teamId = teamAssignments![player.id];
    if (teamId == null) return null;
    try {
      return teams!.firstWhere((t) => t.teamId == teamId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // índice 0 → cabeçalho da seção
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    '$title (${players.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: color),
                  ),
                ],
              ),
            );
          }

          // índice 1 quando vazio → placeholder
          if (players.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Nenhum jogador',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            );
          }

          final player = players[index - 1];
          final team = _teamFor(player);
          final trailing = trailingBuilder?.call(player);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: CircleAvatar(
              backgroundImage: player.avatarUrl.isNotEmpty
                  ? NetworkImage(player.avatarUrl)
                  : null,
              child: player.avatarUrl.isEmpty
                  ? Text(
                      (player.nickname?[0] ?? player.name[0]).toUpperCase(),
                    )
                  : null,
            ),
            title: Text(player.nickname ?? player.name),
            subtitle: Text(player.position),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (team != null) TeamBadge(team: team),
                if (trailing != null) trailing,
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(playerId: player.id),
              ),
            ),
          );
        },
        childCount: players.isEmpty ? 2 : players.length + 1,
      ),
    );
  }
}

