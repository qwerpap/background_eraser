import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/repositories/eraser_repository.dart';

class SaveErasedImageUseCase {
  final EraserRepository repository;

  SaveErasedImageUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String originalPath,
    required String resultPath,
  }) async {
    return await repository.saveErasedImage(
      originalPath: originalPath,
      resultPath: resultPath,
    );
  }
}
