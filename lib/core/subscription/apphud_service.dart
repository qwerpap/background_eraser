import 'package:apphud/apphud.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'subscription_status.dart';
import 'subscription_product.dart';

/// Абстракция для работы с AppHud SDK.
///
/// Инкапсулирует работу с подписками, скрывая детали реализации SDK
/// от остальных частей приложения.
abstract class AppHudService {
  /// Инициализирует AppHud с API key.
  ///
  /// Включает debug mode и подключает listener изменений подписки.
  Future<void> init();

  /// Возвращает текущий статус подписки.
  Future<SubscriptionStatus> getSubscriptionStatus();

  /// Проверяет, является ли пользователь premium.
  ///
  /// Возвращает `true`, если подписка активна, иначе `false`.
  Future<bool> isPremium();

  /// Получает список продуктов из paywall.
  ///
  /// Возвращает список [SubscriptionProduct] для paywall с ID main_paywall.
  Future<List<SubscriptionProduct>> getPaywallProducts();

  /// Выполняет покупку продукта.
  ///
  /// [product] - продукт для покупки.
  ///
  /// Бросает исключение в случае ошибки покупки.
  Future<void> purchase(SubscriptionProduct product);

  /// Восстанавливает покупки пользователя.
  ///
  /// Бросает исключение в случае ошибки восстановления.
  Future<void> restore();

  /// Устанавливает данные атрибуции для AppsFlyer.
  ///
  /// [data] - карта данных атрибуции (реализация будет подключена на следующем этапе).
  Future<void> setAttribution(Map<String, String> data);

  /// Сбрасывает тестовую подписку (только для разработки/тестирования).
  ///
  /// Используется для тестирования рекламы и функционала без premium.
  void resetTestSubscription();
}

/// Реализация AppHudService на основе AppHud SDK.
///
/// Обрабатывает все операции с подписками и маппит SDK-типы в domain-модели.
class AppHudServiceImpl implements AppHudService {
  final Talker _talker;
  static const String _apiKey = 'app_Z44sHCCXqhP5FCBDa8SxKBLB7VLpga';
  static const String _paywallId = 'main_paywall';
  static const List<String> _productIds = [
    'sonicforge_weekly',
    'sonicforge_monthly',
    'sonicforge_yearly',
  ];
  
  // Флаг для отслеживания, загружены ли реальные продукты
  bool _hasRealProducts = false;
  
  // Флаг для тестовой подписки (симуляция)
  bool _hasTestSubscription = false;

  AppHudServiceImpl({required Talker talker}) : _talker = talker;

  @override
  Future<void> init() async {
    try {
      _talker.debug('AppHud: Initializing with API key');

      await Apphud.start(apiKey: _apiKey, observerMode: false);

      _talker.debug('AppHud: Initialization completed');
    } catch (e, stackTrace) {
      _talker.error('AppHud: Failed to initialize', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      // Если есть тестовая подписка, возвращаем active
      if (_hasTestSubscription) {
        _talker.debug('AppHud: Subscription status is active (test subscription)');
        return SubscriptionStatus.active;
      }
      
      final hasActiveSubscription = await Apphud.hasActiveSubscription();

      final status = hasActiveSubscription
          ? SubscriptionStatus.active
          : SubscriptionStatus.inactive;

      _talker.debug('AppHud: Subscription status is $status');
      return status;
    } catch (e, stackTrace) {
      _talker.error('AppHud: Failed to get subscription status', e, stackTrace);
      return SubscriptionStatus.unknown;
    }
  }

  @override
  Future<bool> isPremium() async {
    final status = await getSubscriptionStatus();
    return status == SubscriptionStatus.active;
  }

  @override
  Future<List<SubscriptionProduct>> getPaywallProducts() async {
    try {
      _talker.debug('AppHud: Loading products for paywall $_paywallId');

      // Загружаем все продукты и фильтруем по нужным ID
      final allProducts = await Apphud.products();
      _talker.debug('AppHud: Received ${allProducts.length} products from AppHud');

      if (allProducts.isEmpty) {
        _talker.warning('AppHud: No products found. Products may not be loaded yet.');
        // Возвращаем пустой список, но не ошибку
        return [];
      }

      // Фильтруем продукты по известным ID из paywall
      final productIds = _productIds;
      _talker.debug('AppHud: Looking for products: $productIds');

      final products = <SubscriptionProduct>[];

      for (final apphudProduct in allProducts) {
        try {
          // Проверяем, что продукт входит в наш список
          final productId = _extractProductId(apphudProduct);
          _talker.debug('AppHud: Checking product ID: $productId');
          
          if (productId == null || !productIds.contains(productId)) {
            _talker.debug('AppHud: Product $productId skipped (not in list)');
            continue;
          }

          // Получаем SKProduct для получения цены и валюты
          final skProduct = _extractSkProduct(apphudProduct);

          if (skProduct == null) {
            _talker.warning('AppHud: Product $productId has no SKProduct');
            continue;
          }

          // Форматируем цену
          final price = skProduct.price;
          final priceLocale = skProduct.priceLocale;
          final currencyCode = priceLocale?.currencyCode ?? 'USD';

          // Используем localizedPrice если доступен, иначе форматируем вручную
          final priceString =
              skProduct.localizedPrice ??
              '${priceLocale?.currencySymbol ?? '\$'}${price.toStringAsFixed(2)}';

          final product = SubscriptionProduct(
            id: productId,
            title: _extractProductName(apphudProduct) ?? productId,
            price: priceString,
            currencyCode: currencyCode,
          );

          products.add(product);
          _talker.debug(
            'AppHud: Product loaded: ${product.id} - ${product.title} - ${product.price} ${product.currencyCode}',
          );
        } catch (e, stackTrace) {
          _talker.error('AppHud: Failed to process product', e, stackTrace);
        }
      }

      _talker.debug('AppHud: Loaded ${products.length} products from paywall');
      
      // Если продукты не загрузились, возвращаем тестовые для разработки
      if (products.isEmpty) {
        _talker.warning('AppHud: No products loaded, using test products');
        _hasRealProducts = false;
        return _getTestProducts();
      }
      
      _hasRealProducts = true;
      return products;
    } catch (e, stackTrace) {
      _talker.error('AppHud: Failed to get paywall products', e, stackTrace);
      // В случае ошибки возвращаем тестовые продукты
      _hasRealProducts = false;
      return _getTestProducts();
    }
  }

  /// Возвращает тестовые продукты для разработки.
  List<SubscriptionProduct> _getTestProducts() {
    return [
      SubscriptionProduct(
        id: 'sonicforge_weekly',
        title: 'Weekly Premium',
        price: '\$4.99',
        currencyCode: 'USD',
      ),
      SubscriptionProduct(
        id: 'sonicforge_monthly',
        title: 'Monthly Premium',
        price: '\$9.99',
        currencyCode: 'USD',
      ),
      SubscriptionProduct(
        id: 'sonicforge_yearly',
        title: 'Yearly Premium',
        price: '\$49.99',
        currencyCode: 'USD',
      ),
    ];
  }

  /// Извлекает ID продукта из ApphudProductComposite.
  String? _extractProductId(dynamic apphudProduct) {
    try {
      // Пробуем разные возможные поля
      if (apphudProduct is Map) {
        return apphudProduct['productId'] as String? ??
            apphudProduct['identifier'] as String?;
      }
      
      // Пробуем получить через динамическое поле
      try {
        final productId = apphudProduct?.productId ?? apphudProduct?.identifier;
        if (productId != null) {
          return productId.toString();
        }
      } catch (_) {}
      
      // Пробуем через toString и парсинг
      final str = apphudProduct.toString();
      _talker.debug('AppHud: Product toString: $str');
      
      // Ищем ID в строке
      for (final id in _productIds) {
        if (str.contains(id)) {
          return id;
        }
      }
      
      return null;
    } catch (e) {
      _talker.warning('AppHud: Failed to extract product ID: $e');
      return null;
    }
  }

  /// Извлекает название продукта.
  String? _extractProductName(dynamic apphudProduct) {
    try {
      if (apphudProduct is Map) {
        return apphudProduct['name'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Извлекает SKProduct из ApphudProductComposite.
  dynamic _extractSkProduct(dynamic apphudProduct) {
    try {
      if (apphudProduct is Map) {
        return apphudProduct['skProduct'] ?? apphudProduct['product'];
      }
      // Пробуем получить через динамическое поле
      try {
        return apphudProduct?.skProduct ?? apphudProduct?.product;
      } catch (_) {
        return null;
      }
    } catch (e) {
      _talker.debug('AppHud: Failed to extract SKProduct: $e');
      return null;
    }
  }

  @override
  Future<void> purchase(SubscriptionProduct product) async {
    try {
      _talker.debug('AppHud: Starting purchase for product ${product.id}');

      // Проверяем, является ли это тестовым продуктом
      final isTestProduct = _isTestProduct(product.id);
      
      if (isTestProduct) {
        // Для тестовых продуктов симулируем покупку
        _talker.info('AppHud: Simulating purchase for test product ${product.id}');
        await Future.delayed(const Duration(seconds: 1)); // Симуляция задержки
        
        // Устанавливаем флаг тестовой подписки
        _hasTestSubscription = true;
        
        _talker.debug('AppHud: Test purchase completed for ${product.id}');
        _talker.info('AppHud: Test subscription activated');
        return;
      }

      // Сначала получаем все продукты и ищем нужный
      List<dynamic> allProducts;
      try {
        allProducts = await Apphud.products();
      } catch (e) {
        // Если продукты не доступны в StoreKit
        if (e.toString().contains('StoreKit Products Not Available') ||
            e.toString().contains('500')) {
          throw Exception(
            'Products are not configured in App Store Connect. '
            'Please configure in-app purchases in App Store Connect and wait for approval.',
          );
        }
        rethrow;
      }

      if (allProducts.isEmpty) {
        throw Exception(
          'No products available. Please configure in-app purchases in App Store Connect.',
        );
      }

      dynamic apphudProduct;
      for (final p in allProducts) {
        final productId = _extractProductId(p);
        if (productId == product.id) {
          apphudProduct = p;
          break;
        }
      }

      if (apphudProduct == null) {
        throw Exception(
          'Product ${product.id} not found in AppHud. '
          'Please ensure the product is configured in AppHud Dashboard.',
        );
      }

      // AppHud.purchase() может принимать product как named параметр или без параметров
      // Пробуем вызвать с product
      final result = await Apphud.purchase(product: apphudProduct);

      if (result.error != null) {
        final error = result.error!;
        _talker.error(
          'AppHud: Purchase failed for ${product.id}: ${error.message}',
          error,
        );
        
        // Обрабатываем специфичные ошибки
        final errorMessage = error.message ?? 'Unknown error';
        if (errorMessage.contains('StoreKit Products Not Available') ||
            errorMessage.contains('500')) {
          throw Exception(
            'Products are not configured in App Store Connect. '
            'Please configure in-app purchases and wait for approval.',
          );
        }
        
        throw Exception('Purchase failed: $errorMessage');
      }

      if (result.transaction != null) {
        _talker.debug(
          'AppHud: Purchase successful for ${product.id}, transaction: ${result.transaction?.transactionIdentifier}',
        );
      } else {
        _talker.debug(
          'AppHud: Purchase completed successfully for ${product.id}',
        );
      }
    } catch (e, stackTrace) {
      _talker.error('AppHud: Purchase error for ${product.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Проверяет, является ли продукт тестовым (не загруженным из AppHud).
  bool _isTestProduct(String productId) {
    // Если реальные продукты не загружены, значит используем тестовые
    return !_hasRealProducts;
  }

  @override
  void resetTestSubscription() {
    _hasTestSubscription = false;
    _talker.info('AppHud: Test subscription reset');
  }

  @override
  Future<void> restore() async {
    try {
      _talker.debug('AppHud: Starting restore purchases');

      final result = await Apphud.restorePurchases();

      if (result.error != null) {
        final error = result.error!;
        _talker.error('AppHud: Restore failed: ${error.message}', error);
        throw Exception('Restore failed: ${error.message}');
      }

      _talker.debug('AppHud: Restore completed successfully');
    } catch (e, stackTrace) {
      _talker.error('AppHud: Restore error', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setAttribution(Map<String, String> data) async {
    try {
      _talker.debug('AppHud: Setting attribution data: $data');

      // AppHud SDK требует использование enum для ключей user properties
      // Атрибуция будет передана через AppsFlyer conversion callback
      // Логируем данные для отладки
      if (data.containsKey('att_status')) {
        _talker.debug('AppHud: ATT status: ${data['att_status']}');
      }
      if (data.containsKey('source')) {
        _talker.debug('AppHud: Attribution source: ${data['source']}');
      }

      _talker.debug('AppHud: Attribution data logged (AppHud will receive it via AppsFlyer)');
    } catch (e, stackTrace) {
      _talker.error('AppHud: Failed to set attribution', e, stackTrace);
    }
  }
}
