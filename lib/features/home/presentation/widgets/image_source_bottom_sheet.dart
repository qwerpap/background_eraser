import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:background_eraser/core/theme/app_colors.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({
    super.key,
    required this.onSourceSelected,
    required this.onClose,
  });

  final Function(picker.ImageSource) onSourceSelected;
  final VoidCallback onClose;

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.editPhotoBtnColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.whiteColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.only(top: 24, bottom: bottomPadding + 16);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.scaffoldColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: _getPadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.white210Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildSourceOption(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () {
              onSourceSelected(picker.ImageSource.camera);
            },
          ),
          const SizedBox(height: 12),
          _buildSourceOption(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () {
              onSourceSelected(picker.ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
