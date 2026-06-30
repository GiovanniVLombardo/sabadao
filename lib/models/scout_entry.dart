class ScoutEntry {
  final String playerId;
  final String playerName;
  final String? playerNickname;
  final String? avatarUrl;
  int goals;
  int assists;
 
  ScoutEntry({
    required this.playerId,
    required this.playerName,
    this.playerNickname,
    this.avatarUrl,
    this.goals = 0,
    this.assists = 0,
  });
 
  String get displayName => playerNickname ?? playerName;
}