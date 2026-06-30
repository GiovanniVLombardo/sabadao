import 'package:flutter/material.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/services/match_service.dart';

class MatchController extends ValueNotifier<List<Match>> {
  final MatchService _matchService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MatchController({MatchService? matchService})
    : _matchService = matchService ?? MatchService(),
      super([]);

  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      value = await _matchService.getMatches();
    } catch (_) {
      value = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Match> createMatch({
    required Match match
  }) async {
    final _match = await _matchService.createMatch(
      matchDate: match.matchDate,
      location: match.location,
    );
    if(match.team1Id != null && match.team2Id != null){
      await _matchService.insertMatchTeam(matchId: _match.id!, teamId: match.team1Id!);
      await _matchService.insertMatchTeam(matchId: _match.id!, teamId: match.team2Id!);
    }
    value = [_match, ...value];
    return match;
  }

  Future<Match> updateMatch({
    required String matchId,
    required DateTime matchDate,
    required String status,
    String location = '',
  }) async {
    final updated = await _matchService.updateMatch(
      matchId: matchId,
      matchDate: matchDate,
      location: location,
      status: status,
    );
    value = [for (final m in value) m.id == matchId ? updated : m];
    return updated;
  }

  Future<void> deleteMatch(String matchId) async {
    await _matchService.deleteMatch(matchId);
    value = value.where((m) => m.id != matchId).toList();
  }
}
