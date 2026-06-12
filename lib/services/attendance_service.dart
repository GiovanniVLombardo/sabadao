import 'package:flutter/material.dart';
import 'package:sabadao/models/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabadao/models/attendance.dart';

import '../models/attendance_result.dart';

class AttendanceService {
  final _supabase = Supabase.instance.client;
  static const int _maxSpots = 18;

  Future<AttendanceResult> getAttendances(String matchId) async {
    // Busca todos os jogadores ativos
    final playersData = await _supabase
        .from('players')
        .select()
        .eq('is_active', true)
        .order('name');

    debugPrint('PlayersData $playersData');

    // Busca os registros de attendance da partida
    final attendancesData = await _supabase
        .from('attendances')
        .select()
        .eq('match_id', matchId);

    final allPlayers =
        (playersData as List).map((e) => Player.fromJson(e)).toList();

    final attendanceMap = {
      for (final a in attendancesData as List)
        a['player_id'] as String: a['is_confirmed'] as bool,
    };

    final confirmed = <Player>[];
    final declined = <Player>[];
    final pending = <Player>[];

    for (final player in allPlayers) {
      if (!attendanceMap.containsKey(player.id)) {
        pending.add(player);
      } else if (attendanceMap[player.id] == true) {
        confirmed.add(player);
      } else {
        declined.add(player);
      }
    }

    return AttendanceResult(
      confirmed: confirmed,
      declined: declined,
      pending: pending,
    );
  }

  // Confirma ou cancela presença usando upsert.
  // A constraint única (match_id, player_id) garante que não haverá duplicatas.
  Future<Attendance> confirmPresence({
    required String matchId,
    required String playerId,
    required bool isConfirmed,
  }) async {
    final data = await _supabase
        .from('attendances')
        .upsert(
          {
            'match_id': matchId,
            'player_id': playerId,
            'is_confirmed': isConfirmed,
          },
          onConflict: 'match_id,player_id',
        )
        .select()
        .single();

    return Attendance.fromJson(data);
  }

  // Retorna o RSVP atual do jogador para uma partida.
  // Retorna null se ele ainda não respondeu.
  Future<bool?> getPlayerRsvp({
    required String matchId,
    required String playerId,
  }) async {
    final data = await _supabase
        .from('attendances')
        .select('is_confirmed')
        .eq('match_id', matchId)
        .eq('player_id', playerId)
        .maybeSingle();

    return data?['is_confirmed'] as bool?;
  }

  // Vagas restantes: 18 - confirmados.
  // Migrado do MatchService — pertence aqui por coesão de domínio.
  Future<int> getAvailableSpots(String matchId) async {
    try {
      final data = await _supabase
          .from('attendances')
          .select('id')
          .eq('match_id', matchId)
          .eq('is_confirmed', true);

      return (_maxSpots - (data as List).length).clamp(0, _maxSpots);
    } catch (_) {
      return _maxSpots;
    }
  }

  Future<void> insertAttendance({
    required String matchId,
    required String playerId,
    required bool isConfirmed,
  }) async {
    await _supabase.from('attendances').upsert(
      {
        'match_id': matchId,
        'player_id': playerId,
        'is_confirmed': isConfirmed,
      },
      onConflict: 'match_id,player_id',
    );
  }

  Future<void> deleteAttendance({
    required String matchId,
    required String playerId,
  }) async {
    await _supabase
        .from('attendances')
        .delete()
        .eq('match_id', matchId)
        .eq('player_id', playerId);
  }

  Future<void> addGuest({
    required String matchId,
    required String name,
    required String position,
  }) async {
    // Cria o jogador avulso
    final playerData = await _supabase
        .from('players')
        .insert({
          'name': name,
          'position': position,
          'is_guest': true,
        })
        .select()
        .single();

    // Já confirma presença na partida
    await insertAttendance(
      matchId: matchId,
      playerId: playerData['id'] as String,
      isConfirmed: true,
    );
  }
}