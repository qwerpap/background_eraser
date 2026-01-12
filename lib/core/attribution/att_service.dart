import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'att_status.dart';

/// Абстракция для работы с App Tracking Transparency.
/// 
/// Инкапсулирует работу с ATT, скрывая детали реализации SDK
/// от остальных частей приложения.
abstract class AttService {
  /// Возвращает текущий статус ATT.
  /// 
  /// Для Android всегда возвращает [AttStatus.unsupported].
  /// Для iOS < 14 также возвращает [AttStatus.unsupported].
  Future<AttStatus> getStatus();

  /// Запрашивает разрешение на трекинг.
  /// 
  /// Проверяет платформу и версию iOS.
  /// Вызывает диалог только если статус [AttStatus.notDetermined].
  /// Возвращает финальный статус после запроса.
  Future<AttStatus> requestPermission();
}

/// Реализация AttService на основе app_tracking_transparency.
/// 
/// Обрабатывает все возможные статусы и кейсы,
/// включая неподдерживаемые платформы.
class AttServiceImpl implements AttService {
  final Talker _talker;
  final DeviceInfoPlugin _deviceInfo;

  AttServiceImpl({
    required Talker talker,
    DeviceInfoPlugin? deviceInfo,
  })  : _talker = talker,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  @override
  Future<AttStatus> getStatus() async {
    try {
      // Проверка платформы
      if (!Platform.isIOS) {
        _talker.debug('ATT: Platform is not iOS, returning unsupported');
        return AttStatus.unsupported;
      }

      // Проверка версии iOS
      final iosInfo = await _deviceInfo.iosInfo;
      final iosVersion = iosInfo.systemVersion;
      final majorVersion = int.tryParse(iosVersion.split('.').first) ?? 0;

      if (majorVersion < 14) {
        _talker.debug('ATT: iOS version $iosVersion < 14, returning unsupported');
        return AttStatus.unsupported;
      }

      // Получение статуса из SDK
      final trackingStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      final status = _mapSdkStatusToAttStatus(trackingStatus);

      _talker.debug('ATT: Current status is $status');
      return status;
    } catch (e, stackTrace) {
      _talker.error(
        'ATT: Failed to get status',
        e,
        stackTrace,
      );
      // В случае ошибки возвращаем unsupported, чтобы не ломать основной функционал
      return AttStatus.unsupported;
    }
  }

  @override
  Future<AttStatus> requestPermission() async {
    try {
      // Проверка платформы
      if (!Platform.isIOS) {
        _talker.debug('ATT: Cannot request permission on non-iOS platform');
        return AttStatus.unsupported;
      }

      // Проверка версии iOS
      final iosInfo = await _deviceInfo.iosInfo;
      final iosVersion = iosInfo.systemVersion;
      final majorVersion = int.tryParse(iosVersion.split('.').first) ?? 0;

      if (majorVersion < 14) {
        _talker.debug('ATT: Cannot request permission on iOS < 14');
        return AttStatus.unsupported;
      }

      // Проверяем текущий статус
      final currentStatus = await getStatus();
      
      if (currentStatus != AttStatus.notDetermined) {
        _talker.debug(
          'ATT: Cannot request permission, current status is $currentStatus',
        );
        return currentStatus;
      }

      // Запрашиваем разрешение
      _talker.debug('ATT: Requesting tracking authorization');
      final trackingStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      final status = _mapSdkStatusToAttStatus(trackingStatus);

      _talker.debug('ATT: Permission request completed with status $status');
      return status;
    } catch (e, stackTrace) {
      _talker.error(
        'ATT: Failed to request permission',
        e,
        stackTrace,
      );
      // В случае ошибки возвращаем unsupported
      return AttStatus.unsupported;
    }
  }

  /// Маппит статус из SDK в AttStatus.
  /// 
  /// Инкапсулирует зависимость от SDK-типов.
  AttStatus _mapSdkStatusToAttStatus(TrackingStatus sdkStatus) {
    switch (sdkStatus) {
      case TrackingStatus.authorized:
        return AttStatus.authorized;
      case TrackingStatus.denied:
        return AttStatus.denied;
      case TrackingStatus.restricted:
        return AttStatus.restricted;
      case TrackingStatus.notDetermined:
        return AttStatus.notDetermined;
      default:
        _talker.warning('ATT: Unknown SDK status: $sdkStatus, returning unsupported');
        return AttStatus.unsupported;
    }
  }
}
