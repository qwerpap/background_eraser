import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_eraser/constants/api_constants.dart';
import 'package:talker_flutter/talker_flutter.dart';

class RemoveBgRemoteDataSource {
  final Dio _dio;
  final Talker _talker;

  RemoveBgRemoteDataSource({required Dio dio, required Talker talker})
    : _dio = dio,
      _talker = talker;

  Future<File> removeBackground(File image) async {
    try {
      _talker.info('Removing background for image: ${image.path}');

      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
        'size': 'auto',
        'format': 'png',
        'type': 'auto',
      });

      final response = await _dio.post(
        '${ApiConstants.removeBgBaseUrl}/removebg',
        data: formData,
        options: Options(
          headers: {'X-API-Key': ApiConstants.removeBgApiKey},
          responseType: ResponseType.bytes,
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/removed_bg_$timestamp.png';
      final outputFile = File(outputPath);

      await outputFile.writeAsBytes(response.data as List<int>);

      _talker.info('Background removed successfully: $outputPath');
      return outputFile;
    } on DioException catch (e) {
      _talker.error('Remove.bg API error: ${e.message}', e);

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 400:
            throw const RemoveBgException('Invalid file format or size');
          case 402:
            throw const RemoveBgException('Insufficient credits');
          case 403:
            throw const RemoveBgException('Authentication failed');
          case 429:
            throw const RemoveBgException('Rate limit exceeded');
          default:
            throw RemoveBgException('Server error: $statusCode');
        }
      } else {
        throw RemoveBgException('Network error: ${e.message}');
      }
    } catch (e, st) {
      _talker.error('Unexpected error removing background: $e', e, st);
      throw RemoveBgException('Failed to remove background: $e');
    }
  }
}

class RemoveBgException implements Exception {
  final String message;
  const RemoveBgException(this.message);

  @override
  String toString() => message;
}
