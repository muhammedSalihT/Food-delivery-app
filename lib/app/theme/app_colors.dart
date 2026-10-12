import 'package:flutter/material.dart';

/// Primary Brand and Theme Colors extracted from Food Delivery UI reference
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(
    0xFFFF4B3A,
  ); // Vibrant energetic delivery orange-red
  static const Color primaryDark = Color(0xFFE03A2B);
  static const Color primaryLight = Color(0xFFFFECE9);

  // Secondary & Accents
  static const Color secondary = Color(0xFFFF9500); // Warm amber / rating star
  static const Color accentGreen = Color(
    0xFF2AC17E,
  ); // Vegan / Free Delivery tag
  static const Color accentBlue = Color(0xFF4A90E2);

  // Login / Welcome Screen Specific Palette
  static const Color loginHeaderYellow = Color(0xFFF7C343);
  static const Color loginFieldBg = Color(0xFFF4E5B8);
  static const Color loginButtonOrange = Color(0xFFE85324);
  static const Color loginDarkText = Color(0xFF3B1E1E);
  static const Color loginSubText = Color(0xFF6B6868);
  static const Color loginForgotColor = Color(0xFFE85324);
  static const Color loginSocialCircleBg = Color(0xFFFFE5DD);
  static const Color loginSocialIconColor = Color(0xFFE85324);
  static const Color loginCardBg = Color(0xFFF9F9F9);

  // Home Banner Gradient Colors
  static const Color promoGradientStart = Color(0xFFFF5E48);
  static const Color promoGradientEnd = Color(0xFFFF8A5C);

  // Status & Utility Colors
  static const Color offlineBannerBg = Color(0xFF2C3E50);

  // Neutral & Grayscale
  static const Color background = Color(0xFFF6F6F9); // Light clean backdrop
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  static const Color textPrimary = Color(0xFF1D1E20);
  static const Color textSecondary = Color(0xFF8F959E);
  static const Color textMuted = Color(0xFFB4B9C1);

  static const Color border = Color(0xFFE8E9EC);
  static const Color divider = Color(0xFFF0F1F4);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // State Colors
  static const Color error = Color(0xFFEA3B3B);
  static const Color errorLight = Color(0xFFFFEEEE);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2994A);
}
