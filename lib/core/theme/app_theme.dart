import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.whiteColor),
      titleTextStyle: TextStyle(
        color: AppColors.whiteColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.whiteColor),
      bodyMedium: TextStyle(color: AppColors.whiteColor),
      bodySmall: TextStyle(color: AppColors.white210Color),
      titleLarge: TextStyle(color: AppColors.whiteColor),
      titleMedium: TextStyle(color: AppColors.whiteColor),
      titleSmall: TextStyle(color: AppColors.white210Color),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.aquaColor,
      secondary: AppColors.pinkColor,
      surface: Colors.transparent,
      onPrimary: AppColors.whiteColor,
      onSecondary: AppColors.whiteColor,
      onSurface: AppColors.whiteColor,
    ),
  );

  static final ThemeData lightTheme = darkTheme;
}
