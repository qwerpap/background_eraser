import 'package:talker_flutter/talker_flutter.dart';
import 'analytics_service.dart';

/// Композитный сервис аналитики, отправляющий события в несколько сервисов.
///
/// Обеспечивает дублирование событий в Firebase Analytics и AppMetrica.
class CompositeAnalyticsService implements AnalyticsService {
  final List<AnalyticsService> _services;
  final Talker _talker;

  CompositeAnalyticsService({
    required List<AnalyticsService> services,
    required Talker talker,
  })  : _services = services,
        _talker = talker;

  @override
  Future<void> logEvent(String name, Map<String, Object?> params) async {
    final futures = _services.map(
      (service) => service.logEvent(name, params),
    );
    await Future.wait(futures);
    _talker.debug('Composite analytics: event $name sent to ${_services.length} services');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    final futures = _services.map(
      (service) => service.setUserProperty(name, value),
    );
    await Future.wait(futures);
    _talker.debug('Composite analytics: user property $name set in ${_services.length} services');
  }

  @override
  Future<void> setUserId(String id) async {
    final futures = _services.map(
      (service) => service.setUserId(id),
    );
    await Future.wait(futures);
    _talker.debug('Composite analytics: user ID set in ${_services.length} services');
  }
}
