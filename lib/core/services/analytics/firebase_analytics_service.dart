import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'analytics_service.dart';

/// Реализация AnalyticsService на основе Firebase Analytics.
///
/// Инкапсулирует работу с Firebase Analytics, скрывая детали реализации
/// от остальных частей приложения.
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;
  final Talker _talker;

  FirebaseAnalyticsService({
    required FirebaseAnalytics analytics,
    required Talker talker,
  })  : _analytics = analytics,
        _talker = talker;

  @override
  Future<void> logEvent(String name, Map<String, Object?> params) async {
    try {
      final filteredParams = <String, Object>{};
      for (final entry in params.entries) {
        if (entry.value != null) {
          // Firebase Analytics принимает только String или num
          // Конвертируем bool в int (0 или 1)
          final value = entry.value!;
          if (value is bool) {
            filteredParams[entry.key] = value ? 1 : 0;
          } else {
            filteredParams[entry.key] = value;
          }
        }
      }

      await _analytics.logEvent(
        name: name,
        parameters: filteredParams.isEmpty ? null : filteredParams,
      );
      _talker.debug(
        'Analytics event logged: $name with params: $filteredParams',
      );
    } catch (e, stackTrace) {
      _talker.error('Failed to log analytics event: $name', e, stackTrace);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _talker.debug('Analytics user property set: $name = $value');
    } catch (e, stackTrace) {
      _talker.error(
        'Failed to set analytics user property: $name',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<void> setUserId(String id) async {
    try {
      await _analytics.setUserId(id: id);
      _talker.debug('Analytics user ID set: $id');
    } catch (e, stackTrace) {
      _talker.error('Failed to set analytics user ID: $id', e, stackTrace);
    }
  }
}
