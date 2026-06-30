import 'package:flutter/material.dart';
import 'package:sabadao/models/team_score.dart';

class TeamScoreBlock extends StatelessWidget {
  final TeamScore team;
  final VoidCallback onEdit;

  const TeamScoreBlock({super.key, required this.team, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onEdit,
      child: Column(
        children: [
          Text(
            team.score.toString(),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            team.acronym ?? team.teamName,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 12,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 2),
              Text(
                'Editar',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}