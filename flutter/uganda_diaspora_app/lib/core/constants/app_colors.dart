import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Core (design system spec) ─────────────────────────────────────
  static const Color primaryBlack  = Color(0xFF121212);
  static const Color darkOrange    = Color(0xFFD97706);  // primary accent
  static const Color deepRed       = Color(0xFFB91C1C);  // secondary accent

  // ── Uganda flag (for flag-specific display) ──────────────────────────────
  static const Color ugandaBlack  = Color(0xFF1A1A1A);
  static const Color ugandaYellow = Color(0xFFFFCE00);
  static const Color ugandaRed    = Color(0xFFD90026);
  static const Color craneWhite   = Color(0xFFFFFFFF);

  // ── Semantic aliases (used throughout the app) ───────────────────────────
  static const Color primary      = primaryBlack;
  static const Color primaryLight = Color(0xFF374151);
  static const Color primaryDark  = Color(0xFF030712);
  static const Color accent       = darkOrange;

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error   = Color(0xFFDC2626);
  static const Color info    = Color(0xFF2563EB);

  // ── Light theme ──────────────────────────────────────────────────────────
  static const Color backgroundLight      = Color(0xFFF7F7F7);
  static const Color surfaceLight         = Color(0xFFFFFFFF);
  static const Color cardLight            = Color(0xFFFFFFFF);
  static const Color textPrimaryLight     = Color(0xFF121212);
  static const Color textSecondaryLight   = Color(0xFF6B7280);
  static const Color textMutedLight       = Color(0xFF9CA3AF);
  static const Color dividerLight         = Color(0xFFE5E7EB);
  static const Color inputBackgroundLight = Color(0xFFF3F4F6);

  // ── Dark theme ───────────────────────────────────────────────────────────
  static const Color backgroundDark    = Color(0xFF0A0A0A);
  static const Color surfaceDark       = Color(0xFF1A1A1A);
  static const Color cardDark          = Color(0xFF242424);
  static const Color textPrimaryDark   = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark       = Color(0xFF2D2D2D);
  static const Color inputBackgroundDark = Color(0xFF1A1A1A);

  // ── Category colours ─────────────────────────────────────────────────────
  static const Color tourismOrange  = Color(0xFFD97706);
  static const Color webinarPurple  = Color(0xFF7C3AED);
  static const Color embassyTeal    = Color(0xFF0891B2);
  static const Color opportunityGold= Color(0xFFD97706);
  static const Color diasporaBlue   = Color(0xFF1D4ED8);
  static const Color nationalGreen  = Color(0xFF16A34A);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF121212), Color(0xFF1C0A00)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFB45309)],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB91C1C), Color(0xFF991B1B)],
  );

  static const LinearGradient ugandaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121212), Color(0xFF1A0800), Color(0xFF2D1000)],
  );

  // Kept for backward compat
  static const LinearGradient primaryGradient = heroGradient;
}
