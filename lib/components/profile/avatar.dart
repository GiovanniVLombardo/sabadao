import 'package:flutter/material.dart';
import 'package:sabadao/models/player.dart';

class Avatar extends StatelessWidget {
  final Player? player;
  const Avatar({super.key, this.player});

  static const Color _accent = Color(0xFF2563EB);
  static const Color _accentLight = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    const double size = 220;
    

    if (player?.avatarUrl != '') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _accentLight, width: 3),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.5),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
          image: DecorationImage(
            image: player!.avatarUrl.startsWith('http')
                ? NetworkImage(player!.avatarUrl)
                : AssetImage(player!.avatarUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Initials fallback
    final initials = player!.name
        .split(' ')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        border: Border.all(color: _accentLight, width: 3),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.5),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
