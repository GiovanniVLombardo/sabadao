import 'package:flutter/cupertino.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/models/player_ranking.dart';
import 'package:sabadao/models/scout_entry.dart';
import 'package:sabadao/models/team_score.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoutService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca o ranking completo a partir da view player_stats.
  /// Ordenação: gols DESC, vitórias DESC, assistências DESC.
  Future<List<PlayerRanking>> getRanking() async {
    final response = await _supabase
        .from('player_stats')
        .select()
        .order('goals', ascending: false)
        .order('wins', ascending: false)
        .order('assists', ascending: false);

    return (response as List<dynamic>)
        .map((item) => PlayerRanking.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<PlayerRanking> getUserScout(String playerId) async {
    final response = await _supabase
        .from('player_stats')
        .select()
        .eq('player_id', playerId)
        .order('goals', ascending: false)
        .order('wins', ascending: false)
        .order('assists', ascending: false);

    return PlayerRanking.fromMap(response as Map<String, dynamic>);
  }

  /// Busca times e placar da partida
  Future<List<TeamScore>> getMatchTeams(String matchId) async {
    final response = await _supabase
        .from('match_teams')
        .select('team_id, score, teams(name, acronym, color)')
        .eq('match_id', matchId);

    debugPrint('Buscando MatchTeams: $response');

    return (response as List).map((row) {
      final team = row['teams'] as Map<String, dynamic>;
      return TeamScore(
        teamId: row['team_id'] as int,
        teamName: team['name'] as String,
        acronym: team['acronym'] as String?,
        color: team['color'] as String?,
        score: row['score'] as int,
      );
    }).toList();
  }

  /// Busca scouts (gols/assistências) dos jogadores confirmados na partida
  Future<List<ScoutEntry>> getMatchScouts(
    String matchId,
    List<Player> confirmedPlayers,
  ) async {
    // Busca scouts existentes no banco
    final response = await _supabase
        .from('scouts')
        .select('player_id, goals, assists')
        .eq('match_id', matchId);

    final existingMap = <String, Map<String, dynamic>>{};
    for (final row in response as List) {
      existingMap[row['player_id'] as String] = row;
    }

    // Mescla com jogadores confirmados — garante que todos apareçam
    return confirmedPlayers.map((player) {
      final existing = existingMap[player.id];
      return ScoutEntry(
        playerId: player.id!,
        playerName: player.name,
        playerNickname: player.nickname,
        avatarUrl: player.avatarUrl,
        goals: existing?['goals'] as int? ?? 0,
        assists: existing?['assists'] as int? ?? 0,
      );
    }).toList()..sort((a, b) {
      final byGoals = b.goals.compareTo(a.goals);
      return byGoals != 0 ? byGoals : b.assists.compareTo(a.assists);
    });
  }

  /// Atualiza o placar de um time
  Future<void> updateTeamScore({
    required String matchId,
    required int teamId,
    required int score,
  }) async {
    await _supabase
        .from('match_teams')
        .update({'score': score})
        .eq('match_id', matchId)
        .eq('team_id', teamId);
  }

  /// Upsert de gols/assistências de um jogador
  Future<void> upsertScout({
    required String matchId,
    required String playerId,
    required int goals,
    required int assists,
  }) async {
    await _supabase.from('scouts').upsert({
      'match_id': matchId,
      'player_id': playerId,
      'goals': goals,
      'assists': assists,
    }, onConflict: 'match_id,player_id');
  }

  /// Remove scout de um jogador
  Future<void> removeScout({
    required String matchId,
    required String playerId,
  }) async {
    await _supabase
        .from('scouts')
        .delete()
        .eq('match_id', matchId)
        .eq('player_id', playerId);
  }

  /// Retorna um mapa { playerId → teamId } com as distribuições já salvas.
  /// Somente jogadores confirmados com team_id preenchido aparecem no mapa.
  Future<Map<String, int>> getPlayerAssignments(String matchId) async {
    final response = await _supabase
        .from('attendances')
        .select('player_id, team_id')
        .eq('match_id', matchId)
        .eq('is_confirmed', true)
        .not('team_id', 'is', null);

    return {
      for (final row in response as List)
        row['player_id'] as String: row['team_id'] as int,
    };
  }

  /// Salva a distribuição de times atualizando a coluna team_id em attendances.
  /// Faz um update individual por jogador usando a constraint única
  /// (match_id, player_id) — sem criar nenhuma linha nova.
  ///
  /// [assignments] é um mapa { playerId → teamId }.
  Future<void> savePlayerAssignments({
    required String matchId,
    required Map<String, int> assignments,
  }) async {
    // Executa os updates em paralelo — attendances já tem a linha de cada
    // jogador confirmado; só precisamos setar o team_id.
    await Future.wait(
      assignments.entries.map(
        (e) => _supabase
            .from('attendances')
            .update({'team_id': e.value})
            .eq('match_id', matchId)
            .eq('player_id', e.key),
      ),
    );
  }
}
