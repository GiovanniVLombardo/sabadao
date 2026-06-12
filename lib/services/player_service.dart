import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sabadao/models/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Player> createPlayer({
    required String userId,
    required Player player,
  }) async {
    try {
      final data = await _supabase
          .from('players')
          .insert({
            'user_id': userId,
            'name': player.name,
            'nickname': player.nickname,
            'position': player.position,
            'preferred_foot': player.preferredFoot,
            'birth_date': player.birthDate?.toIso8601String(),
          })
          .select() // retorna as colunas inseridas
          .single(); // garante um único Map<String, dynamic>

      return Player.fromJson(data);
    } catch (e) {
      debugPrint('Error creating player: $e');
    }

    return Future.error('Failed to create player');
  }

  Future<Player?> getPlayerByUserId(String userId) async {
    final data = await _supabase
        .from('players')
        .select()
        .eq('user_id', userId)
        .maybeSingle(); // retorna null se não encontrar, em vez de lançar

    if (data == null) return null;

    return Player.fromJson(data);
  }

  Future<Player?> getPlayerById(String playerId) async {
    final data = await _supabase
        .from('players')
        .select()
        .eq('id', playerId)
        .maybeSingle(); // retorna null se não encontrar, em vez de lançar

    if (data == null) return null;

    return Player.fromJson(data);
  }

  Future<Player> updatePlayer({
    required String? playerId,
    required Map<String, dynamic> fields,
  }) async {
    final data = await _supabase
        .from('players')
        .update(fields)
        .eq('id', playerId!)
        .select()
        .single();

    return Player.fromJson(data);
  }

  Future<void> deletePlayer(String playerId) async {
    await _supabase.from('players').delete().eq('id', playerId);
  }

  Future<String> uploadAvatar(String playerId, File image) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileExtension = image.path.split('.').last;
    final path = '$userId/avatar.$fileExtension';

    // 1. Upload para o Storage (upsert substitui foto anterior)
    await _supabase.storage
        .from('avatars')
        .upload(path, image, fileOptions: const FileOptions(upsert: true));

    // 2. Gerar URL pública
    final String publicUrl = _supabase.storage
        .from('avatars')
        .getPublicUrl(path);

    // 3. Persistir URL na tabela profiles
    await _supabase
        .from('players')
        .update({'avatar_url': publicUrl})
        .eq('user_id', userId);

    return publicUrl;
  }

  // ── Remover avatar ───────────────────────────────────────────────────────────

  /// Remove o arquivo do Storage e limpa a URL na tabela `profiles`.
  Future<void> removeAvatar(String playerId) async {
    final userId = _supabase.auth.currentUser!.id;

    // Lista arquivos do usuário para apagar independente da extensão
    final List<FileObject> files = await _supabase.storage
        .from('avatars')
        .list(path: userId);

    if (files.isNotEmpty) {
      final paths = files.map((f) => '$userId/${f.name}').toList();
      await _supabase.storage.from('avatars').remove(paths);
    }

    // Limpa a URL no banco
    await _supabase
        .from('players')
        .update({'avatar_url': ''})
        .eq('user_id', userId);
  }
}
