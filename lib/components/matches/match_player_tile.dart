import 'package:flutter/material.dart';
import 'package:sabadao/components/team/team_badge.dart';
import 'package:sabadao/models/team_score.dart';

class MatchPlayerTile extends StatelessWidget {
  final String name;
  final String position;
  final String? avatarUrl;

  final TeamScore? team;

  final int goals;
  final int assists;

  final VoidCallback? onTap;
  final Widget? trailing;

  const MatchPlayerTile({
    super.key,
    required this.name,
    required this.position,
    this.avatarUrl,
    this.team,
    this.goals = 0,
    this.assists = 0,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasScout = goals > 0 || assists > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),

      leading: CircleAvatar(
        backgroundImage:
            avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
        child:
            avatarUrl == null || avatarUrl!.isEmpty
                ? Text(name[0].toUpperCase())
                : null,
      ),

      title: Text(name),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(position),

          const SizedBox(height: 4),

          Row(
            children: [
              if (team != null) TeamBadge(team: team!),

              if (team != null)
                const SizedBox(width: 8),

              if (hasScout) ...[
                const Icon(Icons.sports_soccer, size: 14),
                const SizedBox(width: 2),
                Text("$goals"),

                const SizedBox(width: 10),

                const Icon(Icons.assistant_outlined, size: 14),
                const SizedBox(width: 2),
                Text("$assists"),
              ] else
                Text(
                  "Sem registros",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ],
      ),

      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),

      onTap: onTap,
    );
  }
}