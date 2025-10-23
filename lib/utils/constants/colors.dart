import 'package:flutter/material.dart';

class FColors {
  FColors._();

  // -------------------- App Basic Colors --------------------
  static const Color primary = Color(0xFF4BAF6F);
  static const Color secondary = Color(0xFFFFE24B);
  static const Color accent = Color(0xFF80C7AF);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color transparent = Color(0x00000000);

  // Event Status Colors
  static const Color upcoming = Color(0xFF2196F3); // Blue for upcoming events
  static const Color ongoing = Color(0xFFFF9800); // Orange for ongoing events
  static const Color completed = Color(0xFF4CAF50); // Green for completed events
  static const Color cancelled = Color(0xFFF44336); // Red for cancelled events

  // Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xFFFF9A9E),
      Color(0xFFFAD0C4),
      Color(0xFFFAD0C4),
    ],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C7570);
  static const Color textWhite = Colors.white;

  // Background Colors
  // static const Color light = Color(0xFFF6F6F6);
  static const Color light = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5F5);

  // Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = FColors.white.withOpacity(0.1);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF4BAF6F);
  static const Color buttonSecondary = Color(0xFF6C7570);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and Validation Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Leaderboard Colors
  static const Color leaderboardGold = Color(0xFFFFD700);
  static const Color leaderboardSilver = Color(0xFFC0C0C0);
  static const Color leaderboardBronze = Color(0xFFCD7F32);
  static const Color leaderboardAccent = Color(0xFF4DD4AC);

  // Leaderboard Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8E8E8), Color(0xFFC0C0C0)],
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6A57E), Color(0xFFCD7F32)],
  );

  // -------------------- Admin Side Colors --------------------

  // Admin Light Theme - Clean & Professional
  static const Color adminLightPrimary = Color(0xFF5E72E4);  // Modern purple-blue
  static const Color adminLightSecondary = Color(0xFF2DCE89);  // Success green
  static const Color adminLightAccent = Color(0xFF11CDEF);  // Info cyan
  static const Color adminLightBackground = Color(0xFFF7F8FC);  // Very light gray-blue
  static const Color adminLightSurface = Color(0xFFFFFFFF);  // Pure white cards
  static const Color adminLightSurfaceVariant = Color(0xFFFBFCFD);  // Slightly off-white

  // Admin Light Text & Icons
  static const Color adminLightText = Color(0xFF32325D);  // Dark blue-gray
  static const Color adminLightTextSecondary = Color(0xFF8898AA);  // Medium gray
  static const Color adminLightTextMuted = Color(0xFFADB5BD);  // Light gray
  static const Color adminLightIcon = Color(0xFF525F7F);  // Icon gray

  // Admin Light Borders & Dividers
  static const Color adminLightBorder = Color(0xFFE9ECEF);  // Light border
  static const Color adminLightDivider = Color(0xFFDEE2E6);  // Divider

  // Admin Light Status Colors
  static const Color adminLightSuccess = Color(0xFF2DCE89);  // Green
  static const Color adminLightError = Color(0xFFF5365C);  // Red
  static const Color adminLightWarning = Color(0xFFFB6340);  // Orange
  static const Color adminLightInfo = Color(0xFF11CDEF);  // Cyan

  // Admin Light Interactive States
  static const Color adminLightHover = Color(0xFFF6F9FC);  // Hover background
  static const Color adminLightSelected = Color(0xFFE8EBFF);  // Selected background
  static const Color adminLightFocus = Color(0xFF5E72E4);  // Focus color

  // Admin Dark Theme - Modern & Elegant
  static const Color adminDarkPrimary = Color(0xFF7B8CFF);  // Lighter purple-blue
  static const Color adminDarkSecondary = Color(0xFF4FD69C);  // Light success green
  static const Color adminDarkAccent = Color(0xFF37D5F2);  // Light info cyan
  static const Color adminDarkBackground = Color(0xFF0B1929);  // Deep blue-black
  static const Color adminDarkSurface = Color(0xFF111B2B);  // Card surface
  static const Color adminDarkSurfaceVariant = Color(0xFF1A2332);  // Elevated surface

  // Admin Dark Text & Icons
  static const Color adminDarkText = Color(0xFFE2E8F0);  // Light gray-white
  static const Color adminDarkTextSecondary = Color(0xFF94A3B8);  // Medium gray
  static const Color adminDarkTextMuted = Color(0xFF64748B);  // Muted gray
  static const Color adminDarkIcon = Color(0xFFCBD5E1);  // Icon light gray

  // Admin Dark Borders & Dividers
  static const Color adminDarkBorder = Color(0xFF1E293B);  // Dark border
  static const Color adminDarkDivider = Color(0xFF2D3748);  // Dark divider

  // Admin Dark Status Colors
  static const Color adminDarkSuccess = Color(0xFF4FD69C);  // Light green
  static const Color adminDarkError = Color(0xFFFC7C8A);  // Light red
  static const Color adminDarkWarning = Color(0xFFFFB76D);  // Light orange
  static const Color adminDarkInfo = Color(0xFF37D5F2);  // Light cyan

  // Admin Dark Interactive States
  static const Color adminDarkHover = Color(0xFF1E293B);  // Hover background
  static const Color adminDarkSelected = Color(0xFF2A3F5F);  // Selected background
  static const Color adminDarkFocus = Color(0xFF7B8CFF);  // Focus color

  // Gradient Colors for Charts and Special Elements
  static const List<Color> adminChartColors = [
    Color(0xFF5E72E4),  // Primary
    Color(0xFF2DCE89),  // Success
    Color(0xFF11CDEF),  // Info
    Color(0xFFFB6340),  // Warning
    Color(0xFFF5365C),  // Error
    Color(0xFFFBD38D),  // Yellow
    Color(0xFF8B5CF6),  // Purple
  ];

  // Special Effects
  static const Color adminGlassLight = Color(0x0DFFFFFF);  // Glass effect light
  static const Color adminGlassDark = Color(0x1AFFFFFF);  // Glass effect dark
  static const Color adminShadow = Color(0x1A000000);  // Shadow color
}