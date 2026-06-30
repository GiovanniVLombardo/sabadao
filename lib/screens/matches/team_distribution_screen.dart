import 'package:flutter/material.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/team_score.dart';
import 'package:sabadao/services/scout_service.dart';
import 'package:sabadao/utils/globals.dart';

/// Tela de distribuição de jogadores nos times via drag-and-drop.
///
/// Recebe os [confirmedPlayers] e os [teams] da partida.
/// Cada jogador começa na coluna "Sem time" a menos que já tenha uma
/// distribuição salva no banco. O botão "Salvar" só fica ativo quando
/// todos os jogadores tiverem um time (sem coluna "Sem time" vazia).
class TeamDistributionScreen extends StatefulWidget {
  final String matchId;
  final List<Player> confirmedPlayers;
  final List<TeamScore> teams;

  const TeamDistributionScreen({
    super.key,
    required this.matchId,
    required this.confirmedPlayers,
    required this.teams,
  });

  @override
  State<TeamDistributionScreen> createState() =>
      _TeamDistributionScreenState();
}

class _TeamDistributionScreenState extends State<TeamDistributionScreen> {
  // null = sem time; teamId = distribuído
  final Map<String, int?> _assignments = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssignments());
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    try {
      final saved =
          await ScoutService().getPlayerAssignments(widget.matchId);

      // Inicializa todos com null, depois sobrescreve com o que veio do banco
      for (final p in widget.confirmedPlayers) {
        _assignments[p.id!] = saved[p.id];
      }
    } catch (e) {
      Globals.showError(context, 'Erro ao carregar distribuição. $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    // Garante que todos têm time antes de salvar
    if (_assignments.values.any((v) => v == null)) return;

    setState(() => _isSaving = true);
    try {
      await ScoutService().savePlayerAssignments(
        matchId: widget.matchId,
        assignments: _assignments.map((k, v) => MapEntry(k, v!)),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Distribuição salva!')),
        );
        Navigator.pop(context, true); // retorna true = houve alteração
      }
    } catch (e) {
      Globals.showError(context, 'Erro ao salvar distribuição. $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Jogadores de uma coluna específica (null = sem time).
  List<Player> _playersForTeam(int? teamId) => widget.confirmedPlayers
      .where((p) => _assignments[p.id] == teamId)
      .toList();

  bool get _allAssigned => _assignments.values.every((v) => v != null);

  Color _teamColor(TeamScore team) {
    if (team.color == null) return Colors.blueGrey;
    try {
      return Color(
        int.parse(team.color!.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuir Times'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _allAssigned ? _save : null,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Banner de validação ──────────────────────────────────
                if (!_allAssigned)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Distribua todos os jogadores para salvar',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),

                // ── Colunas de times ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    children: [
                      // Coluna "Sem time" — sempre a primeira
                      _TeamColumn(
                        label: 'Sem time',
                        color: Colors.grey,
                        players: _playersForTeam(null),
                        teamId: null,
                        allTeams: widget.teams,
                        onAccept: (player) => setState(
                          () => _assignments[player.id!] = null,
                        ),
                      ),

                      // Uma coluna por time
                      for (final team in widget.teams)
                        _TeamColumn(
                          label: team.acronym ?? team.teamName,
                          color: _teamColor(team),
                          players: _playersForTeam(team.teamId),
                          teamId: team.teamId,
                          allTeams: widget.teams,
                          onAccept: (player) => setState(
                            () => _assignments[player.id!] = team.teamId,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Coluna de time ─────────────────────────────────────────────────────────────

class _TeamColumn extends StatelessWidget {
  final String label;
  final Color color;
  final int? teamId;
  final List<Player> players;
  final List<TeamScore> allTeams;
  final void Function(Player player) onAccept;

  const _TeamColumn({
    required this.label,
    required this.color,
    required this.teamId,
    required this.players,
    required this.allTeams,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Player>(
      onWillAcceptWithDetails: (details) =>
          // Só aceita se o jogador não está já nessa coluna
          details.data.id != null &&
          !players.any((p) => p.id == details.data.id),
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 180,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cabeçalho da coluna ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${players.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cards draggable dos jogadores ────────────────────────
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Text(
                          'Arraste\njogadores aqui',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: players.length,
                        itemBuilder: (_, i) =>
                            _PlayerDraggable(player: players[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Card draggable de jogador ──────────────────────────────────────────────────

class _PlayerDraggable extends StatelessWidget {
  final Player player;

  const _PlayerDraggable({required this.player});

  @override
  Widget build(BuildContext context) {
    final card = _PlayerCard(player: player);

    return Draggable<Player>(
      data: player,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 164, child: _PlayerCard(player: player)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}

// ── Card visual do jogador ─────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final Player player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = player.avatarUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: CircleAvatar(
          radius: 16,
          backgroundImage:
              hasAvatar ? NetworkImage(player.avatarUrl) : null,
          child: hasAvatar
              ? null
              : Text(
                  (player.nickname?.isNotEmpty == true
                          ? player.nickname![0]
                          : player.name[0])
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
        ),
        title: Text(
          player.nickname ?? player.name,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          player.position,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}