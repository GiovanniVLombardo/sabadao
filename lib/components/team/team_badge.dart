import 'package:flutter/material.dart';
import 'package:sabadao/models/team_score.dart';

class TeamBadge extends StatelessWidget {
  final TeamScore team;

  const TeamBadge({super.key, required this.team});

  Color get _color {
    final raw = team.color;
    if (raw == null || raw.isEmpty) return Colors.blueGrey;
    try {
      return Color(int.parse(raw.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = team.acronym ?? team.teamName;
    final bg = _color;
    // Escolhe texto branco ou preto dependendo da luminância do fundo
    final textColor =
        bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}