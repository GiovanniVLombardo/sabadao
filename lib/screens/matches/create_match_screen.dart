import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/controllers/match_controller.dart';
import 'package:sabadao/controllers/team_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/models/team.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _matchDateController = TextEditingController();

  DateTime? _matchDate;
  Team? _selectedTeam1;
  Team? _selectedTeam2;
  bool _isLoading = false;

  // Populated by loading teams from the repository/controller
  List<Team> _teams = [];
  bool _loadingTeams = true;
  bool _teamsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_teamsLoaded) {
      _teamsLoaded = true;
      // aguarda o frame atual terminar antes de executar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTeams();
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _matchDateController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await context.read<TeamController>().getTeams();
      if (mounted) setState(() => _teams = teams);
    } catch (e) {
      debugPrint('Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar times. Tente novamente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  Future<void> _selectMatchDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _matchDate = fullDateTime;
      _matchDateController.text = DateFormat(
        "dd/MM/yyyy 'às' HH:mm",
      ).format(fullDateTime);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final match = Match(
      matchDate: _matchDate!,
      location: _locationController.text.trim(),
      team1Id: _selectedTeam1!.id,
      team2Id: _selectedTeam2!.id,
      status: 'scheduled',
    );

    try {
      await context.read<MatchController>().createMatch(match: match);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partida criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar partida. Tente novamente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Partida')),
      body: _loadingTeams
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Preencha os dados da partida.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),

                        // Data e horário da partida
                        TextFormField(
                          controller: _matchDateController,
                          readOnly: true,
                          onTap: _selectMatchDate,
                          decoration: const InputDecoration(
                            labelText: 'Data e Horário',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Selecione a data e o horário'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Local
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Local',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.place_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Insira o local da partida'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Time 1
                        DropdownButtonFormField<Team>(
                          decoration: const InputDecoration(
                            labelText: 'Time 1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shield_outlined),
                          ),
                          items: _teams
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: _TeamDropdownItem(team: t),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedTeam1 = v),
                          validator: (v) =>
                              v == null ? 'Selecione o Time 1' : null,
                        ),
                        const SizedBox(height: 16),

                        // Divisor "VS"
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'VS',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Time 2
                        DropdownButtonFormField<Team>(
                          decoration: const InputDecoration(
                            labelText: 'Time 2',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shield_outlined),
                          ),
                          items: _teams
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: _TeamDropdownItem(team: t),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedTeam2 = v),
                          validator: (v) {
                            if (v == null) return 'Selecione o Time 2';
                            if (v.id == _selectedTeam1?.id) {
                              return 'Escolha um time diferente do Time 1';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Botão salvar
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Criar Partida',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Widget auxiliar que exibe o nome e a sigla/cor do time no dropdown.
class _TeamDropdownItem extends StatelessWidget {
  final Team team;
  const _TeamDropdownItem({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (team.color != '')
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _hexToColor(team.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1),
            ),
          ),
        Text(team.name),
        if (team.acronym != '') ...[
          const SizedBox(width: 6),
          Text(
            '(${team.acronym})',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Color _hexToColor(String hex) {
    final sanitized = hex.replaceAll('#', '');
    final value = int.tryParse('FF$sanitized', radix: 16);
    return value != null ? Color(value) : Colors.grey;
  }
}
