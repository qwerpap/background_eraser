import 'package:equatable/equatable.dart';

class ErasedImage extends Equatable {
  final int id;
  final String originalPath;
  final String resultPath;
  final DateTime createdAt;

  const ErasedImage({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, originalPath, resultPath, createdAt];
}

