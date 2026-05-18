import 'package:flutter/material.dart';

class AppColors {
  // Uganda flag colors
  static const Color ugandaBlack = Color(0xFF1A1A1A);
  static const Color ugandaYellow = Color(0xFFFFCE00);
  static const Color ugandaRed = Color(0xFFD90026);
  static const Color craneWhite = Color(0xFFFFFFFF);

  // Brand Primary
  static const Color primary = Color(0xFF1B4B91); // Deep diplomatic blue
  static const Color primaryLight = Color(0xFF2E6DC8);
  static const Color primaryDark = Color(0xFF0D2F5C);
  static const Color accent = Color(0xFFFFCE00); // Uganda yellow as accent

  // Status
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Light theme
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color inputBackgroundLight = Color(0xFFF1F5F9);

  // Dark theme
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF243044);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF334155);
  static const Color inputBackgroundDark = Color(0xFF1E293B);

  // Category colors
  static const Color diasporaBlue = Color(0xFF3B82F6);
  static const Color nationalGreen = Color(0xFF10B981);
  static const Color tourismOrange = Color(0xFFF97316);
  static const Color webinarPurple = Color(0xFF8B5CF6);
  static const Color embassyTeal = Color(0xFF06B6D4);
  static const Color opportunityGold = Color(0xFFEAB308);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient ugandaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, Color(0xFF1A5276)],
  );
}
