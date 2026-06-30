import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/matches/attendance_section.dart';
import 'package:sabadao/components/matches/edit_match_dialog.dart';
import 'package:sabadao/components/matches/match_header_widget.dart';
import 'package:sabadao/components/score/counter_row.dart';
import 'package:sabadao/components/score/player_scout_tile.dart';
import 'package:sabadao/components/score/scoreboard_card.dart';
import 'package:sabadao/components/score/section_header.dart';
import 'package:sabadao/controllers/attendance_controller.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/scout_entry.dart';
import 'package:sabadao/models/team_score.dart';
import 'package:sabadao/routers/match_detail_router.dart';
import 'package:sabadao/screens/matches/match_scout_screen.dart';
import 'package:sabadao/services/scout_service.dart';
import 'package:sabadao/utils/globals.dart';

class MatchGameScreen extends StatefulWidget {
  final Match match;

  const MatchGameScreen({super.key, required this.match});

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  late Match _match;
  List<Player> _confirmed = [];
  List<TeamScore> _teams = [];
  Map<String, int> _teamAssignments = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  /// Carrega presenças primeiro para que _loadTopScorers tenha _confirmed pronto.
  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await _loadAttendances();
    await Future.wait([
      _loadScoutData(),
      _loadAssignments(),
      _loadMatchData()
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMatchData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ScoutController>().loadMatchData(
            widget.match.id!,
            _confirmed,
          );
    } catch (e) {
      Globals.showError(context, 'Erro ao carregar dados. $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendances() async {
    try {
      final result = await context.read<AttendanceController>().getAttendances(
        _match.id!,
      );
      if (mounted) setState(() => _confirmed = result.confirmed);
    } catch (e) {
      debugPrint('$e');
      Globals.showError(context, 'Erro ao carregar presenças. $e');
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final assignments = await ScoutService().getPlayerAssignments(_match.id!);
      if (mounted) setState(() => _teamAssignments = assignments);
    } catch (e) {
      debugPrint('Erro ao carregar distribuição: $e');
    }
  }

  Future<void> _loadScoutData() async {
    try {
      final teams = await ScoutService().getMatchTeams(_match.id!);
      if (mounted) setState(() => _teams = teams);
    } catch (e) {
      debugPrint('Scout load error: $e');
    }
  }


  Future<void> _openScoutScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ScoutController(),
          child: MatchScoutScreen(match: _match, confirmedPlayers: _confirmed),
        ),
      ),
    );
    // Recarrega placar e artilheiros ao voltar
    await Future.wait([_loadScoutData()]);
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
        matchId: _match.id!,
        teamId: team.teamId,
        score: result,
      );
      await _loadScoutData();
    } catch (_) {
      Globals.showError(context, 'Erro ao atualizar placar.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editMatch() async {
    final updated = await showEditMatchDialog(context, _match);
    if (updated == null || !mounted) return;

    if (updated.status != _match.status) {
      MatchDetailRouter.replace(context, updated);
    } else {
      setState(() => _match = updated);
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
                backgroundImage:
                    (entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty)
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
      Globals.showError(context, 'Erro ao salvar dados do jogador.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _isActiveMatch =>
      _match.status == 'ongoing' || _match.status == 'finished';

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserController>().value?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        actions: [
          /*if (isAdmin && _isActiveMatch)
            IconButton(
              icon: const Icon(Icons.scoreboard_outlined),
              tooltip: 'Placar & Gols',
              onPressed: _openScoutScreen,
            ),*/
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar partida',
              onPressed: _editMatch,
            ),
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
              onRefresh: _loadAll,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: matchHeaderWidget(context, _match)),

                  // ── Confirmados com time ────────────────────────────────
                  /*if (_confirmed.isNotEmpty)
                    AttendanceSection(
                      icon: Icons.check_circle_outlined,
                      color: Colors.green,
                      title: 'Confirmados',
                      players: _confirmed,
                      teamAssignments: _teamAssignments,
                      teams: _teams,
                    ),*/

                  // ── Placar ──────────────────────────────────────────────
                  if (_teams.isNotEmpty)
                    SliverToBoxAdapter(
                      child: ScoreboardCard(
                        teams: _teams,
                        onEdit: _editTeamScore,
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      icon: Icons.sports_soccer_outlined,
                      label: 'Gols & Assistências',
                    ),
                  ),
                  Consumer<ScoutController>(
                    builder: (context, controller, _) {
                      if (controller.value.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Text(
                              'Nenhum jogador confirmado.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entry = controller.value[index];
                            return PlayerScoutTile(
                              entry: entry,
                              onTap: () => _editPlayerScout(entry),
                            );
                          }, childCount: controller.value.length),
                        );
                      }
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }
}
