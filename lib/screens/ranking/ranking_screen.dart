import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/main_drawer.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/models/player_ranking.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoutController>().loadRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
        actions: [
          Consumer<ScoutController>(
            builder: (_, ctrl, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF008CFF)),
              onPressed: ctrl.isLoading ? null : ctrl.loadRanking,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MainDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildTopThree(),
            const SizedBox(height: 12),
            _buildRankingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Artilheiros',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  /*Widget _buildFilterTabs() {
    return Consumer<ScoutController>(
      builder: (_, ctrl, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _filterTab('Gols', RankingFilter.goals, '⚽', ctrl),
                _filterTab('Vitórias', RankingFilter.wins, '🏆', ctrl),
                _filterTab('Aproveit.', RankingFilter.winRate, '📈', ctrl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterTab(
    String label,
    RankingFilter filter,
    String emoji,
    ScoutController ctrl,
  ) {
    final isActive = ctrl.currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF008CFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF0D1B2A)
                      : const Color(0xFF8A9BB0),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget _buildTopThree() {
    return Consumer<ScoutController>(
      builder: (_, ctrl, _) {
        if (ctrl.isLoading || ctrl.ranking.isEmpty){
          return const SizedBox.shrink();
        }

        final top = ctrl.ranking.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (top.length > 1) Expanded(child: _podiumCard(top[1], 2, 80)),
              Expanded(child: _podiumCard(top[0], 1, 100)),
              if (top.length > 2) Expanded(child: _podiumCard(top[2], 3, 64)),
            ],
          ),
        );
      },
    );
  }

  Widget _podiumCard(PlayerRanking player, int position, double height) {
    final colors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFB0BEC5),
      3: const Color(0xFFFF8C42),
    };
    final color = colors[position]!;

    final value = _getStatValue(player);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          _buildAvatar(player.avatarUrl, player.displayName, 36, color),
          const SizedBox(height: 6),
          Text(
            player.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    return Expanded(
      child: Consumer<ScoutController>(
        builder: (_, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF008CFF)),
            );
          }

          if (ctrl.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFF8A9BB0),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ctrl.error!,
                    style: const TextStyle(color: Color(0xFF8A9BB0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: ctrl.loadRanking,
                    child: const Text(
                      'Tentar novamente',
                      style: TextStyle(color: Color(0xFF008CFF)),
                    ),
                  ),
                ],
              ),
            );
          }

          if (ctrl.ranking.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma estatística ainda.',
                style: TextStyle(color: Color(0xFF8A9BB0)),
              ),
            );
          }

          final listPlayers = ctrl.ranking.skip(3).toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: listPlayers.length,
            itemBuilder: (context, index) {
              final player = listPlayers[index];
              final rank = index + 4;
              return _rankingTile(player, rank);
            },
          );
        },
      ),
    );
  }

  Widget _rankingTile(PlayerRanking player, int rank) {
    //final value = _getStatValue(player);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Color(0xFF8A9BB0),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildAvatar(
            player.avatarUrl,
            player.displayName,
            22,
            const Color(0xFF008CFF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: Color(0xFF8A9BB0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _statBadge('⚽', player.goals.toString()),
                  const SizedBox(width: 8),
                  _statBadge('🏆', player.wins.toString()),
                ],
              ),
              _statBadge('📈', '${player.winRate.toString()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String? url,
    String name,
    double radius,
    Color borderColor,
  ) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: borderColor.withValues(alpha: 0.2),
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }

  String _getStatValue(PlayerRanking player) {
    final ctrl = context.read<ScoutController>();
    switch (ctrl.currentFilter) {
      case RankingFilter.goals:
        return '${player.goals} gols';
      case RankingFilter.wins:
        return '${player.wins} Vitórias';
      case RankingFilter.winRate:
        return '${player.winRate}%';
    }
  }
}
