import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/controllers/match_controller.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/utils/globals.dart';

/// Exibe o dialog de edição de partida e retorna o [Match] atualizado,
/// ou `null` se o usuário cancelar ou ocorrer um erro.
///
/// Após salvar, o chamador deve usar o valor retornado para redirecionar
/// pela rota correta (ex.: via [MatchDetailRouter]) caso o status tenha mudado.
Future<Match?> showEditMatchDialog(
  BuildContext context,
  Match match,
) async {
  final locationController = TextEditingController(text: match.location);
  DateTime selectedDate = match.matchDate;
  String selectedStatus = match.status;
  final formKey = GlobalKey<FormState>();

  // Captura o controller ANTES de abrir o dialog, enquanto o context
  // da tela ainda é válido. Isso evita usar context depois que o dialog
  // já foi fechado e sua árvore de widgets desmontada.
  final matchController = context.read<MatchController>();

  return showDialog<Match>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Editar Partida'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Local ──────────────────────────────────────────────────
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Local',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Data / hora ────────────────────────────────────────────
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

              // ── Status ─────────────────────────────────────────────────
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
                        child: Text(Globals.statusLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedStatus = v ?? selectedStatus),
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
              // Mostra loading no botão enquanto salva
              setDialogState(() {});

              try {
                final updated = await matchController.updateMatch(
                  matchId: match.id!,
                  matchDate: selectedDate,
                  location: locationController.text.trim(),
                  status: selectedStatus,
                );
                // Fecha o dialog passando o Match atualizado como resultado.
                // O Navigator.pop ocorre DEPOIS do await, garantindo que
                // o valor seja retornado corretamente para o showDialog<Match>.
                if (ctx.mounted) Navigator.pop(ctx, updated);
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Globals.showError(context, 'Erro ao atualizar partida. $e');
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );
}