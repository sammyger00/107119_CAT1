import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // Parcel Status Colors
  static const Color statusSent = Color(0xFF9E9E9E); // Grey
  static const Color statusLoaded = Color(0xFF2196F3); // Blue
  static const Color statusOffloaded = Color(0xFFFF9800); // Orange
  static const Color statusReceived = Color(0xFF4CAF50); // Green
  static const Color statusIssued = Color(0xFF673AB7); // Purple

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color dividerLight = Color(0xFFBDBDBD);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF404040);

  // Payment Method Colors
  static const Color mpesa = Color(0xFF00A859); // M-Pesa Green
  static const Color familyBank = Color(0xFFE31E24); // Family Bank Red
  static const Color cash = Color(0xFF4CAF50); // Green

  // Utility Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
}
