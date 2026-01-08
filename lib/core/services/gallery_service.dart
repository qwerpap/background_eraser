import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_eraser/core/bloc/bloc_providers.dart';
import 'package:talker_flutter/talker_flutter.dart';

class GalleryException implements Exception {
  GalleryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GalleryService {
  GalleryService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    try {
      getIt<Talker>().info('Opening gallery picker');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        getIt<Talker>().info('Image selected from gallery: ${image.path}');
        return File(image.path);
      }

      return null;
    } catch (e) {
      getIt<Talker>().error('Error picking image from gallery: $e');

      // Попытка запросить разрешение явно
      try {
        getIt<Talker>().info('Trying to request gallery permission explicitly');
        final permission = Platform.isIOS
            ? Permission.photos
            : Permission.storage;
        final permissionStatus = await permission.request();
        getIt<Talker>().info(
          'Permission status after request: $permissionStatus',
        );

        if (permissionStatus == PermissionStatus.granted) {
          getIt<Talker>().info(
            'Retrying gallery picker after permission granted',
          );
          final XFile? retryImage = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );

          if (retryImage != null) {
            return File(retryImage.path);
          }
        } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
          throw GalleryException(
            'Gallery permission is permanently denied. Please enable it in settings.',
          );
        }
      } catch (permissionError) {
        if (permissionError is GalleryException) {
          rethrow;
        }
        getIt<Talker>().error(
          'Error requesting gallery permission: $permissionError',
        );
        throw GalleryException(
          'Failed to access gallery. Please check permissions.',
        );
      }

      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      getIt<Talker>().info('Opening camera');

      if (Platform.isIOS) {
        getIt<Talker>().info('iOS detected - checking camera availability');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        getIt<Talker>().info('Image selected from camera: ${image.path}');
        return File(image.path);
      }

      return null;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      getIt<Talker>().error('Error picking image from camera: $e');

      // Обработка ошибки на iOS симуляторе
      if (Platform.isIOS &&
          (errorMessage.contains('simulator') ||
              errorMessage.contains('camera not available') ||
              errorMessage.contains('no camera') ||
              errorMessage.contains('camera unavailable'))) {
        getIt<Talker>().warning('Camera is not available on iOS simulator');
        throw GalleryException(
          'Camera is not available on iOS simulator. Please use a real device or select from gallery.',
        );
      }

      // Попытка запросить разрешение явно
      try {
        getIt<Talker>().info('Trying to request camera permission explicitly');
        final permission = await Permission.camera.request();
        getIt<Talker>().info('Camera permission status: $permission');

        if (permission == PermissionStatus.granted) {
          getIt<Talker>().info('Retrying camera after permission granted');
          final XFile? retryImage = await _picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );

          if (retryImage != null) {
            return File(retryImage.path);
          }
        } else if (permission == PermissionStatus.permanentlyDenied) {
          throw GalleryException(
            'Camera permission is permanently denied. Please enable it in settings.',
          );
        }
      } catch (permissionError) {
        if (permissionError is GalleryException) {
          rethrow;
        }
        getIt<Talker>().error(
          'Error requesting camera permission: $permissionError',
        );
        throw GalleryException(
          'Failed to access camera. Please check permissions.',
        );
      }

      return null;
    }
  }
}
