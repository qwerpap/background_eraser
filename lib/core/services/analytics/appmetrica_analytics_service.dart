import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'analytics_service.dart';

/// Реализация AnalyticsService на основе AppMetrica.
///
/// Инкапсулирует работу с AppMetrica, скрывая детали реализации
/// от остальных частей приложения.
class AppMetricaAnalyticsService implements AnalyticsService {
  final Talker _talker;

  AppMetricaAnalyticsService({required Talker talker}) : _talker = talker;

  @override
  Future<void> logEvent(String name, Map<String, Object?> params) async {
    try {
      final filteredParams = <String, Object>{};
      for (final entry in params.entries) {
        if (entry.value != null) {
          // AppMetrica принимает String, num, bool
          final value = entry.value!;
          if (value is bool) {
            // Конвертируем bool в String для AppMetrica
            filteredParams[entry.key] = value.toString();
          } else {
            filteredParams[entry.key] = value;
          }
        }
      }

      // AppMetrica.reportEvent - параметры передаются как отдельные события
      // или можно использовать reportEvent с именем, содержащим параметры
      AppMetrica.reportEvent(name);
      
      // Логируем параметры как отдельные события (AppMetrica не поддерживает параметры напрямую)
      if (filteredParams.isNotEmpty) {
        for (final entry in filteredParams.entries) {
          AppMetrica.reportEvent('${name}_${entry.key}_${entry.value}');
        }
      }
      
      _talker.debug(
        'AppMetrica event logged: $name with params: $filteredParams',
      );
    } catch (e, stackTrace) {
      _talker.error('Failed to log AppMetrica event: $name', e, stackTrace);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      AppMetrica.setUserProfileID(value);
      _talker.debug('AppMetrica user property set: $name = $value');
    } catch (e, stackTrace) {
      _talker.error(
        'Failed to set AppMetrica user property: $name',
        e,
        stackTrace,
      );
    }
  }

  @override
  Future<void> setUserId(String id) async {
    try {
      AppMetrica.setUserProfileID(id);
      _talker.debug('AppMetrica user ID set: $id');
    } catch (e, stackTrace) {
      _talker.error('Failed to set AppMetrica user ID: $id', e, stackTrace);
    }
  }
}
