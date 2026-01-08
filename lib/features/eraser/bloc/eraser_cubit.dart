import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/bloc/eraser_state.dart';
import 'package:background_eraser/features/eraser/domain/usecases/remove_background_usecase.dart';
import 'package:talker_flutter/talker_flutter.dart';

class EraserCubit extends Cubit<EraserState> {
  final RemoveBackgroundUseCase _removeBackgroundUseCase;
  final Talker _talker;
  File? _originalImage;
  File? _processedImage;

  EraserCubit(this._removeBackgroundUseCase, this._talker)
    : super(const EraserInitial());

  void reset() {
    _originalImage = null;
    _processedImage = null;
    emit(const EraserInitial());
  }

  void setOriginalImage(File image) {
    _originalImage = image;
    _processedImage = null;
    emit(const EraserInitial());
  }

  Future<void> removeBackground(File image) async {
    _originalImage = image;
    emit(const EraserLoading());

    final result = await _removeBackgroundUseCase(image);

    result.fold(
      (failure) {
        final errorMessage = _getErrorMessage(failure);
        _talker.error('Failed to remove background: $errorMessage');
        emit(EraserError(errorMessage));
      },
      (processedImage) {
        if (_originalImage == null) {
          _talker.error('Original image not set before processing');
          emit(const EraserError('Internal error: original image not set'));
          return;
        }
        _processedImage = processedImage;
        _talker.info('Background removed successfully: ${processedImage.path}');
        emit(
          EraserSuccess(
            originalImage: _originalImage!,
            processedImage: processedImage,
          ),
        );
      },
    );
  }

  void undo() {
    if (state is EraserSuccess && _originalImage != null) {
      emit(const EraserInitial());
      _talker.info('Undo: showing original image');
    }
  }

  void redo() {
    if (state is EraserInitial &&
        _originalImage != null &&
        _processedImage != null) {
      emit(
        EraserSuccess(
          originalImage: _originalImage!,
          processedImage: _processedImage!,
        ),
      );
      _talker.info('Redo: showing processed image');
    }
  }

  bool get canUndo => state is EraserSuccess && _originalImage != null;
  bool get canRedo =>
      state is EraserInitial &&
      _originalImage != null &&
      _processedImage != null;

  String _getErrorMessage(Failure failure) {
    if (failure is AuthFailure) {
      return 'Authentication failed. Please check API key.';
    } else if (failure is InsufficientCreditsFailure) {
      return 'Insufficient credits. Please top up your account.';
    } else if (failure is RateLimitFailure) {
      return 'Rate limit exceeded. Please try again later.';
    } else if (failure is InvalidFileFailure) {
      return failure.message ?? 'Invalid file format or size.';
    } else if (failure is NetworkFailure) {
      return failure.message ?? 'Network error. Please check your connection.';
    } else if (failure is ServerFailure) {
      return failure.message ?? 'Server error. Please try again later.';
    } else {
      return failure.message ?? 'Unknown error occurred.';
    }
  }
}
