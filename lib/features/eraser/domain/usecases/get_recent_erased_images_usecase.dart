import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/entities/erased_image.dart';
import 'package:background_eraser/features/eraser/domain/repositories/eraser_repository.dart';

class GetRecentErasedImagesUseCase {
  final EraserRepository repository;

  GetRecentErasedImagesUseCase(this.repository);

  Future<Either<Failure, List<ErasedImage>>> call() async {
    return await repository.getRecentErasedImages();
  }
}

