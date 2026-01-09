import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/services/ads/admob_service.dart';
import '../../../core/subscription/apphud_service.dart';
import '../../eraser/domain/usecases/get_recent_erased_images_usecase.dart';
import '../../eraser/domain/usecases/save_erased_image_usecase.dart';
import '../../eraser/domain/entities/erased_image.dart';
import '../data/models/photo_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecentErasedImagesUseCase _getRecentErasedImagesUseCase;
  final SaveErasedImageUseCase _saveErasedImageUseCase;
  final Talker _talker;
  final AnalyticsService _analyticsService;
  final AdMobService _adMobService;
  final AppHudService _appHudService;

  HomeBloc({
    required GetRecentErasedImagesUseCase getRecentErasedImagesUseCase,
    required SaveErasedImageUseCase saveErasedImageUseCase,
    required Talker talker,
    required AnalyticsService analyticsService,
    required AdMobService adMobService,
    required AppHudService appHudService,
  })  : _getRecentErasedImagesUseCase = getRecentErasedImagesUseCase,
       _saveErasedImageUseCase = saveErasedImageUseCase,
       _talker = talker,
        _analyticsService = analyticsService,
        _adMobService = adMobService,
        _appHudService = appHudService,
        super(const HomeInitial()) {
    on<HomeLoadPhotos>(_onLoadPhotos);
    on<HomeImageSourceSelected>(_onImageSourceSelected);
    on<HomeSavePhoto>(_onSavePhoto);
  }

  Future<void> _onLoadPhotos(
    HomeLoadPhotos event,
    Emitter<HomeState> emit,
  ) async {
    await _loadPhotos(emit);
  }

  Future<void> _loadPhotos(Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final result = await _getRecentErasedImagesUseCase();

    result.fold(
      (failure) {
        _talker.error('Error loading photos: ${failure.message}');
        emit(
          HomeError(
            'Failed to load photos: ${failure.message ?? "Unknown error"}',
          ),
        );
      },
      (erasedImages) {
        final photos = erasedImages.map(_erasedImageToPhotoModel).toList();
        emit(HomeLoaded(photos));
        _adMobService.showInterstitialAd();
      },
    );
  }

  Future<void> _reloadPhotos(Emitter<HomeState> emit) async {
    final result = await _getRecentErasedImagesUseCase();
    result.fold(
      (failure) {
        _talker.error('Error reloading photos: ${failure.message}');
        if (state is HomeLoaded) {
          emit(state);
        }
      },
      (erasedImages) {
        final photos = erasedImages.map(_erasedImageToPhotoModel).toList();
      emit(HomeLoaded(photos));
      },
    );
  }

  PhotoModel _erasedImageToPhotoModel(ErasedImage erasedImage) {
    return PhotoModel(
      id: erasedImage.id.toString(),
      imagePath: erasedImage.resultPath,
      createdAt: erasedImage.createdAt,
    );
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
        final isPremium = await _appHudService.isPremium();
        await _analyticsService.logEvent(
          'upload_photo',
          {
            'source_screen': 'home',
            'is_premium': isPremium,
          },
        );
        emit(HomeImagePicked(image));
      } else {
        // Пользователь просто закрыл bottom sheet без выбора фото
        // Восстанавливаем предыдущее состояние
        if (state is HomeLoaded) {
          emit(state);
        } else if (state is HomeInitial || state is HomeLoading) {
          // Если состояние было Initial или Loading, загружаем фото
          await _loadPhotos(emit);
        } else {
          emit(state);
        }
      }
    } catch (e) {
      _talker.error('Error picking image: $e');
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('Camera is not available')) {
        errorMessage =
            'Camera is not available on iOS simulator. Please use a real device or select from gallery.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please enable camera/gallery access in settings.';
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
      final photosDir = await _getPhotosDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = '${photosDir.path}/$fileName';

      await event.imageFile.copy(savedPath);
      _talker.info('Photo file copied to: $savedPath');

      final result = await _saveErasedImageUseCase(
        originalPath: event.originalPath ?? event.imageFile.path,
        resultPath: savedPath,
      );

      result.fold(
        (failure) {
          _talker.error('Error saving photo: ${failure.message}');
          if (state is HomeLoaded) {
            emit(state);
          } else {
            emit(
              HomeError(
                'Failed to save photo: ${failure.message ?? "Unknown error"}',
              ),
            );
          }
        },
        (_) {
          _talker.info('Photo saved successfully');
          _analyticsService.logEvent(
            'save_image',
            {
              'source_screen': 'home',
              'is_premium': false,
            },
          );
        },
      );

      if (result.isRight) {
        await _reloadPhotos(emit);
      }
    } catch (e) {
      _talker.error('Error copying photo file: $e');
      if (state is HomeLoaded) {
        emit(state);
      } else {
        emit(HomeError('Failed to save photo: ${e.toString()}'));
      }
    }
  }

  Future<Directory> _getPhotosDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDocDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }
}
