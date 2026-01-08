import 'package:flutter/material.dart';
import 'package:background_eraser/core/shared/widgets/custom_elevated_button.dart';
import 'package:background_eraser/core/theme/app_colors.dart';

class BottomActionPanel extends StatelessWidget {
  const BottomActionPanel({
    super.key,
    this.onRemoveBackground,
    this.onSave,
    this.isProcessing = false,
    this.hasRemovedBackground = false,
  });

  final VoidCallback? onRemoveBackground;
  final VoidCallback? onSave;
  final bool isProcessing;
  final bool hasRemovedBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.bottomNavColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: hasRemovedBackground ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: hasRemovedBackground,
                child: CustomElevatedButton(
                  text: 'Remove background',
                  onPressed: (isProcessing || onRemoveBackground == null)
                      ? null
                      : onRemoveBackground,
                  height: 56,
                ),
              ),
            ),
            const SizedBox(height: 12),
            hasRemovedBackground
                ? Center(
                    child: CustomElevatedButton(
                      text: 'Save',
                      onPressed: (isProcessing || onSave == null)
                          ? null
                          : onSave,
                      height: 56,
                      transparent: !hasRemovedBackground,
                      backgroundColor: hasRemovedBackground
                          ? null
                          : Colors.transparent,
                    ),
                  )
                : CustomElevatedButton(
                    text: 'Save',
                    onPressed: (isProcessing || onSave == null) ? null : onSave,
                    height: 56,
                    transparent: !hasRemovedBackground,
                    backgroundColor: hasRemovedBackground
                        ? null
                        : Colors.transparent,
                  ),
          ],
        ),
      ),
    );
  }
}
