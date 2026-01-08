import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'core/bloc/bloc_providers.dart' show BlocProviders, getIt;
import 'core/navigation/presentation/widgets/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  BlocProviders.setup();
  runApp(const MyApp());
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
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
