import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:dio/dio.dart';

import '../navigation/presentation/cubit/navigation_cubit.dart';
import '../navigation/data/constants/navigation_constants.dart';
import '../shared/widgets/cubit/button_animation_cubit.dart';
import '../shared/widgets/cubit/snackbar_cubit.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/eraser/bloc/eraser_cubit.dart';
import '../../features/eraser/data/datasources/remove_bg_remote_datasource.dart';
import '../../features/eraser/data/repositories/remove_bg_repository_impl.dart';
import '../../features/eraser/domain/repositories/remove_bg_repository.dart';
import '../../features/eraser/domain/usecases/remove_background_usecase.dart';
import '../../features/eraser/data/database/eraser_database.dart';
import '../../features/eraser/data/datasources/eraser_local_datasource.dart';
import '../../features/eraser/data/repositories/eraser_repository_impl.dart';
import '../../features/eraser/domain/repositories/eraser_repository.dart';
import '../../features/eraser/domain/usecases/save_erased_image_usecase.dart';
import '../../features/eraser/domain/usecases/get_recent_erased_images_usecase.dart';
import '../../features/eraser/domain/usecases/clear_all_erased_images_usecase.dart';
import '../../constants/api_constants.dart';

final GetIt getIt = GetIt.instance;

class BlocProviders {
  BlocProviders._();

  static void setup() {
    _registerTalker();
    _registerNavigationCubit();
    _registerButtonAnimationCubit();
    _registerSnackbarCubit();
    _registerHomeBloc();
    _registerEraserCubit();
    // TODO: Add history and separation when features are ready
    // _registerHistory();
    // _registerSeparation();
  }

  static void _registerTalker() {
    getIt.registerLazySingleton<Talker>(() => TalkerFlutter.init());
  }

  static void _registerNavigationCubit() {
    getIt.registerFactoryParam<NavigationCubit, String, bool>(
      (currentLocation, isDark) =>
          NavigationCubit(currentLocation: currentLocation, isDark: isDark),
    );
  }

  static void _registerButtonAnimationCubit() {
    getIt.registerFactory<ButtonAnimationCubit>(
      () => ButtonAnimationCubit(),
    );
  }

  static void _registerSnackbarCubit() {
    getIt.registerSingleton<SnackbarCubit>(
      SnackbarCubit(),
    );
  }

  static void _registerHomeBloc() {
    getIt.registerLazySingleton<HomeBloc>(
      () => HomeBloc(
        getRecentErasedImagesUseCase: getIt<GetRecentErasedImagesUseCase>(),
        saveErasedImageUseCase: getIt<SaveErasedImageUseCase>(),
        talker: getIt<Talker>(),
      ),
    );
  }

  static void _registerEraserCubit() {
    getIt.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(
        baseUrl: ApiConstants.removeBgBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )),
      instanceName: 'removeBgDio',
    );

    getIt.registerFactory<RemoveBgRemoteDataSource>(
      () => RemoveBgRemoteDataSource(
        dio: getIt<Dio>(instanceName: 'removeBgDio'),
        talker: getIt<Talker>(),
      ),
    );

    getIt.registerFactory<RemoveBgRepository>(
      () => RemoveBgRepositoryImpl(
        getIt<RemoveBgRemoteDataSource>(),
      ),
    );

    getIt.registerFactory<RemoveBackgroundUseCase>(
      () => RemoveBackgroundUseCase(
        getIt<RemoveBgRepository>(),
      ),
    );

    getIt.registerLazySingleton<EraserDatabase>(
      () => EraserDatabase(),
    );

    getIt.registerFactory<EraserLocalDataSource>(
      () => EraserLocalDataSource(
        getIt<EraserDatabase>(),
        getIt<Talker>(),
      ),
    );

    getIt.registerFactory<EraserRepository>(
      () => EraserRepositoryImpl(
        getIt<EraserLocalDataSource>(),
      ),
    );

    getIt.registerFactory<SaveErasedImageUseCase>(
      () => SaveErasedImageUseCase(
        getIt<EraserRepository>(),
      ),
    );

    getIt.registerFactory<GetRecentErasedImagesUseCase>(
      () => GetRecentErasedImagesUseCase(
        getIt<EraserRepository>(),
      ),
    );

    getIt.registerFactory<ClearAllErasedImagesUseCase>(
      () => ClearAllErasedImagesUseCase(
        getIt<EraserRepository>(),
      ),
    );

    getIt.registerFactory<EraserCubit>(
      () => EraserCubit(
        getIt<RemoveBackgroundUseCase>(),
        getIt<Talker>(),
      ),
    );
  }


  static Widget wrapWithProviders({
    required BuildContext context,
    required Widget child,
    String? currentLocation,
    bool? isDark,
  }) {
    // Try to get GoRouterState, fallback to defaults if not available
    String location;
    bool dark;
    
    try {
      final routerState = GoRouterState.of(context);
      location = routerState.uri.path;
    } catch (e) {
      location = currentLocation ?? NavigationConstants.home;
    }
    
    try {
      final brightness = MediaQuery.platformBrightnessOf(context);
      dark = brightness == Brightness.dark;
    } catch (e) {
      dark = isDark ?? false;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (_) =>
              getIt<NavigationCubit>(param1: location, param2: dark),
        ),
        BlocProvider<HomeBloc>.value(
          value: getIt<HomeBloc>(),
        ),
        BlocProvider<SnackbarCubit>.value(
          value: getIt<SnackbarCubit>(),
        ),
        BlocProvider<EraserCubit>(
          create: (_) => getIt<EraserCubit>(),
        ),
        // TODO: Add when features are ready
        // BlocProvider(
        //   create: (_) => getIt<OverlayCubit>(),
        // ),
        // BlocProvider(
        //   create: (_) => getIt<SeparationBloc>(),
        // ),
        // BlocProvider(
        //   create: (_) => getIt<HistoryBloc>(),
        // ),
      ],
      child: child,
    );
  }
}
