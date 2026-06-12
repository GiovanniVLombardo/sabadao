import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/profile/custom_sliver_app_bar.dart';
import 'package:sabadao/components/profile/info_card.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/player.dart';

class ProfileScreen extends StatefulWidget {
  final String? playerId;

  const ProfileScreen({super.key, required this.playerId});

  // Palette
  static const Color _bg = Color(0xFF0D1117);
  static const Color _card = Color(0xFF161B22);
  static const Color _starFilled = Color(0xFFFBBF24);
  static const Color _starEmpty = Color(0xFF374151);
  static const Color _textPrimary = Color(0xFFF9FAFB);
  static const Color _textSecondary = Color(0xFF9CA3AF);
  static const Color _divider = Color(0xFF21262D);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Player? player;
  bool _isLoading = false;
  bool _isCurrentPlayer = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlayer());
  }

  Future<void> _loadPlayer() async {
    final userController = context.read<UserController>();
    final currentPlayer = userController.value;

    if (currentPlayer?.id == widget.playerId) {
      setState(() => player = currentPlayer);
      setState(() {
        _isCurrentPlayer = true;
      });
      return;
    }

    setState(() => _isLoading = true);
    final _player = await userController.getPlayerById(widget.playerId!);
    setState(() {
      player = _player;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserController>();
    //final Player? player = controller.value!.id == playerId ? controller.value : controller.getPlayerById(playerId);

    return Scaffold(
      backgroundColor: ProfileScreen._bg,
      body: _isLoading || player == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                CustomSliverAppBar(
                  player: player,
                  controller: controller,
                  isCurrentPlayer: _isCurrentPlayer,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildNameAndTeam(player),
                        _buildRatingRow(player),
                        const SizedBox(height: 24),
                        _buildStatsRow(player),
                        const SizedBox(height: 28),
                        InfoCard(player: player),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNameAndTeam(Player? player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player!.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ProfileScreen._textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(Player? player) {
    return Row(
      children: [
        _buildStars(player!.level.toDouble()),
        const SizedBox(width: 10),
        Text(
          player.level.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ProfileScreen._starFilled,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '/ 5.0',
          style: TextStyle(fontSize: 13, color: ProfileScreen._textSecondary),
        ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        final double fill = (rating - i).clamp(0.0, 1.0);
        IconData icon;
        if (fill >= 1.0) {
          icon = Icons.star_rounded;
        } else if (fill >= 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        final Color color = fill > 0
            ? ProfileScreen._starFilled
            : ProfileScreen._starEmpty;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(icon, size: 26, color: color),
        );
      }),
    );
  }

  Widget _buildStatsRow(Player? player) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileScreen._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProfileScreen._divider),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatCell(label: 'Jogos', value: player!.games.toString()),
            _verticalDivider(),
            _buildStatCell(label: 'Gols', value: player.goals.toString()),
            _verticalDivider(),
            _buildStatCell(
              label: 'Assistências',
              value: player.assists.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCell({required String label, required String value}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: ProfileScreen._textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: ProfileScreen._textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, color: ProfileScreen._divider);
}
