class Scout {
  final String id;
  final String matchId;
  final String playerId;
  final int goals;
  final int assists;

  const Scout({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.goals,
    required this.assists,
  });

  factory Scout.fromMap(Map<String, dynamic> map) {
    return Scout(
      id: map['id'] as String,
      matchId: map['match_id'] as String,
      playerId: map['player_id'] as String,
      goals: map['goals'] as int? ?? 0,
      assists: map['assists'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'player_id': playerId,
      'goals': goals,
      'assists': assists,
    };
  }
}

