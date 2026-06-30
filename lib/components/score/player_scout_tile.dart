import 'package:flutter/material.dart';
import 'package:sabadao/models/scout_entry.dart';

class PlayerScoutTile extends StatelessWidget {
  final ScoutEntry entry;
  final VoidCallback onTap;

  const PlayerScoutTile({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStats = entry.goals > 0 || entry.assists > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: CircleAvatar(
        backgroundImage:
            (entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty)
                ? NetworkImage(entry.avatarUrl!)
                : null,
        child: (entry.avatarUrl == null || entry.avatarUrl!.isEmpty)
            ? Text(entry.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(entry.displayName),
      subtitle: hasStats
          ? Row(
              children: [
                if (entry.goals > 0) ...[
                  const Icon(Icons.sports_soccer, size: 13),
                  const SizedBox(width: 3),
                  Text('${entry.goals}'),
                  const SizedBox(width: 10),
                ],
                if (entry.assists > 0) ...[
                  const Icon(Icons.assistant_outlined, size: 13),
                  const SizedBox(width: 3),
                  Text('${entry.assists}'),
                ],
              ],
            )
          : Text(
              'Sem registros',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}