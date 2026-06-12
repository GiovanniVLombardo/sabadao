import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabadao/components/profile/picker_sheet.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/models/player.dart';

class AvatarWithEditButton extends StatefulWidget {
  const AvatarWithEditButton({super.key, 
    required this.player,
    required this.controller,
  });

  final Player? player;
  final UserController controller;

  @override
  State<AvatarWithEditButton> createState() => AvatarWithEditButtonState();
}

class AvatarWithEditButtonState extends State<AvatarWithEditButton> {
  bool _uploading = false;

  static const Color _accent = Color(0xFF2563EB);
  static const Color _accentLight = Color(0xFF3B82F6);
  static const Color _danger = Color(0xFFEF4444);

  // ── Fluxo de seleção ─────────────────────────────────────────────────────────

  Future<void> _onPickImage(ImageSource? source) async {
    final player = widget.player;
    if (player == null) return;

    // null = remover foto
    if (source == null) {
      await _runWithLoading(
        () => widget.controller.removeAvatar(player.id!),
      );
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return; // usuário cancelou

    // Faz upload local + Supabase via controller → service
    await _runWithLoading(
      () => widget.controller.uploadAvatar(player.id!, File(picked.path)),
    );
  }

  Future<void> _runWithLoading(Future<void> Function() task) async {
    setState(() => _uploading = true);
    try {
      await task();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: $e'),
            backgroundColor: _danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAvatar(),
        if (_uploading) _buildLoadingOverlay(),
        if (!_uploading)
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildEditButton(),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    const double size = 180;
    final player = widget.player;

    if (player?.avatarUrl != '') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _accentLight, width: 3),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.5),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
          image: DecorationImage(
            image: player!.avatarUrl.startsWith('http')
                ? NetworkImage(player.avatarUrl)
                : AssetImage(player.avatarUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final initials = player!.name
        .split(' ')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        border: Border.all(color: _accentLight, width: 3),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.5),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.55),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              SizedBox(height: 8),
              Text(
                'Enviando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => PickerSheet(onPickImage: _onPickImage),
      ),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}