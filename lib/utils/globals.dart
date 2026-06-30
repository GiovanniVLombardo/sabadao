import 'package:flutter/material.dart';

class Globals {
  static String statusLabel(String status) => switch (status) {
    'scheduled' => 'Agendada',
    'ongoing' => 'Em andamento',
    'finished' => 'Finalizada',
    'cancelled' => 'Cancelada',
    _ => status,
  };

  static Color statusColor(String status) => switch (status) {
    'scheduled' => Colors.blue,
    'ongoing' => Colors.green,
    'finished' => Colors.grey,
    'cancelled' => Colors.red,
    _ => Colors.grey,
  };

  static void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }
}
