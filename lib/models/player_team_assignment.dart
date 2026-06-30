/// Associação local entre um jogador e um time dentro de uma partida.
///
/// Não é persistido diretamente — é usado em memória pela
/// [TeamDistributionScreen] para montar o estado do drag-and-drop.
/// A persistência acontece via [ScoutService.savePlayerAssignments].
class PlayerTeamAssignment {
  final String playerId;

  /// `null` significa que o jogador ainda não foi distribuído.
  int? teamId;

  PlayerTeamAssignment({required this.playerId, this.teamId});
}