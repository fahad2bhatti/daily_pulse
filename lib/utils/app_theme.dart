import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg1,
    fontFamily: 'Nunito',
    useMaterial3: false,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.teal,
      surface: AppColors.card,
    ),
  );
}
