import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/controllers/attendance_controller.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/controllers/match_controller.dart';
import 'package:sabadao/screens/profile/profile_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late Match _match;
  List<Player> _confirmed = [];
  List<Player> _declined = [];
  List<Player> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAttendances());
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<AttendanceController>();
      final result = await controller.getAttendances(_match.id);
      setState(() {
        _confirmed = result.confirmed;
        _declined = result.declined;
        _pending = result.pending;
      });
    } catch (e) {
      debugPrint('$e');
      _showError('Erro ao carregar presenças. $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAttendance(Player player, bool confirm) async {
    try {
      await context.read<AttendanceController>().setAttendance(
        matchId: _match.id,
        playerId: player.id!,
        isConfirmed: confirm,
      );
      await _loadAttendances();
    } catch (e) {
      _showError('Erro ao atualizar presença. $e');
    }
  }

  Future<void> _removeAttendance(Player player) async {
    try {
      await context.read<AttendanceController>().removeAttendance(
        matchId: _match.id,
        playerId: player.id!,
      );
      await _loadAttendances();
    } catch (_) {
      _showError('Erro ao remover presença.');
    }
  }

  Future<void> _showAddGuestDialog() async {
    final nameController = TextEditingController();
    final positionController = TextEditingController();
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
                  matchId: _match.id,
                  name: nameController.text.trim(),
                  position: positionController.text.trim(),
                );
                await _loadAttendances();
              } catch (_) {
                _showError('Erro ao adicionar avulso.');
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMatchDialog() async {
    final locationController = TextEditingController(text: _match.location);
    DateTime selectedDate = _match.matchDate;
    String selectedStatus = _match.status;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar Partida'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(selectedDate),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time == null) return;
                    setDialogState(() {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['scheduled', 'ongoing', 'finished', 'cancelled']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(_statusLabel(s)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(
                    () => selectedStatus = v ?? selectedStatus,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final updated = await context
                      .read<MatchController>()
                      .updateMatch(
                        matchId: _match.id,
                        matchDate: selectedDate,
                        location: locationController.text.trim(),
                        status: selectedStatus,
                      );
                  setState(() => _match = updated);
                } catch (_) {
                  _showError('Erro ao atualizar partida.');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'scheduled' => 'Agendada',
    'ongoing' => 'Em andamento',
    'finished' => 'Finalizada',
    'cancelled' => 'Cancelada',
    _ => status,
  };

  Color _statusColor(String status) => switch (status) {
    'scheduled' => Colors.blue,
    'ongoing' => Colors.green,
    'finished' => Colors.grey,
    'cancelled' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserController>().value?.isAdmin ?? false;
    final canEdit = isAdmin && _match.status == 'scheduled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar partida',
              onPressed: _showEditMatchDialog,
            ),
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
              onRefresh: _loadAttendances,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildMatchHeader()),
                  _buildSection(
                    icon: Icons.check_circle_outlined,
                    color: Colors.green,
                    title: 'Confirmados',
                    count: _confirmed.length,
                    players: _confirmed,
                    isAdmin: canEdit,
                    trailing: (player) => canEdit
                        ? _attendanceMenuButton(player, isConfirmed: true)
                        : null,
                  ),
                  _buildSection(
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    title: 'Ausentes',
                    count: _declined.length,
                    players: _declined,
                    isAdmin: canEdit,
                    trailing: (player) => canEdit
                        ? _attendanceMenuButton(player, isConfirmed: false)
                        : null,
                  ),
                  _buildSection(
                    icon: Icons.hourglass_empty_outlined,
                    color: Colors.orange,
                    title: 'Pendentes',
                    count: _pending.length,
                    players: _pending,
                    isAdmin: canEdit,
                    trailing: (player) => canEdit
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                tooltip: 'Confirmar',
                                onPressed: () =>
                                    _toggleAttendance(player, true),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                tooltip: 'Recusar',
                                onPressed: () =>
                                    _toggleAttendance(player, false),
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

  Widget _buildMatchHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  _statusLabel(_match.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: _statusColor(_match.status),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  "EEEE, dd/MM/yyyy",
                  'pt_BR',
                ).format(_match.matchDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat("HH:mm", 'pt_BR').format(_match.matchDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  _match.location,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _attendanceMenuButton(Player player, {required bool isConfirmed}) {
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

  SliverList _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required int count,
    required List<Player> players,
    required bool isAdmin,
    required Widget? Function(Player) trailing,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  '$title ($count)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: color),
                ),
              ],
            ),
          );
        }

        if (players.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Nenhum jogador',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          );
        }

        final player = players[index - 1];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: CircleAvatar(
            backgroundImage: player.avatarUrl != ''
                ? NetworkImage(player.avatarUrl)
                : null,
            child: player.avatarUrl == ''
                ? Text(
                    player.nickname?[0].toUpperCase() ??
                        player.name[0].toUpperCase(),
                  )
                : null,
          ),
          title: Text(player.nickname ?? player.name),
          subtitle: Text(player.position),
          trailing: trailing(player),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(playerId: player.id),
            ),
          ),
        );
      }, childCount: players.isEmpty ? 2 : players.length + 1),
    );
  }
}
