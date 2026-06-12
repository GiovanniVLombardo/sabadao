import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabadao/components/profile/sheet_option.dart';

class PickerSheet extends StatelessWidget {
  const PickerSheet({super.key, required this.onPickImage});

  final void Function(ImageSource? source) onPickImage;

  static const Color _card = Color(0xFF161B22);
  static const Color _accentLight = Color(0xFF3B82F6);
  static const Color _textPrimary = Color(0xFFF9FAFB);
  static const Color _textSecondary = Color(0xFF9CA3AF);
  static const Color _divider = Color(0xFF21262D);
  static const Color _danger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Foto de Perfil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha como deseja atualizar sua foto',
            style: TextStyle(fontSize: 13, color: _textSecondary),
          ),
          const SizedBox(height: 24),
          SheetOption(
            icon: Icons.camera_alt_rounded,
            iconColor: _accentLight,
            label: 'Tirar foto',
            subtitle: 'Usar a câmera do dispositivo',
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 12),
          SheetOption(
            icon: Icons.photo_library_rounded,
            iconColor: _accentLight,
            label: 'Escolher da galeria',
            subtitle: 'Selecionar uma imagem existente',
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 12),
          SheetOption(
            icon: Icons.delete_outline_rounded,
            iconColor: _danger,
            label: 'Remover foto',
            subtitle: 'Voltar para as iniciais do nome',
            labelColor: _danger,
            onTap: () {
              Navigator.pop(context);
              onPickImage(null);
            },
          ),
        ],
      ),
    );
  }
}