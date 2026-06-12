class Attendance {
  final String id;
  final String matchId;
  final String playerId;
  final bool isConfirmed;

  const Attendance({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.isConfirmed,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      playerId: json['player_id'] as String,
      isConfirmed: json['is_confirmed'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'match_id': matchId,
    'player_id': playerId,
    'is_confirmed': isConfirmed,
  };
}