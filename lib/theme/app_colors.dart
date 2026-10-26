// theme/app_colors.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFF0F766E);
  static const primaryDeep = Color(0xFF0B4F4A);
  static const primaryNight = Color(0xFF0A3F3B);
  static const primarySoft = Color(0xFFE6F2EF);
  static const accent = Color(0xFFF59E0B);
  static const accentSoft = Color(0xFFFFF3DC);
  static const background = Color(0xFFF4F7F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEFF5F3);
  static const ink = Color(0xFF11231F);
  static const muted = Color(0xFF607570);
  static const outline = Color(0xFFDCE7E4);
  static const success = Color(0xFF1B9C85);
  static const error = Color(0xFFC3423F);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNight, primaryDeep, primary],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primary],
  );
}
