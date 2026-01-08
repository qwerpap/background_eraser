import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/repositories/eraser_repository.dart';

class ClearAllErasedImagesUseCase {
  final EraserRepository repository;

  ClearAllErasedImagesUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearAllErasedImages();
  }
}

