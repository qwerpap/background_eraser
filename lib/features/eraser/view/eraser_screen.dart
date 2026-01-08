import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:background_eraser/core/shared/widgets/custom_scaffold.dart';
import 'package:background_eraser/core/theme/app_colors.dart';
import 'package:background_eraser/core/services/gallery_service.dart';
import 'package:background_eraser/features/eraser/widgets/eraser_app_bar.dart';
import 'package:background_eraser/features/eraser/widgets/toolbar.dart';
import 'package:background_eraser/features/eraser/widgets/bottom_action_panel.dart';
import 'package:background_eraser/features/eraser/bloc/eraser_cubit.dart';
import 'package:background_eraser/features/eraser/bloc/eraser_state.dart';
import 'package:background_eraser/features/home/bloc/home_bloc.dart';
import 'package:background_eraser/features/home/bloc/home_event.dart';
import 'package:background_eraser/features/home/presentation/widgets/image_source_bottom_sheet.dart';
import 'package:background_eraser/features/home/presentation/widgets/upload_photo.dart';

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
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.imageFile;
    if (_selectedImage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EraserCubit>().setOriginalImage(_selectedImage!);
      });
    }
  }

  void _handleReset() {
    context.read<EraserCubit>().reset();
  }

  void _handleUndo() {
    context.read<EraserCubit>().undo();
  }

  void _handleRedo() {
    context.read<EraserCubit>().redo();
  }

  void _handleUploadPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      builder: (bottomSheetContext) => ImageSourceBottomSheet(
        onSourceSelected: (source) async {
          Navigator.of(bottomSheetContext).pop();
          await _handleImageSourceSelected(source);
        },
        onClose: () {
          Navigator.of(bottomSheetContext).pop();
        },
      ),
    );
  }

  Future<void> _handleImageSourceSelected(picker.ImageSource source) async {
    try {
      File? image;
      if (source == picker.ImageSource.camera) {
        image = await GalleryService.pickImageFromCamera();
      } else {
        image = await GalleryService.pickImageFromGallery();
      }

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
        context.read<EraserCubit>().setOriginalImage(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('GalleryException: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRemoveBackground() {
    final imageFile = _selectedImage ?? widget.imageFile;
    if (imageFile != null) {
      context.read<EraserCubit>().removeBackground(imageFile);
    }
  }

  void _handleSave() async {
    final cubit = context.read<EraserCubit>();
    final state = cubit.state;

    File? imageToSave;
    String? originalPath;
    
    if (state is EraserSuccess) {
      imageToSave = state.processedImage;
      originalPath = state.originalImage.path;
    } else {
      imageToSave = _selectedImage ?? widget.imageFile;
    }

    if (imageToSave != null) {
      context.read<HomeBloc>().add(HomeSavePhoto(imageToSave, originalPath: originalPath));
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  bool _hasNoImage() {
    return _selectedImage == null &&
        widget.imageFile == null &&
        widget.imageBytes == null &&
        !widget.useMockImage;
  }

  Widget _buildImage(EraserState state) {
    if (_hasNoImage()) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: UploadPhoto(onPressed: _handleUploadPhoto),
        ),
      );
    }

    Widget imageWidget;

    File? imageToShow;
    if (state is EraserSuccess) {
      imageToShow = state.processedImage;
    } else {
      imageToShow = _selectedImage ?? widget.imageFile;
    }

    if (imageToShow != null) {
      imageWidget = Image.file(
        imageToShow,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (widget.imageBytes != null) {
      imageWidget = Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (widget.useMockImage) {
      imageWidget = Image.asset(
        'assets/png/blank.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      imageWidget = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: UploadPhoto(onPressed: _handleUploadPhoto),
        ),
      );
    }

    return imageWidget;
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
    return BlocListener<EraserCubit, EraserState>(
      listener: (context, state) {
        if (state is EraserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<EraserCubit, EraserState>(
        builder: (context, state) {
          final cubit = context.read<EraserCubit>();
          final isProcessing = state is EraserLoading;
          final hasRemovedBackground = state is EraserSuccess;
          final canUndo = cubit.canUndo;
          final canRedo = cubit.canRedo;
          final hasNoImage = _hasNoImage();

    return CustomScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              EraserAppBar(onReset: _handleReset),
              Expanded(
                child: Container(
                  color: AppColors.white018Color,
                        child: _buildImage(state),
                ),
              ),
                    if (!hasNoImage)
                      Toolbar(
                        onUndo: _handleUndo,
                        onRedo: _handleRedo,
                        canUndo: canUndo,
                        canRedo: canRedo,
                      ),
                    if (!hasNoImage)
              BottomActionPanel(
                        onRemoveBackground:
                            (state is EraserInitial || state is EraserError)
                    ? _handleRemoveBackground
                    : null,
                        onSave: hasRemovedBackground ? _handleSave : null,
                        isProcessing: isProcessing,
                        hasRemovedBackground: hasRemovedBackground,
              ),
            ],
          ),
                if (isProcessing) _buildProcessingOverlay(),
        ],
            ),
          );
        },
      ),
    );
  }
}
