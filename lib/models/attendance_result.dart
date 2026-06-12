import 'package:sabadao/models/player.dart';

class AttendanceResult {
  final List<Player> confirmed;
  final List<Player> declined;
  final List<Player> pending;

  const AttendanceResult({
    required this.confirmed,
    required this.declined,
    required this.pending,
  });
}