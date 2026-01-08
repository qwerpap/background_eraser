import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class EraserState extends Equatable {
  const EraserState();

  @override
  List<Object?> get props => [];
}

class EraserInitial extends EraserState {
  const EraserInitial();
}

class EraserLoading extends EraserState {
  const EraserLoading();
}

class EraserSuccess extends EraserState {
  const EraserSuccess({
    required this.originalImage,
    required this.processedImage,
  });

  final File originalImage;
  final File processedImage;

  @override
  List<Object?> get props => [originalImage, processedImage];
}

class EraserError extends EraserState {
  const EraserError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
