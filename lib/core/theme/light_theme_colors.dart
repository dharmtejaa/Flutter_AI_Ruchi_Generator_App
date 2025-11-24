import 'package:flutter/material.dart';

class LightThemeColors {
  // ——— Clean White Shades (Perfect for Light Mode) ———
  static const Color pureWhite = Color(0xFFFFFFFF); // Pure white background
  static const Color softWhite = Color(0xFFFbFbFb); // Soft white surface
  static const Color lightGray = Color(0xFFfefefe); // Light gray background
  static const Color mediumGray = Color(0xFFF1F0F0); // Medium gray surface
  static const Color warmGray = Color(0xFFEEEEEE); // Warm gray container
  static const Color subtleGray = Color(0xFFE8E8E8); // Subtle gray variant
  static const Color coolGray = Color(0xFFE0E0E0); // Cool gray border

  // ——— Text Colors with Enhanced Contrast ———
  static const Color deepBlack = Color(0xFF1A1A1A); // Primary headings
  static const Color richBlack = Color(0xFF2D2D2D); // Secondary text
  static const Color darkGray = Color(0xFF313130); // Body text
  static const Color softGrey = Color(0xFF888888); // Caption text
  static const Color mutedText = Color(0xFF9E9E9E); // Disabled text
  static const Color lightText = Color(0xFFBDBDBD); // Placeholder text

  // ——— Border and Divider Colors ———
  static const Color primaryBorder = Color(0xFFE0E0E0); // Primary borders
  static const Color secondaryBorder = Color(0xFFF0F0F0); // Secondary borders
  static const Color subtleBorder = Color(0xFFF5F5F5); // Subtle borders
  static const Color dividerColor = Color(0xFFEEEEEE); // Dividers

  // ——— Accent Colors for Light Theme ———
  static const Color primaryOrange = Color(0xFFFF7043); // Main brand color
  static const Color primaryGreenLight = Color(0xFF66BB6A); // Light variant
  static const Color primaryGreenDark = Color(0xFF2E7D32); // Dark variant

  static const Color secondaryOrange = Color(0xFFFF6F00); // Secondary brand
  static const Color secondaryOrangeLight = Color(0xFFFF8A50); // Light variant

  static const Color accentBlue = Color(0xFF2196F3); // Info color
  static const Color accentPurple = Color(0xFF9C27B0); // Special accent
  static const Color accentTeal = Color(0xFF009688); // Alternative accent

  // ——— Status Colors ———
  static const Color successGreen = Color(0xFF43A047); // Success state
  static const Color warningOrange = Color(0xFFFF9800); // Warning state
  static const Color errorRed = Color(0xFFE53935); // Error state
  static const Color infoBlue = Color(0xFF2196F3); // Info state

  // ——— Shadow Colors ———
  static Color shadowLight = Colors.grey.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.grey.withValues(alpha: 0.08);
  static Color shadowHeavy = Colors.grey.withValues(alpha: 0.12);
  // ignore: deprecated_member_use
  static Color shadowIntense = Colors.grey.withOpacity(0.1);

  // ——— Overlay Colors ———
  static Color overlayLight = Colors.black.withValues(alpha: 0.05);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.1);
  static Color overlayHeavy = Colors.black.withValues(alpha: 0.2);
  static Color overlayIntense = Colors.black.withValues(alpha: 0.4);

  /// Get a color with opacity for light theme
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
 
}
