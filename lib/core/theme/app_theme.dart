import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      error: Colors.red,
      onError: Colors.white,
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headingLight,
      bodyLarge: AppTextStyles.bodyLight,
      labelLarge: AppTextStyles.buttonLight,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      error: Colors.red,
      onError: Colors.white,
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headingDark,
      bodyLarge: AppTextStyles.bodyDark,
      labelLarge: AppTextStyles.buttonDark,
    ),
  );
}
