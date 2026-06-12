import 'package:flutter/material.dart';
import 'package:sabadao/components/profile/info_row.dart';
import 'package:sabadao/models/player.dart';

class InfoCard extends StatelessWidget {
  final Player? player;
  const InfoCard({super.key, this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          InfoRow(label: 'Nome', value: player!.name, isFirst: true),
          _buildRowDivider(Theme.of(context).colorScheme.outline),
          InfoRow(label: 'Idade', value: '${player!.age} anos'),
          _buildRowDivider(Theme.of(context).colorScheme.outline),
          InfoRow(
            label: 'Posição',
            value: player!.position,
            valueColor: Theme.of(context).colorScheme.secondary,
          ),
          _buildRowDivider(Theme.of(context).colorScheme.outline),
          InfoRow(
            label: 'Pé Preferido',
            value: player!.preferredFoot,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider(Color color) => Container(
    height: 1,
    color: color,
    margin: const EdgeInsets.symmetric(horizontal: 16),
  );
}
