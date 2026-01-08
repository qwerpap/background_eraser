import 'dart:io';
import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/repositories/remove_bg_repository.dart';
import 'package:background_eraser/features/eraser/data/datasources/remove_bg_remote_datasource.dart';

class RemoveBgRepositoryImpl implements RemoveBgRepository {
  final RemoveBgRemoteDataSource _remoteDataSource;

  RemoveBgRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, File>> removeBackground(File image) async {
    try {
      final result = await _remoteDataSource.removeBackground(image);
      return Right(result);
    } on RemoveBgException catch (e) {
      final message = e.message.toLowerCase();

      if (message.contains('authentication failed') ||
          message.contains('403')) {
        return const Left(AuthFailure('Authentication failed'));
      } else if (message.contains('insufficient credits') ||
          message.contains('402')) {
        return const Left(InsufficientCreditsFailure('Insufficient credits'));
      } else if (message.contains('rate limit') || message.contains('429')) {
        return const Left(RateLimitFailure('Rate limit exceeded'));
      } else if (message.contains('invalid file') || message.contains('400')) {
        return Left(InvalidFileFailure(e.message));
      } else if (message.contains('network error') ||
          message.contains('connection')) {
        return Left(NetworkFailure(e.message));
      } else {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: $e'));
    }
  }
}
