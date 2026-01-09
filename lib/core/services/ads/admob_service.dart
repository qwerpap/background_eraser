import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../analytics/analytics_service.dart';
import '../../subscription/apphud_service.dart';
import '../../subscription/subscription_status.dart';

/// Сервис для работы с Google AdMob.
///
/// Инкапсулирует работу с рекламой, скрывая детали реализации SDK.
class AdMobService {
  final Talker _talker;
  final AnalyticsService _analyticsService;
  final AppHudService _appHudService;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  bool _isInterstitialShowing = false;
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID

  AdMobService({
    required Talker talker,
    required AnalyticsService analyticsService,
    required AppHudService appHudService,
  })  : _talker = talker,
        _analyticsService = analyticsService,
        _appHudService = appHudService;

  /// Инициализирует AdMob.
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _talker.debug('AdMob initialized');
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e, stackTrace) {
      _talker.error('Failed to initialize AdMob', e, stackTrace);
    }
  }

  /// Загружает InterstitialAd.
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _talker.debug('InterstitialAd loaded');
          _analyticsService.logEvent(
            'ad_loaded',
            {
              'ad_type': 'interstitial',
              'is_premium': false,
            },
          );
          _setupInterstitialCallbacks();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          _talker.error('InterstitialAd failed to load: ${error.message}', error);
          _analyticsService.logEvent(
            'ad_failed',
            {
              'ad_type': 'interstitial',
              'error_code': error.code.toString(),
              'error_message': error.message,
              'is_premium': false,
            },
          );
        },
      ),
    );
  }

  /// Настраивает колбэки для InterstitialAd.
  void _setupInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _talker.debug('InterstitialAd showed');
        _isInterstitialShowing = true;
        _analyticsService.logEvent(
          'ad_shown',
          {
            'ad_type': 'interstitial',
            'is_premium': false,
          },
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        _talker.debug('InterstitialAd dismissed');
        _isInterstitialShowing = false;
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _talker.error('InterstitialAd failed to show: ${error.message}', error);
        _isInterstitialShowing = false;
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        _analyticsService.logEvent(
          'ad_failed',
          {
            'ad_type': 'interstitial',
            'error_code': error.code.toString(),
            'error_message': error.message,
            'is_premium': false,
          },
        );
        _loadInterstitialAd();
      },
    );
  }

  /// Показывает InterstitialAd, если пользователь не premium.
  Future<bool> showInterstitialAd() async {
    try {
      _talker.debug('showInterstitialAd called');
      final subscriptionStatus = await _appHudService.getSubscriptionStatus();
      final isPremium = subscriptionStatus == SubscriptionStatus.active;
      _talker.debug('Subscription status: $subscriptionStatus, isPremium: $isPremium');

      if (isPremium) {
        _talker.debug('Ad skipped: user is premium');
        _analyticsService.logEvent(
          'ad_skipped',
          {
            'ad_type': 'interstitial',
            'reason': 'premium_user',
            'is_premium': true,
          },
        );
        return false;
      }

      _talker.debug('Ad ready status: $_isInterstitialReady, ad exists: ${_interstitialAd != null}, is showing: $_isInterstitialShowing');
      
      // Если реклама уже показывается, не показываем снова
      if (_isInterstitialShowing) {
        _talker.debug('Ad is already showing, skipping');
        return false;
      }
      
      if (!_isInterstitialReady || _interstitialAd == null) {
        _talker.debug('Ad not ready, loading new ad');
        _loadInterstitialAd();
        return false;
      }

      // Проверяем и устанавливаем колбэки перед показом
      if (_interstitialAd!.fullScreenContentCallback == null) {
        _talker.debug('Callbacks not set, setting them now');
        _setupInterstitialCallbacks();
      } else {
        _talker.debug('Callbacks are already set');
      }

      _talker.debug('Showing InterstitialAd...');
      _talker.debug('Ad hash: ${_interstitialAd.hashCode}, callbacks: ${_interstitialAd!.fullScreenContentCallback != null}');
      
      // Сохраняем ссылку на рекламу перед показом
      final adToShow = _interstitialAd!;
      
      // Сбрасываем флаг готовности, чтобы не показать рекламу дважды
      _isInterstitialReady = false;
      _interstitialAd = null; // Освобождаем ссылку, чтобы можно было загрузить новую рекламу
      
      try {
        // Вызываем show() без await, чтобы не блокировать выполнение
        adToShow.show();
        _talker.debug('InterstitialAd.show() called successfully');
        
        // Реклама будет перезагружена в колбэке onAdDismissedFullScreenContent или onAdFailedToShowFullScreenContent
        // Сразу загружаем новую рекламу для следующего раза
        _loadInterstitialAd();
        
        return true;
      } catch (showError, stackTrace) {
        _talker.error('Error calling show(): $showError', showError, stackTrace);
        _isInterstitialShowing = false;
        // Если ошибка при показе, сбрасываем состояние и перезагружаем
        adToShow.dispose();
        _isInterstitialReady = false;
        _loadInterstitialAd();
        return false;
      }
    } catch (e, stackTrace) {
      _talker.error('Failed to show InterstitialAd', e, stackTrace);
      final subscriptionStatus = await _appHudService.getSubscriptionStatus();
      final isPremium = subscriptionStatus == SubscriptionStatus.active;
      _analyticsService.logEvent(
        'ad_failed',
        {
          'ad_type': 'interstitial',
          'error_message': e.toString(),
          'is_premium': isPremium,
        },
      );
      return false;
    }
  }

  /// Загружает RewardedAd.
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          _talker.debug('RewardedAd loaded');
          _analyticsService.logEvent(
            'ad_loaded',
            {
              'ad_type': 'rewarded',
              'is_premium': false,
            },
          );
          _setupRewardedCallbacks();
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          _talker.error('RewardedAd failed to load: ${error.message}', error);
          _analyticsService.logEvent(
            'ad_failed',
            {
              'ad_type': 'rewarded',
              'error_code': error.code.toString(),
              'is_premium': false,
            },
          );
        },
      ),
    );
  }

  /// Настраивает колбэки для RewardedAd.
  void _setupRewardedCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _talker.debug('RewardedAd showed');
        _analyticsService.logEvent(
          'ad_shown',
          {
            'ad_type': 'rewarded',
            'is_premium': false,
          },
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        _talker.debug('RewardedAd dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _talker.error('RewardedAd failed to show: ${error.message}', error);
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        _analyticsService.logEvent(
          'ad_failed',
          {
            'ad_type': 'rewarded',
            'error_code': error.code.toString(),
            'is_premium': false,
          },
        );
        _loadRewardedAd();
      },
    );
  }

  /// Показывает RewardedAd, если пользователь не premium.
  Future<bool> showRewardedAd() async {
    try {
      final subscriptionStatus = await _appHudService.getSubscriptionStatus();
      final isPremium = subscriptionStatus == SubscriptionStatus.active;

      if (isPremium) {
        _talker.debug('RewardedAd skipped: user is premium');
        _analyticsService.logEvent(
          'ad_skipped',
          {
            'ad_type': 'rewarded',
            'reason': 'premium_user',
            'is_premium': true,
          },
        );
        return false;
      }

      if (!_isRewardedReady || _rewardedAd == null) {
        _talker.debug('RewardedAd not ready, loading new ad');
        _loadRewardedAd();
        return false;
      }

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          _talker.debug('RewardedAd: User earned reward: ${reward.amount} ${reward.type}');
          _analyticsService.logEvent(
            'ad_reward_earned',
            {
              'ad_type': 'rewarded',
              'reward_amount': reward.amount.toString(),
              'reward_type': reward.type,
              'is_premium': false,
            },
          );
        },
      );
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to show RewardedAd', e, stackTrace);
      final subscriptionStatus = await _appHudService.getSubscriptionStatus();
      final isPremium = subscriptionStatus == SubscriptionStatus.active;
      _analyticsService.logEvent(
        'ad_failed',
        {
          'ad_type': 'rewarded',
          'error_message': e.toString(),
          'is_premium': isPremium,
        },
      );
      return false;
    }
  }

  /// Создает BannerAd виджет.
  Widget createBannerAd() {
    return _BannerAdWidget(
      adUnitId: _bannerAdUnitId,
      talker: _talker,
      analyticsService: _analyticsService,
      appHudService: _appHudService,
    );
  }

  /// Освобождает ресурсы.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialReady = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedReady = false;
  }
}

class _BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final Talker talker;
  final AnalyticsService analyticsService;
  final AppHudService appHudService;

  const _BannerAdWidget({
    required this.adUnitId,
    required this.talker,
    required this.analyticsService,
    required this.appHudService,
  });

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final status = await widget.appHudService.getSubscriptionStatus();
    final isPremium = status == SubscriptionStatus.active;
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
      if (!isPremium) {
        _loadBannerAd();
      }
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          widget.talker.debug('BannerAd loaded');
          widget.analyticsService.logEvent(
            'ad_loaded',
            {
              'ad_type': 'banner',
              'is_premium': false,
            },
          );
          if (mounted) {
            setState(() {});
          }
        },
        onAdFailedToLoad: (ad, error) {
          widget.talker.error('BannerAd failed to load: ${error.message}', error);
          ad.dispose();
          widget.analyticsService.logEvent(
            'ad_failed',
            {
              'ad_type': 'banner',
              'error_code': error.code.toString(),
              'is_premium': false,
            },
          );
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremium || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final adWidget = _bannerAd != null ? AdWidget(ad: _bannerAd!) : const SizedBox.shrink();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: adWidget,
    );
  }
}
