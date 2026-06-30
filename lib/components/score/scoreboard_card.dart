import 'package:flutter/material.dart';
import 'package:sabadao/components/score/team_score_block.dart';
import 'package:sabadao/models/team_score.dart';

class ScoreboardCard extends StatelessWidget {
  final List<TeamScore> teams;
  final void Function(TeamScore) onEdit;

  const ScoreboardCard({super.key, required this.teams, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < teams.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'x',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              TeamScoreBlock(team: teams[i], onEdit: () => onEdit(teams[i])),
            ],
          ],
        ),
      ),
    );
  }
}