import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/subscription/apphud_service.dart';
import '../../../core/subscription/subscription_product.dart';
import 'paywall_event.dart';
import 'paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final AppHudService _appHudService;
  final AnalyticsService _analyticsService;
  final Talker _talker;
  
  // Сохраняем последний список продуктов для восстановления состояния после ошибки
  List<SubscriptionProduct> _lastProducts = [];

  PaywallBloc({
    required AppHudService appHudService,
    required AnalyticsService analyticsService,
    required Talker talker,
  }) : _appHudService = appHudService,
       _analyticsService = analyticsService,
       _talker = talker,
       super(const PaywallInitial()) {
    on<PaywallLoadProducts>(_onLoadProducts);
    on<PaywallPurchase>(_onPurchase);
    on<PaywallRestore>(_onRestore);
  }

  Future<void> _onLoadProducts(
    PaywallLoadProducts event,
    Emitter<PaywallState> emit,
  ) async {
    emit(const PaywallLoading());
    try {
      final isPremium = await _appHudService.isPremium();
      await _analyticsService.logEvent('open_paywall', {
        'source_screen': 'paywall',
        'is_premium': isPremium,
      });

      final products = await _appHudService.getPaywallProducts();
      _lastProducts = products;
      _talker.debug('PaywallBloc: Loaded ${products.length} products');
      if (products.isEmpty) {
        _talker.warning(
          'PaywallBloc: No products found. Check AppHud configuration.',
        );
      }
      emit(PaywallLoaded(products));
    } catch (e, stackTrace) {
      _talker.error('Failed to load paywall products', e, stackTrace);
      emit(PaywallError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onPurchase(
    PaywallPurchase event,
    Emitter<PaywallState> emit,
  ) async {
    emit(PaywallPurchasing(event.product));
    try {
      await _appHudService.purchase(event.product);
      await _analyticsService.logEvent('subscription_purchased', {
        'source_screen': 'paywall',
        'product_id': event.product.id,
        'is_premium': true,
      });
      emit(const PaywallPurchaseSuccess());
    } catch (e, stackTrace) {
      _talker.error('Failed to purchase product', e, stackTrace);

      // Извлекаем понятное сообщение об ошибке
      String errorMessage = 'Purchase failed';
      final errorString = e.toString();

      if (errorString.contains('StoreKit Products Not Available') ||
          errorString.contains('not configured in App Store Connect')) {
        errorMessage =
            'Products are not configured yet.\n'
            'Please configure in-app purchases in App Store Connect.';
      } else if (errorString.contains('not found')) {
        errorMessage =
            'Product not found.\n'
            'Please check AppHud configuration.';
      } else {
        // Берем сообщение из исключения, убирая лишнее
        final match = RegExp(
          r'Exception:\s*(.+?)(?:\n|$)',
        ).firstMatch(errorString);
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        } else {
          errorMessage = errorString.replaceAll('Exception: ', '');
        }
      }

      // Показываем ошибку через временное состояние, затем возвращаемся к продуктам
      if (_lastProducts.isNotEmpty) {
        // Сначала показываем ошибку, чтобы SnackBar отобразился
        emit(PaywallError(errorMessage));
        // Затем сразу возвращаемся к продуктам
        await Future.delayed(const Duration(milliseconds: 100));
        emit(PaywallLoaded(_lastProducts));
      } else {
        emit(PaywallError(errorMessage));
      }
    }
  }

  Future<void> _onRestore(
    PaywallRestore event,
    Emitter<PaywallState> emit,
  ) async {
    emit(const PaywallRestoring());
    try {
      await _appHudService.restore();
      emit(const PaywallRestoreSuccess());
    } catch (e, stackTrace) {
      _talker.error('Failed to restore purchases', e, stackTrace);
      emit(PaywallError('Restore failed: ${e.toString()}'));
    }
  }
}
