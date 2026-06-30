import 'package:flutter/cupertino.dart';
import 'package:sabadao/models/team.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Team>> getTeams() async {
    final response = await _supabase
        .from('teams')
        .select();

    debugPrint('Times: $response');

    return (response as List<dynamic>)
        .map((item) => Team.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Team> getTeamById(String id) async {
    final response = await _supabase
        .from('teams')
        .select()
        .eq('id', id);

    return Team.fromMap(response as Map<String, dynamic>);
  }

  Future<List<Team>> getMatchTeams(String matchId) async {
    final response = await _supabase
        .from('match_teams')
        .select()
        .eq('match_id', matchId);

    return (response as List<dynamic>)
        .map((item) => Team.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}