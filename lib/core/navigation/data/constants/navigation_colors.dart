import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NavigationColors {
  NavigationColors._();

  static const Color selectedIconColor = AppColors.navActiveColor;
  static const Color unselectedIconColor = AppColors.navInactiveColor;

  static Color getSelectedGlowColor() => AppColors.aquaColor.withOpacity(0.5);

  static Color getUnselectedGlowColor() => AppColors.whiteColor.withOpacity(0.2);

  static Color getGlassGlowColor() => AppColors.whiteColor.withOpacity(0.15);

  static Color getIndicatorShadowColor() => AppColors.aquaColor.withOpacity(0.4);

  static Color getContainerShadowColor() => Colors.black.withOpacity(0.8);

  static Color getBorderColor(bool isDark) {
    return AppColors.white018Color;
  }

  static double getBorderWidth(bool isDark) {
    return 1.0;
  }

  static Color getGlassColor(bool isDark) => AppColors.whiteColor.withOpacity(0.1);
}

