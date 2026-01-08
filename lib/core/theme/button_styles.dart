import 'package:flutter/material.dart';

import 'app_colors.dart';

ButtonStyle primaryButtonStyle({double radius = 10}) {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.white032Color
          : Colors.transparent,
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.pressed)
          ? AppColors.white018Color
          : AppColors.white032Color,
    ),
    elevation: WidgetStateProperty.all<double>(0.0),
    shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
  );
}
