/// Примеры использования AnalyticsService в Bloc'ах.
///
/// Все события логируются через абстракцию AnalyticsService,
/// UI не должен напрямую вызывать Firebase SDK.

// Пример 1: Логирование открытия paywall
// В Bloc/Cubit, который отвечает за отображение paywall:
/*
final analyticsService = getIt<AnalyticsService>();
await analyticsService.logEvent(
  'open_paywall',
  {
    'source_screen': 'profile', // или 'home', 'eraser'
    'is_premium': false,
  },
);
*/

// Пример 2: Логирование покупки подписки
// В Bloc/Cubit, который обрабатывает покупку:
/*
final analyticsService = getIt<AnalyticsService>();
await analyticsService.logEvent(
  'subscription_purchased',
  {
    'source_screen': 'paywall',
    'is_premium': true,
    'product_id': 'sonicforge_monthly', // опционально
  },
);
*/

// Пример 3: Установка свойства пользователя (premium статус)
/*
final analyticsService = getIt<AnalyticsService>();
await analyticsService.setUserProperty(
  'is_premium',
  'true', // или 'false'
);
*/

// Пример 4: Установка ID пользователя
/*
final analyticsService = getIt<AnalyticsService>();
await analyticsService.setUserId('user_123');
*/
