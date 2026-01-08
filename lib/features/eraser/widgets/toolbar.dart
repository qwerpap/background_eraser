import 'package:flutter/material.dart';
import 'toolbar_button.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onErase,
    this.onRestore,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onErase;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ToolbarButton(icon: Icons.undo, onPressed: onUndo, isEnabled: false),
          ToolbarButton(icon: Icons.redo, onPressed: onRedo, isEnabled: false),
          ToolbarButton(
            icon: Icons.brush,
            onPressed: onErase,
            isEnabled: false,
          ),
          ToolbarButton(
            icon: Icons.restore,
            onPressed: onRestore,
            isEnabled: false,
          ),
        ],
      ),
    );
  }
}
