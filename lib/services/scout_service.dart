import 'package:sabadao/models/player_ranking.dart';
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
}