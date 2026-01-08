import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/entities/erased_image.dart';

abstract class EraserRepository {
  Future<Either<Failure, void>> saveErasedImage({
    required String originalPath,
    required String resultPath,
  });

  Future<Either<Failure, List<ErasedImage>>> getRecentErasedImages();

  Future<Either<Failure, void>> clearAllErasedImages();
}
