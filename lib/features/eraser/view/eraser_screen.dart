import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:background_eraser/core/shared/widgets/custom_scaffold.dart';
import 'package:background_eraser/core/theme/app_colors.dart';
import 'package:background_eraser/features/eraser/widgets/eraser_app_bar.dart';
import 'package:background_eraser/features/eraser/widgets/toolbar.dart';
import 'package:background_eraser/features/eraser/widgets/bottom_action_panel.dart';

enum EraserScreenState { idle, processing, result }

class EraserScreen extends StatefulWidget {
  const EraserScreen({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.useMockImage = false,
  });

  final File? imageFile;
  final Uint8List? imageBytes;
  final bool useMockImage;

  @override
  State<EraserScreen> createState() => _EraserScreenState();
}

class _EraserScreenState extends State<EraserScreen> {
  EraserScreenState _state = EraserScreenState.idle;

  void _handleReset() {
    setState(() {
      _state = EraserScreenState.idle;
    });
  }

  void _handleRemoveBackground() {
    setState(() {
      _state = EraserScreenState.processing;
    });

    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _state = EraserScreenState.result;
        });
      }
    });
  }

  void _handleSave() {
    // TODO: Add save logic
  }

  bool get _hasRemovedBackground => _state == EraserScreenState.result;

  Widget _buildImage() {
    Widget imageWidget;

    if (widget.imageFile != null) {
      imageWidget = Image.file(widget.imageFile!, fit: BoxFit.contain);
    } else if (widget.imageBytes != null) {
      imageWidget = Image.memory(widget.imageBytes!, fit: BoxFit.contain);
    } else if (widget.useMockImage) {
      // Mock image for testing
      imageWidget = Image.asset('assets/png/blank.png', fit: BoxFit.contain);
    } else {
      imageWidget = const Center(child: Text('No image provided'));
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white018Color,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.aquaColor),
            ),
            SizedBox(height: 16),
            Text(
              'Processing...',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              EraserAppBar(onReset: _handleReset),
              Expanded(
                child: Container(
                  color: AppColors.white018Color,
                  child: _buildImage(),
                ),
              ),
              const Toolbar(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomActionPanel(
              onRemoveBackground: _state == EraserScreenState.idle
                  ? _handleRemoveBackground
                  : null,
              onSave: _hasRemovedBackground ? _handleSave : null,
              isProcessing: _state == EraserScreenState.processing,
              hasRemovedBackground: _hasRemovedBackground,
            ),
          ),
          if (_state == EraserScreenState.processing) _buildProcessingOverlay(),
        ],
      ),
    );
  }
}
