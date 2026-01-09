import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'dart:io';
import 'dart:typed_data';

import '../../../../features/home/presentation/view/home_screen.dart';
import '../../../../features/eraser/view/eraser_screen.dart';
import '../../../../features/profile/view/profile_screen.dart';
import '../../../../features/paywall/view/paywall_screen.dart';
import '../../../bloc/bloc_providers.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../subscription/apphud_service.dart';
import '../../data/constants/navigation_constants.dart';
import '../../data/utils/page_transitions.dart';
import '../cubit/navigation_cubit.dart';
import 'bottom_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: NavigationConstants.home,
    observers: [TalkerRouteObserver(getIt<Talker>())],
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: NavigationConstants.home,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const HomeScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.profile,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const ProfileScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.logs,
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              child: TalkerScreen(talker: getIt<Talker>()),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.paywall,
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              child: BlocProviders.wrapWithProviders(
                context: context,
                currentLocation: state.uri.path,
                child: const PaywallScreen(),
              ),
              state: state,
            ),
          ),
        ],
      ),
      GoRoute(
        path: NavigationConstants.eraser,
        pageBuilder: (context, state) {
          File? imageFile;
          Uint8List? imageBytes;
          bool useMockImage = false;

          if (state.extra != null) {
            if (state.extra is File) {
              imageFile = state.extra as File;
            } else if (state.extra is Uint8List) {
              imageBytes = state.extra as Uint8List;
            } else if (state.extra is bool) {
              useMockImage = state.extra as bool;
            }
          } else {
            // Use mock image if no image provided
            useMockImage = true;
          }

          return PageTransitions.fadeTransition(
            child: BlocProviders.wrapWithProviders(
              context: context,
              currentLocation: state.uri.path,
              child: EraserScreen(
                imageFile: imageFile,
                imageBytes: imageBytes,
                useMockImage: useMockImage,
              ),
            ),
            state: state,
          );
        },
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProviders.wrapWithProviders(
      context: context,
      child: _NavigationStateUpdater(child: child),
    );
  }
}

class _NavigationStateUpdater extends StatefulWidget {
  final Widget child;

  const _NavigationStateUpdater({required this.child});

  @override
  State<_NavigationStateUpdater> createState() =>
      _NavigationStateUpdaterState();
}

class _NavigationStateUpdaterState extends State<_NavigationStateUpdater> {
  String? _lastLocation;
  Brightness? _lastBrightness;

  void _updateNavigationState() {
    if (!mounted) return;

    final cubit = context.read<NavigationCubit>();
    final newLocation = GoRouterState.of(context).uri.path;
    final newBrightness = MediaQuery.platformBrightnessOf(context);
    final newIsDark = newBrightness == Brightness.dark;

    if (_lastLocation != newLocation) {
      cubit.updateCurrentRoute(newLocation);
      _lastLocation = newLocation;
      _logScreenView(newLocation);
    }
    if (_lastBrightness != newBrightness) {
      cubit.updateTheme(newIsDark);
      _lastBrightness = newBrightness;
    }
  }

  Future<void> _logScreenView(String screenName) async {
    final analyticsService = getIt<AnalyticsService>();
    final appHudService = getIt<AppHudService>();
    final isPremium = await appHudService.isPremium();
    
    analyticsService.logEvent(
      'screen_view',
      {
        'screen_name': screenName,
        'is_premium': isPremium,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationState();
      _logAppOpen();
    });

    AppRouter.router.routerDelegate.addListener(_onRouterChanged);
  }

  Future<void> _logAppOpen() async {
    final analyticsService = getIt<AnalyticsService>();
    final appHudService = getIt<AppHudService>();
    final isPremium = await appHudService.isPremium();
    
    analyticsService.logEvent(
      'app_open',
      {
        'source_screen': GoRouterState.of(context).uri.path,
        'is_premium': isPremium,
      },
    );
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateNavigationState();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newBrightness = MediaQuery.platformBrightnessOf(context);

    if (_lastBrightness != newBrightness) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateNavigationState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomBottomNavigation(),
        ),
      ],
    );
  }
}
