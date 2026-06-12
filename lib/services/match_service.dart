import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';

class MatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Match>> getMatches() async {
    final data = await _supabase
        .from('matches')
        .select()
        .order('match_date', ascending: true)
        .limit(10);

    return (data as List).map((json) => Match.fromJson(json)).toList();
  }

  Future<List<Match>> getMatchesForPlayer(String playerId) async {
    final data = await _supabase.from('matches').select().contains(
      'player_ids',
      [playerId],
    );

    return (data as List).map((json) => Match.fromJson(json)).toList();
  }

  Future<Match> createMatch({
    required DateTime matchDate,
    required String location,
  }) async {
    final data = await _supabase
        .from('matches')
        .insert({
          'match_date': matchDate.toIso8601String(),
          'location': location
        })
        .select()
        .single();

    return Match.fromJson(data);
  }

  Future<Match> updateMatch({
    required String matchId,
    required DateTime matchDate,
    required String status,
    String location = ''
  }) async {
    final data = await _supabase
        .from('matches')
        .update({'status': status})
        .eq('id', matchId)
        .select()
        .single();

    return Match.fromJson(data);
  }

  Future<void> deleteMatch(String matchId) async {
    await _supabase.from('matches').delete().eq('id', matchId);
  }

  Future<List<Match>> getUpcomingMatches() async {
    final data = await _supabase
        .from('matches')
        .select()
        .eq('status', 'scheduled')
        .order('match_date', ascending: true);

    return (data as List).map((json) => Match.fromJson(json)).toList();
  }

  Future<List<Match>> getFinishedMatches() async {
    final data = await _supabase
        .from('matches')
        .select()
        .eq('status', 'finished')
        .order('match_date', ascending: true);

    return (data as List).map((json) => Match.fromJson(json)).toList();
  }
}
