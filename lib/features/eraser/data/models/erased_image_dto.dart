import 'package:background_eraser/features/eraser/domain/entities/erased_image.dart'
    as domain;
import 'package:background_eraser/features/eraser/data/database/eraser_database.dart'
    as db;

class ErasedImageDto {
  final int id;
  final String originalPath;
  final String resultPath;
  final DateTime createdAt;

  ErasedImageDto({
    required this.id,
    required this.originalPath,
    required this.resultPath,
    required this.createdAt,
  });

  factory ErasedImageDto.fromDrift(db.ErasedImage data) {
    return ErasedImageDto(
      id: data.id,
      originalPath: data.originalPath,
      resultPath: data.resultPath,
      createdAt: data.createdAt,
    );
  }

  domain.ErasedImage toEntity() {
    return domain.ErasedImage(
      id: id,
      originalPath: originalPath,
      resultPath: resultPath,
      createdAt: createdAt,
    );
  }
}
