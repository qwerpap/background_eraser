import 'package:flutter/material.dart';
import 'package:background_eraser/core/theme/app_colors.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isEnabled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.editPhotoBtnColor,
        borderRadius: BorderRadius.circular(20),
        border: isEnabled
            ? Border.all(color: AppColors.whiteColor, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Icon(icon, color: AppColors.whiteColor, size: 24),
          ),
        ),
      ),
    );
  }
}
