import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/score/counter_row.dart';
import 'package:sabadao/components/score/player_scout_tile.dart';
import 'package:sabadao/components/score/scoreboard_card.dart';
import 'package:sabadao/components/score/section_header.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/scout_entry.dart';
import 'package:sabadao/models/team_score.dart';

class MatchScoutScreen extends StatefulWidget {
  final Match match;
  final List<Player> confirmedPlayers;

  const MatchScoutScreen({
    super.key,
    required this.match,
    required this.confirmedPlayers,
  });

  @override
  State<MatchScoutScreen> createState() => _MatchScoutScreenState();
}

class _MatchScoutScreenState extends State<MatchScoutScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ScoutController>().loadMatchData(
            widget.match.id!,
            widget.confirmedPlayers,
          );
    } catch (e) {
      _showError('Erro ao carregar dados. $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _editTeamScore(TeamScore team) async {
    final controller = TextEditingController(text: team.score.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Placar — ${team.acronym ?? team.teamName}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Gols do time',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value >= 0) Navigator.pop(ctx, value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    setState(() => _isSaving = true);
    try {
      await context.read<ScoutController>().updateTeamScore(
            matchId: widget.match.id!,
            teamId: team.teamId,
            score: result,
          );
    } catch (_) {
      _showError('Erro ao atualizar placar.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editPlayerScout(ScoutEntry entry) async {
    int goals = entry.goals;
    int assists = entry.assists;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: (entry.avatarUrl != null &&
                        entry.avatarUrl!.isNotEmpty)
                    ? NetworkImage(entry.avatarUrl!)
                    : null,
                child: (entry.avatarUrl == null || entry.avatarUrl!.isEmpty)
                    ? Text(entry.displayName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text(entry.displayName)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CounterRow(
                label: 'Gols',
                icon: Icons.sports_soccer,
                value: goals,
                onChanged: (v) => setDialogState(() => goals = v),
              ),
              const SizedBox(height: 12),
              CounterRow(
                label: 'Assistências',
                icon: Icons.assistant_outlined,
                value: assists,
                onChanged: (v) => setDialogState(() => assists = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    setState(() => _isSaving = true);
    try {
      await context.read<ScoutController>().upsertScout(
            matchId: widget.match.id!,
            playerId: entry.playerId,
            goals: goals,
            assists: assists,
          );
    } catch (_) {
      _showError('Erro ao salvar dados do jogador.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placar & Gols'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Consumer<ScoutController>(
                builder: (context, controller, _) {
                  return CustomScrollView(
                    slivers: [
                      // ── Placar ──────────────────────────────────────────
                      if (controller.teams.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: SectionHeader(
                            icon: Icons.scoreboard_outlined,
                            label: 'Placar',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: ScoreboardCard(
                            teams: controller.teams,
                            onEdit: _editTeamScore,
                          ),
                        ),
                      ],

                      // ── Gols por jogador ────────────────────────────────
                      const SliverToBoxAdapter(
                        child: SectionHeader(
                          icon: Icons.sports_soccer_outlined,
                          label: 'Gols & Assistências',
                        ),
                      ),

                      if (controller.value.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text(
                              'Nenhum jogador confirmado.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = controller.value[index];
                              return PlayerScoutTile(
                                entry: entry,
                                onTap: () => _editPlayerScout(entry),
                              );
                            },
                            childCount: controller.value.length,
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

// ── Scoreboard ──────────────────────────────────────────────────────────────





// ── Player Scout Tile ───────────────────────────────────────────────────────



// ── Counter Row (dialog) ────────────────────────────────────────────────────



// ── Section Header ──────────────────────────────────────────────────────────

