import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sabadao/models/player.dart';
import 'package:sabadao/services/auth_service.dart';
import 'package:sabadao/services/player_service.dart';

class UserController extends ValueNotifier<Player?> {
  final AuthService _authService;
  final PlayerService _playerService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserController({AuthService? authService, PlayerService? playerService})
    : _authService = authService ?? AuthService(),
      _playerService = playerService ?? PlayerService(),
      super(null);

  bool get hasPlayer => value != null;

  /// Chamado pelo AuthGate após confirmar sessão ativa
  Future<void> loadPlayerProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      value = null;
      return;
    }
    if (value != null) return; // já está em memória

    _isLoading = true;
    notifyListeners();

    try {
      value = await _playerService.getPlayerByUserId(user.id);
    } catch (_) {
      value = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile(Player player) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final created = await _playerService.createPlayer(
      userId: user.id,
      player: player,
    );
    value = created; // notifica a árvore → AuthGate redireciona automaticamente
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    if (value == null) return;
    final updated = await _playerService.updatePlayer(
      playerId: value!.id,
      fields: fields,
    );
    value = updated;
  }

  void clearPlayer() {
    value = null;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> uploadAvatar(String playerId, File image) async {
    // Delega toda a lógica de Storage + DB para o PlayerService
    final String publicUrl = await _playerService.uploadAvatar(playerId, image);

    // Atualiza o estado local para a UI refletir imediatamente
    if (value != null) {
      value = value!.copyWith(avatarUrl: publicUrl);
      notifyListeners();
    }
  }

  Future<void> removeAvatar(String playerId) async {
    await _playerService.removeAvatar(playerId);

    if (value != null) {
      value = value!.copyWith(avatarUrl: '');
      notifyListeners();
    }
  }

  Future<Player?> getPlayerById(String playerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _playerService.getPlayerById(playerId);
    } catch (_) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
