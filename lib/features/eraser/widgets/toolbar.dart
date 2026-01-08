import 'package:flutter/material.dart';
import 'toolbar_button.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToolbarButton(
            icon: Icons.undo,
            onPressed: onUndo,
            isEnabled: canUndo,
          ),
          const SizedBox(width: 24),
          ToolbarButton(
            icon: Icons.redo,
            onPressed: onRedo,
            isEnabled: canRedo,
          ),
        ],
      ),
    );
  }
}
