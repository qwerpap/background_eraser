import 'dart:io';
import 'package:background_eraser/features/eraser/data/database/eraser_database.dart';
import 'package:background_eraser/features/eraser/data/models/erased_image_dto.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:drift/drift.dart';

class EraserLocalDataSource {
  final EraserDatabase _database;
  final Talker _talker;

  EraserLocalDataSource(this._database, this._talker);

  Future<void> saveErasedImage({
    required String originalPath,
    required String resultPath,
  }) async {
    try {
      await _database
          .into(_database.erasedImages)
          .insert(
            ErasedImagesCompanion.insert(
              originalPath: originalPath,
              resultPath: resultPath,
              createdAt: DateTime.now(),
            ),
          );
      _talker.info(
        'Erased image saved: original=$originalPath, result=$resultPath',
      );
    } catch (e, st) {
      _talker.error('Error saving erased image: $e', e, st);
      rethrow;
    }
  }

  Future<List<ErasedImageDto>> getRecentErasedImages() async {
    try {
      final query = _database.select(_database.erasedImages)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

      final results = await query.get();

      _talker.info('Loaded ${results.length} erased images from database');

      final dtos = results
          .map((data) => ErasedImageDto.fromDrift(data))
          .toList();

      final existingFiles = await Future.wait(
        dtos.map((dto) async {
          final exists = await File(dto.resultPath).exists();
          return exists ? dto : null;
        }),
      );

      return existingFiles.whereType<ErasedImageDto>().toList();
    } catch (e, st) {
      _talker.error('Error getting erased images: $e', e, st);
      rethrow;
    }
  }

  Future<void> clearAllErasedImages() async {
    try {
      final allImages = await _database.select(_database.erasedImages).get();

      for (final image in allImages) {
        try {
          final file = File(image.resultPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          _talker.warning('Error deleting file ${image.resultPath}: $e');
        }
      }

      await _database.delete(_database.erasedImages).go();
      _talker.info('All erased images cleared');
    } catch (e, st) {
      _talker.error('Error clearing erased images: $e', e, st);
      rethrow;
    }
  }
}
