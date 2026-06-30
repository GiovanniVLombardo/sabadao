class TeamScore {
  final int teamId;
  final String teamName;
  final String? acronym;
  final String? color;
  int score;
 
  TeamScore({
    required this.teamId,
    required this.teamName,
    this.acronym,
    this.color,
    this.score = 0,
  });
}