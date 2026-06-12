import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabadao/components/profile/picker_sheet.dart';

class PhotoEditButton extends StatelessWidget {
  const PhotoEditButton({super.key, required this.onPickImage});

  final void Function(ImageSource? source) onPickImage;

  static const Color _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerSheet(context),
      child: Container(
        width: 60,
        height: 60,
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
        child: const Icon(Icons.camera_alt_rounded,
            size: 20, color: Colors.white),
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PickerSheet(onPickImage: onPickImage),
    );
  }
}