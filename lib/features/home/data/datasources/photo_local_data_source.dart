import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:background_eraser/core/bloc/bloc_providers.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../models/photo_model.dart';

class PhotoLocalDataSource {
  PhotoLocalDataSource._();
  static final PhotoLocalDataSource instance = PhotoLocalDataSource._();

  Future<Directory> _getPhotosDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDocDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  Future<String> savePhotoFile(File sourceFile) async {
    try {
      final photosDir = await _getPhotosDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final destinationFile = File('${photosDir.path}/$fileName');
      await sourceFile.copy(destinationFile.path);

      getIt<Talker>().info('Photo saved to: ${destinationFile.path}');
      return destinationFile.path;
    } catch (e, st) {
      getIt<Talker>().error('Error saving photo file: $e', e, st);
      rethrow;
    }
  }

  Future<List<PhotoModel>> getAllPhotos() async {
    try {
      final photosDir = await _getPhotosDirectory();

      if (!await photosDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = photosDir.listSync();
      final List<PhotoModel> photos = [];

      for (final file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
          try {
            final stat = await file.stat();
            final fileName = file.path.split('/').last;
            final id = fileName.replaceAll('.jpg', '');
            
            photos.add(PhotoModel(
              id: id,
              imagePath: file.path,
              createdAt: stat.modified,
            ));
          } catch (e) {
            getIt<Talker>().warning('Error reading photo file ${file.path}: $e');
          }
        }
      }

      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      getIt<Talker>().info('Loaded ${photos.length} photos from directory');

      return photos;
    } catch (e, st) {
      getIt<Talker>().error('Error getting all photos: $e', e, st);
      return [];
    }
  }

  Future<PhotoModel> savePhotoMetadata(PhotoModel photo) async {
    try {
      final file = File(photo.imagePath);
      if (await file.exists()) {
      getIt<Talker>().info('Photo metadata saved: ${photo.id}');
      return photo;
      } else {
        throw Exception('Photo file does not exist: ${photo.imagePath}');
      }
    } catch (e, st) {
      getIt<Talker>().error('Error saving photo metadata: $e', e, st);
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      final photos = await getAllPhotos();
      final photo = photos.firstWhere(
        (p) => p.id == photoId,
        orElse: () => throw Exception('Photo not found: $photoId'),
      );

      final file = File(photo.imagePath);
      if (await file.exists()) {
        await file.delete();
      getIt<Talker>().info('Photo deleted: $photoId');
      } else {
        getIt<Talker>().warning('Photo file does not exist: ${photo.imagePath}');
      }
    } catch (e, st) {
      getIt<Talker>().error('Error deleting photo: $e', e, st);
      rethrow;
    }
  }
}
