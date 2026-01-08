import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../../../core/services/gallery_service.dart';
import '../../../core/bloc/bloc_providers.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../data/repositories/photo_repository.dart';
import '../data/datasources/photo_local_data_source.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PhotoRepository _photoRepository;

  HomeBloc() 
      : _photoRepository = PhotoRepository(PhotoLocalDataSource.instance),
        super(const HomeInitial()) {
    on<HomeLoadPhotos>(_onLoadPhotos);
    on<HomeImageSourceSelected>(_onImageSourceSelected);
    on<HomeSavePhoto>(_onSavePhoto);
  }

  Future<void> _onLoadPhotos(
    HomeLoadPhotos event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final photos = await _photoRepository.getAllPhotos();
      emit(HomeLoaded(photos));
    } catch (e) {
      getIt<Talker>().error('Error loading photos: $e');
      emit(HomeError('Failed to load photos: ${e.toString()}'));
    }
  }

  Future<void> _onImageSourceSelected(
    HomeImageSourceSelected event,
    Emitter<HomeState> emit,
  ) async {
    // Не показываем loading при выборе источника фото
    // Сохраняем текущее состояние, чтобы фото не скрывались
    
    try {
      File? image;

      if (event.source == picker.ImageSource.camera) {
        image = await GalleryService.pickImageFromCamera();
      } else {
        image = await GalleryService.pickImageFromGallery();
      }

      if (image != null) {
        emit(HomeImagePicked(image));
      } else {
        // Пользователь просто закрыл bottom sheet без выбора фото
        // Восстанавливаем предыдущее состояние
        if (state is HomeLoaded) {
          emit(state);
        } else if (state is HomeInitial || state is HomeLoading) {
          // Если состояние было Initial или Loading, загружаем фото
          final photos = await _photoRepository.getAllPhotos();
          emit(HomeLoaded(photos));
        } else {
          emit(state);
        }
      }
    } catch (e) {
      getIt<Talker>().error('Error picking image: $e');
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('Camera is not available')) {
        errorMessage = 'Camera is not available on iOS simulator. Please use a real device or select from gallery.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please enable camera/gallery access in settings.';
      } else {
        errorMessage = 'Failed to pick image: ${e.toString()}';
      }
      // При ошибке восстанавливаем предыдущее состояние
      if (state is HomeLoaded) {
        emit(state);
        // Показываем ошибку через snackbar, не через состояние
        // emit(HomeError(errorMessage));
      } else {
        emit(HomeError(errorMessage));
      }
    }
  }

  Future<void> _onSavePhoto(
    HomeSavePhoto event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final photo = await _photoRepository.savePhoto(event.imageFile);
      getIt<Talker>().info('Photo saved: ${photo.id}');
      
      // Обновляем список фото
      final photos = await _photoRepository.getAllPhotos();
      
      // Эмитим состояние сохранения с обновленным списком фото
      emit(HomePhotoSaved(photo, photos));
      
      // Сразу же переходим в загруженное состояние с фото
      emit(HomeLoaded(photos));
    } catch (e) {
      getIt<Talker>().error('Error saving photo: $e');
      // Восстанавливаем предыдущее состояние при ошибке
      if (state is HomeLoaded) {
        emit(state);
      } else {
        emit(HomeError('Failed to save photo: ${e.toString()}'));
      }
    }
  }
}

