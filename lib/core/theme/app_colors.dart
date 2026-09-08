import 'package:flutter/material.dart';

/// Semantic color palette for OptiMeal.
/// Forest/Emerald green reflects sustainability and food rescue.
/// Deep Navy & Slate reflect trust, reliability, and security.
class AppColors {
  AppColors._();

  // Primary - Sustainability Green
  static const Color primary = Color(0xFF2E7D32); // Emerald / Forest Green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryContainer = Color(0xFFD4EDDA);
  static const Color onPrimary = Colors.white;

  // Secondary - Deep Navy
  static const Color secondary = Color(0xFF1A237E); // Deep Navy
  static const Color secondaryLight = Color(0xFF3949AB);
  static const Color secondaryDark = Color(0xFF0D1B2A);
  static const Color secondaryContainer = Color(0xFFE8EAF6);
  static const Color onSecondary = Colors.white;

  // Status Colors
  static const Color statusAvailable = Color(0xFF2E7D32); // Green
  static const Color statusReserved = Color(0xFFEF6C00); // Amber / Orange
  static const Color statusCompleted = Color(0xFF1565C0); // Blue
  static const Color statusExpired = Color(0xFF757575); // Grey
  static const Color statusCancelled = Color(0xFFC62828); // Red

  // Accent & Warnings
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF0288D1);

  // Background & Surface - Light
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color borderLight = Color(0xFFDEE2E6);

  // Background & Surface - Dark
  static const Color backgroundDark = Color(0xFF0F172A); // Dark Slate
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
}
