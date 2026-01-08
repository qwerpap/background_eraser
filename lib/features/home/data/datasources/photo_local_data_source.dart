import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:background_eraser/core/bloc/bloc_providers.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../models/photo_model.dart';

class PhotoLocalDataSource {
  PhotoLocalDataSource._();
  static final PhotoLocalDataSource instance = PhotoLocalDataSource._();

  static const String _photosKey = 'saved_photos';

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
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getString(_photosKey);

      if (photosJson == null || photosJson.isEmpty) {
        return [];
      }

      final List<dynamic> photosList = json.decode(photosJson);
      final photos = photosList
          .map((json) => PhotoModel.fromJson(json as Map<String, dynamic>))
          .where((photo) => File(photo.imagePath).existsSync())
          .toList();

      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e, st) {
      getIt<Talker>().error('Error getting all photos: $e', e, st);
      return [];
    }
  }

  Future<PhotoModel> savePhotoMetadata(PhotoModel photo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPhotos = await getAllPhotos();

      final updatedPhotos = existingPhotos
          .where((p) => p.id != photo.id)
          .toList();
      updatedPhotos.add(photo);

      updatedPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final photosJson = json.encode(
        updatedPhotos.map((p) => p.toJson()).toList(),
      );

      await prefs.setString(_photosKey, photosJson);
      getIt<Talker>().info('Photo metadata saved: ${photo.id}');

      return photo;
    } catch (e, st) {
      getIt<Talker>().error('Error saving photo metadata: $e', e, st);
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      final photos = await getAllPhotos();
      final photo = photos.firstWhere((p) => p.id == photoId);

      // Удаляем файл
      final file = File(photo.imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Удаляем из метаданных
      final updatedPhotos = photos.where((p) => p.id != photoId).toList();
      final prefs = await SharedPreferences.getInstance();
      final photosJson = json.encode(
        updatedPhotos.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_photosKey, photosJson);

      getIt<Talker>().info('Photo deleted: $photoId');
    } catch (e, st) {
      getIt<Talker>().error('Error deleting photo: $e', e, st);
      rethrow;
    }
  }
}
