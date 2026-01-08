import 'package:background_eraser/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title, style: AppFonts.displaySmall));
  }
}
