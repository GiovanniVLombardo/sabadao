import 'package:flutter/foundation.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/player_ranking.dart';
import 'package:sabadao/models/scout_entry.dart';
import 'package:sabadao/models/team_score.dart';
import '../services/scout_service.dart';

enum RankingFilter { goals, wins, winRate }

class ScoutController extends ValueNotifier<List<ScoutEntry>> {
  final ScoutService _service;
  List<TeamScore> _teams = [];
 
  List<TeamScore> get teams => _teams;

  ScoutController({ScoutService? service})
      : _service = service ?? ScoutService(),
        super([]);

  List<PlayerRanking> _ranking = [];
  RankingFilter _currentFilter = RankingFilter.goals;
  bool _isLoading = false;
  String? _error;

  // ranking já ordenado conforme o filtro ativo — usado pela RankingScreen
  List<PlayerRanking> get sortedRanking => _sorted(_ranking);
  // mantido para compatibilidade com outros lugares que usem ctrl.ranking
  List<PlayerRanking> get ranking => _ranking;

  RankingFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> loadRanking() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ranking = await _service.getRanking();
    } catch (e) {
      _error = 'Erro ao carregar ranking: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(RankingFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    notifyListeners();
  }

  List<PlayerRanking> _sorted(List<PlayerRanking> list) {
    final copy = List<PlayerRanking>.from(list);

    switch (_currentFilter) {
      case RankingFilter.goals:
        // primário: gols — desempate: vitórias
        copy.sort((a, b) {
          final c = b.goals.compareTo(a.goals);
          return c != 0 ? c : b.wins.compareTo(a.wins);
        });

      case RankingFilter.wins:
        // primário: vitórias — desempate: aproveitamento
        copy.sort((a, b) {
          final c = b.wins.compareTo(a.wins);
          return c != 0 ? c : _compareWinRate(b, a);
        });

      case RankingFilter.winRate:
        // primário: aproveitamento — desempate: nº de partidas (mais jogos = mais relevante)
        // jogadores sem partidas vão para o final
        copy.sort((a, b) {
          final c = _compareWinRate(b, a);
          return c != 0 ? c : b.matchesPlayed.compareTo(a.matchesPlayed);
        });
    }

    return copy;
  }

  /// Compara aproveitamento tratando null como -1 (vai para o fim da lista).
  int _compareWinRate(PlayerRanking a, PlayerRanking b) {
    final rateA = a.winRate ?? -1;
    final rateB = b.winRate ?? -1;
    return rateA.compareTo(rateB);
  }

  Future<PlayerRanking> getUserScout(String playerId) async {
    return  await _service.getUserScout(playerId);
  }

  Future<void> loadMatchData(
    String matchId,
    List<Player> confirmedPlayers,
  ) async {
    _teams = await _service.getMatchTeams(matchId);
    value = await _service.getMatchScouts(matchId, confirmedPlayers);
  }
 
  Future<void> updateTeamScore({
    required String matchId,
    required int teamId,
    required int score,
  }) async {
    await _service.updateTeamScore(
      matchId: matchId,
      teamId: teamId,
      score: score,
    );
    final idx = _teams.indexWhere((t) => t.teamId == teamId);
    if (idx != -1) {
      _teams[idx].score = score;
      notifyListeners();
    }
  }
 
  Future<void> upsertScout({
    required String matchId,
    required String playerId,
    required int goals,
    required int assists,
  }) async {
    await _service.upsertScout(
      matchId: matchId,
      playerId: playerId,
      goals: goals,
      assists: assists,
    );
    final idx = value.indexWhere((e) => e.playerId == playerId);
    if (idx != -1) {
      value[idx].goals = goals;
      value[idx].assists = assists;
      // re-sort by goals then assists
      final sorted = List<ScoutEntry>.from(value)
        ..sort((a, b) {
          final byGoals = b.goals.compareTo(a.goals);
          return byGoals != 0 ? byGoals : b.assists.compareTo(a.assists);
        });
      value = sorted;
    }
  }
}