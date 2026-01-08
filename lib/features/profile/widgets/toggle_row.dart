import 'package:flutter/material.dart';
import 'package:background_eraser/core/theme/app_colors.dart';

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.icon,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.white210Color,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white210Color,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.aquaColor,
          ),
        ],
      ),
    );
  }
}

