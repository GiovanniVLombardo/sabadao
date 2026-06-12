import 'package:flutter/material.dart';
import 'package:sabadao/components/profile/avatar.dart';
import 'package:sabadao/components/profile/avatar_with_edit_button.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/player.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Player? player;
  final UserController controller;
  final bool isCurrentPlayer;

  const CustomSliverAppBar({
    super.key,
    this.player,
    required this.controller,
    required this.isCurrentPlayer,
  });

  static const Color _bg = Color(0xFF0D1117);
  static const Color _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _bg,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [
                    Color(0xFF0D1117),
                    Color(0xFF1A3A6B),
                    Color(0xFF0D1117),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 0,
              right: 0,
              child: Center(
                child: isCurrentPlayer
                    ? AvatarWithEditButton(
                        player: player,
                        controller: controller,
                      )
                    : Avatar(player: player,),
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _bg],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
