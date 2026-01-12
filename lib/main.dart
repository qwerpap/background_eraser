import 'dart:ui';
import 'package:background_eraser/firebase_options.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'core/bloc/bloc_providers.dart' show BlocProviders, getIt;
import 'core/services/ads/admob_service.dart';
import 'core/services/attribution/appsflyer_service.dart';
import 'core/subscription/apphud_service.dart';
import 'core/navigation/presentation/widgets/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация с обработкой всех ошибок
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  try {
    BlocProviders.setup();
  } catch (e, stackTrace) {
    debugPrint('BlocProviders setup error: $e\n$stackTrace');
    // Продолжаем даже если setup упал
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization error: $e\n$stackTrace');
  }

  // Инициализация SDK в фоне (не блокируем запуск)
  _initializeSDKsInBackground();

  runApp(const MyApp());
}

void _initializeSDKsInBackground() {
  // Запускаем инициализацию асинхронно, не ждем завершения
  Future.microtask(() async {
    try {
      AppMetrica.activate(const AppMetricaConfig('6243466'));
      debugPrint('AppMetrica initialized');
    } catch (e) {
      debugPrint('AppMetrica error: $e');
    }

    try {
      await getIt<AppHudService>().init();
      debugPrint('AppHud initialized');
    } catch (e) {
      debugPrint('AppHud error: $e');
    }

    try {
      await getIt<AppsFlyerService>().init();
      final attributionData = await getIt<AppsFlyerService>().getAttributionData();
      await getIt<AppHudService>().setAttribution(attributionData);
      debugPrint('AppsFlyer initialized');
    } catch (e) {
      debugPrint('AppsFlyer error: $e');
    }

    try {
      await getIt<AdMobService>().init();
      debugPrint('AdMob initialized');
    } catch (e) {
      debugPrint('AdMob error: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TalkerBuilder(
      talker: getIt<Talker>(),
      builder: (context, talker) {
        return MaterialApp.router(
          title: 'Background Eraser',
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
