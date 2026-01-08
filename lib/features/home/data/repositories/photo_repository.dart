import 'dart:io';
import 'package:background_eraser/features/home/data/datasources/photo_local_data_source.dart';
import 'package:background_eraser/features/home/data/models/photo_model.dart';
import 'package:uuid/uuid.dart';

class PhotoRepository {
  final PhotoLocalDataSource _localDataSource;

  PhotoRepository(this._localDataSource);

  Future<List<PhotoModel>> getAllPhotos() async {
    return await _localDataSource.getAllPhotos();
  }

  Future<PhotoModel> savePhoto(File imageFile) async {
    final savedPath = await _localDataSource.savePhotoFile(imageFile);
    final photo = PhotoModel(
      id: const Uuid().v4(),
      imagePath: savedPath,
      createdAt: DateTime.now(),
    );
    return await _localDataSource.savePhotoMetadata(photo);
  }

  Future<void> deletePhoto(String photoId) async {
    await _localDataSource.deletePhoto(photoId);
  }
}

