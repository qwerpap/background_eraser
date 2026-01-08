import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/entities/erased_image.dart';
import 'package:background_eraser/features/eraser/domain/repositories/eraser_repository.dart';
import 'package:background_eraser/features/eraser/data/datasources/eraser_local_datasource.dart';

class EraserRepositoryImpl implements EraserRepository {
  final EraserLocalDataSource _localDataSource;

  EraserRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, void>> saveErasedImage({
    required String originalPath,
    required String resultPath,
  }) async {
    try {
      await _localDataSource.saveErasedImage(
        originalPath: originalPath,
        resultPath: resultPath,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to save erased image: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ErasedImage>>> getRecentErasedImages() async {
    try {
      final dtos = await _localDataSource.getRecentErasedImages();
      final entities = dtos.map<ErasedImage>((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(UnknownFailure('Failed to get erased images: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllErasedImages() async {
    try {
      await _localDataSource.clearAllErasedImages();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to clear erased images: $e'));
    }
  }
}
