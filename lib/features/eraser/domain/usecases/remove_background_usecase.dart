import 'dart:io';
import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';
import 'package:background_eraser/features/eraser/domain/repositories/remove_bg_repository.dart';

class RemoveBackgroundUseCase {
  final RemoveBgRepository repository;

  RemoveBackgroundUseCase(this.repository);

  Future<Either<Failure, File>> call(File image) async {
    return await repository.removeBackground(image);
  }
}
