import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/matches/attendance_section.dart';
import 'package:sabadao/components/matches/edit_match_dialog.dart';
import 'package:sabadao/components/matches/match_header_widget.dart';
import 'package:sabadao/controllers/attendance_controller.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/team_score.dart';
import 'package:sabadao/routers/match_detail_router.dart';
import 'package:sabadao/screens/matches/team_distribution_screen.dart';
import 'package:sabadao/services/scout_service.dart';
import 'package:sabadao/utils/globals.dart';

class ScheduledMatchScreen extends StatefulWidget {
  final Match match;

  const ScheduledMatchScreen({super.key, required this.match});

  @override
  State<ScheduledMatchScreen> createState() => _ScheduledMatchScreenState();
}

class _ScheduledMatchScreenState extends State<ScheduledMatchScreen> {
  late Match _match;
  List<Player> _confirmed = [];
  List<Player> _declined = [];
  List<Player> _pending = [];
  List<TeamScore> _teams = [];
  Map<String, int> _teamAssignments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadAttendances(), _loadTeams(), _loadAssignments()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await ScoutService().getMatchTeams(_match.id!);
      if (mounted) setState(() => _teams = teams);
    } catch (e) {
      debugPrint('Erro ao carregar times: $e');
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final assignments =
          await ScoutService().getPlayerAssignments(_match.id!);
      if (mounted) setState(() => _teamAssignments = assignments);
    } catch (e) {
      debugPrint('Erro ao carregar distribuição: $e');
    }
  }

  Future<void> _loadAttendances() async {
    try {
      final result = await context
          .read<AttendanceController>()
          .getAttendances(_match.id!);
      if (mounted) {
        setState(() {
          _confirmed = result.confirmed;
          _declined = result.declined;
          _pending = result.pending;
        });
      }
    } catch (e) {
      debugPrint('$e');
      Globals.showError(context, 'Erro ao carregar presenças. $e');
    }
  }

  Future<void> _toggleAttendance(Player player, bool confirm) async {
    try {
      await context.read<AttendanceController>().setAttendance(
            matchId: _match.id!,
            playerId: player.id!,
            isConfirmed: confirm,
          );
      await _loadAttendances();
    } catch (e) {
      Globals.showError(context, 'Erro ao atualizar presença. $e');
    }
  }

  Future<void> _removeAttendance(Player player) async {
    try {
      await context.read<AttendanceController>().removeAttendance(
            matchId: _match.id!,
            playerId: player.id!,
          );
      await _loadAttendances();
    } catch (_) {
      Globals.showError(context, 'Erro ao remover presença.');
    }
  }

  Future<void> _showAddGuestDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Avulso'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do jogador',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Insira um nome' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                await context.read<AttendanceController>().addGuest(
                      matchId: _match.id!,
                      name: nameController.text.trim(),
                      position: '',
                    );
                await _loadAttendances();
              } catch (_) {
                Globals.showError(context, 'Erro ao adicionar avulso.');
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTeamDistribution() async {
    if (_confirmed.isEmpty) {
      Globals.showError(context, 'Não há jogadores confirmados para distribuir.');
      return;
    }
    if (_teams.isEmpty) {
      Globals.showError(context, 'Esta partida não possui times cadastrados.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamDistributionScreen(
          matchId: _match.id!,
          confirmedPlayers: _confirmed,
          teams: _teams,
        ),
      ),
    );
    // Recarrega badges ao voltar, caso a distribuição tenha mudado
    await _loadAssignments();
  }

  Future<void> _editMatch() async {
    final updated = await showEditMatchDialog(context, _match);
    if (updated == null || !mounted) return;

    // Se o status mudou, redireciona para a tela correta via roteador.
    // Se não mudou, apenas atualiza o estado local.
    if (updated.status != _match.status) {
      MatchDetailRouter.replace(context, updated);
    } else {
      setState(() => _match = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = (context.watch<UserController>().value?.isAdmin ?? false) &&
        _match.status == 'scheduled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.group_outlined),
              tooltip: 'Distribuir times',
              onPressed: _openTeamDistribution,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar partida',
              onPressed: _editMatch,
            ),
          ],
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: _showAddGuestDialog,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Avulso'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: matchHeaderWidget(context, _match)),

                  // ── Confirmados ─────────────────────────────────────────
                  AttendanceSection(
                    icon: Icons.check_circle_outlined,
                    color: Colors.green,
                    title: 'Confirmados',
                    players: _confirmed,
                    teamAssignments: _teamAssignments,
                    teams: _teams,
                    trailingBuilder: canEdit
                        ? (p) => _menuButton(p, isConfirmed: true)
                        : null,
                  ),

                  // ── Ausentes ────────────────────────────────────────────
                  AttendanceSection(
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    title: 'Ausentes',
                    players: _declined,
                    trailingBuilder: canEdit
                        ? (p) => _menuButton(p, isConfirmed: false)
                        : null,
                  ),

                  // ── Pendentes ───────────────────────────────────────────
                  AttendanceSection(
                    icon: Icons.hourglass_empty_outlined,
                    color: Colors.orange,
                    title: 'Pendentes',
                    players: _pending,
                    trailingBuilder: canEdit
                        ? (p) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  tooltip: 'Confirmar',
                                  onPressed: () =>
                                      _toggleAttendance(p, true),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  tooltip: 'Recusar',
                                  onPressed: () =>
                                      _toggleAttendance(p, false),
                                ),
                              ],
                            )
                        : null,
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _menuButton(Player player, {required bool isConfirmed}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'toggle') _toggleAttendance(player, !isConfirmed);
        if (value == 'remove') _removeAttendance(player);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isConfirmed ? Icons.close : Icons.check,
                size: 18,
                color: isConfirmed ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(isConfirmed ? 'Marcar ausente' : 'Marcar presente'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Remover'),
            ],
          ),
        ),
      ],
    );
  }
}