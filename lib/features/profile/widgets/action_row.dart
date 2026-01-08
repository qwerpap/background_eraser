import 'package:flutter/material.dart';
import 'package:background_eraser/core/theme/app_colors.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isDanger ? AppColors.redColor : AppColors.white210Color,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDanger ? AppColors.redColor : AppColors.whiteColor,
                  fontWeight: isDanger ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.white210Color,
            ),
          ],
        ),
      ),
    );
  }
}

