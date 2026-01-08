import 'package:flutter/material.dart';

class AppColors {
  static const Color whiteColor = Color(0xFFF4F4F4);
  static const Color white210Color = Color(0xFFD2D2D2);
  static const Color white018Color = Color(0x2EFFFFFF);
  static const Color white032Color = Color(0x52FFFFFF);

  static const Color primary = Colors.white;
  static const Color secondary = whiteColor;

  static const orangeColor = Color(0xFFFA454D);
  static const redColor = Color(0xFFFA454D);
  static const pinkColor = Color(0xFFDB0082);
  static const yellowColor = Color(0xFFDBDC69);
  static const lemonColor = Color(0xFFDBDC69);

  static const aquaColor = Color(0xFF68CDD2);

  static const navActiveColor = Color(0xFF68CDD2);
  static const navInactiveColor = AppColors.whiteColor;

  static final buttonColor = LinearGradient(colors: [pinkColor, orangeColor]);

  static final scaffoldColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF02132D), Color(0xFF3E161E)],
  );

  static final bottomNavColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5B2E37), Color(0xFF02132D)],
  );

  static final editPhotoBtnColor = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xFF6C2F3B), Color(0xFF4F4F95)],
    stops: [0.3, 1],
  );

  // Slider colors
  static const Color sliderActiveColor = Color(0xFFDB0082);
  static const Color sliderInactiveColor = Color(0x2EFFFFFF);
  static const Color sliderThumbColor = Colors.white;
  static const Color sliderValueColor = Colors.white;
}
