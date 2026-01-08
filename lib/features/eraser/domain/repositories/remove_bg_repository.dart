import 'dart:io';
import 'package:background_eraser/core/domain/utils/either.dart';
import 'package:background_eraser/core/domain/errors/failure.dart';

abstract class RemoveBgRepository {
  Future<Either<Failure, File>> removeBackground(File image);
}
