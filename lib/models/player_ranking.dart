class PlayerRanking {
  final String playerId;
  final String name;
  final String? nickname;
  final String? avatarUrl;
  final String position;

  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goals;
  final int assists;
  final double? winRate;

  PlayerRanking({
    required this.playerId,
    required this.name,
    this.nickname,
    this.avatarUrl,
    required this.position,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goals,
    required this.assists,
    this.winRate,
  });

  factory PlayerRanking.fromMap(Map<String, dynamic> map) {
    return PlayerRanking(
      playerId: map['player_id'] as String,
      name: map['name'] as String,
      nickname: map['nickname'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      position: map['position'] as String? ?? '',
      matchesPlayed: (map['matches_played'] as num?)?.toInt() ?? 0,
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      draws: (map['draws'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      goals: (map['goals'] as num?)?.toInt() ?? 0,
      assists: (map['assists'] as num?)?.toInt() ?? 0,
      winRate: (map['win_rate'] as num?)?.toDouble(),
    );
  }

  /// Exibe apelido se disponível, senão o nome
  String get displayName => nickname?.isNotEmpty == true ? nickname! : name;

  /// Aproveitamento formatado como porcentagem (ex: "73%")
  String get winRateFormatted {
    if (winRate == null) return '—';
    return '${(winRate! * 100).round()}%';
  }

  int get totalContributions => goals + assists;
}