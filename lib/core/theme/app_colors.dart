import 'package:flutter/material.dart';

/// Semantic color palette for OptiMeal (updated to match Figma tokens).
/// Forest/Emerald green reflects sustainability and food rescue.
/// Deep Navy & Slate reflect trust, reliability, and security.
class AppColors {
  AppColors._();

  // ── Primary – Forest / Eco Green (from Figma) ──
  static const Color primary = Color(0xFF006B2C);
  static const Color primaryContainer = Color(0xFF00873A);
  static const Color primaryFixed = Color(0xFF7FFC97);
  static const Color onPrimaryFixed = Color(0xFF002109);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  // ── Secondary – Amber/Warm (Figma secondary) ──
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color secondaryFixed = Color(0xFFFFDDB8);
  static const Color onSecondaryFixed = Color(0xFF2A1700);

  // ── Deep Navy (legacy, keep for compatibility) ──
  static const Color navy = Color(0xFF1A237E);
  static const Color navyLight = Color(0xFF3949AB);
  static const Color navyDark = Color(0xFF0D1B2A);

  // ── Surface & Background – Light ──
  static const Color bgSurface = Color(0xFFFAF8FF);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F3FF);
  static const Color surfaceHigh = Color(0xFFE2E7FF);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // ── On-Surface – Light ──
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF3E4A3D);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color borderLight = Color(0xFFDEE2E6);

  // ── Background & Surface – Dark ──
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // ── Status / Semantic ──
  static const Color statusAvailable = Color(0xFF2E7D32);
  static const Color statusReserved = Color(0xFFEF6C00);
  static const Color statusCompleted = Color(0xFF1565C0);
  static const Color statusExpired = Color(0xFF757575);
  static const Color statusCancelled = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF0288D1);
  static const Color notificationBadge = Color(0xFFDA3437);

  // ── Convenience aliases ──
  static const Color onPrimary = Colors.white;
  static const Color textPrimaryLight = onSurface;

  // ── Aliases for theme compatibility ──
  static const Color onSecondary = Colors.white;
  static const Color surfaceLight = surfaceLowest; // light mode card surface
  static const Color secondaryLight =
      secondaryContainer; // dark-theme secondary
  static const Color secondaryDark = secondary; // dark-theme secondaryContainer
}
