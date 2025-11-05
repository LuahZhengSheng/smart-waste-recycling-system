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
  static const Color upcoming = Color(0xFF2196F3);
  static const Color ongoing = Color(0xFFFF9800);
  static const Color completed = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFF44336);

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
  static const Color light = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF1A1A1A); // 更新：更柔和的深色
  static const Color primaryBackground = Color(0xFFF3F5F5);

  // Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color darkContainer = Color(0xFF2A2A2A); // 更新：深色容器

  // Button Colors
  static const Color buttonPrimary = Color(0xFF4BAF6F);
  static const Color buttonSecondary = Color(0xFF6C7570);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);
  static const Color borderDark = Color(0xFF3A3A3A); // 新增：深色边框

  // Error and Validation Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF333333); // 更新：更明亮的深灰色
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Dark Mode Specific Colors
  static const Color darkSurface = Color(0xFF1E1E1E); // Elevated surface
  static const Color darkBackground = Color(0xFF121212); // Base background
  static const Color darkText = Color(0xFFE0E0E0); // Primary text in dark mode
  static const Color darkTextSecondary = Color(0xFF9E9E9E); // Secondary text in dark mode
  static const Color darkDivider = Color(0xFF2C2C2C); // Divider in dark mode

  // Community Dark Mode Colors - 新增
  static const Color communityDarkBackground = Color(0xFF1A1A1A);
  static const Color communityDarkSurface = Color(0xFF2A2A2A);
  static const Color communityDarkBorder = Color(0xFF3A3A3A);
  static const Color communityDarkDivider = Color(0xFF333333);

  // -------------------- Event Module Colors --------------------

  // Event Card Colors (for different event types)
  static const Color eventWasteColor = Color(0xFFFFE5E5);
  static const Color eventWasteIcon = Color(0xFFFF6B6B);

  static const Color eventConferenceColor = Color(0xFFE5E5FF);
  static const Color eventConferenceIcon = Color(0xFF6B6BFF);

  static const Color eventLeadershipColor = Color(0xFFE5F5FF);
  static const Color eventLeadershipIcon = Color(0xFF9B6BFF);

  static const Color eventKidsColor = Color(0xFFE5F0FF);
  static const Color eventKidsIcon = Color(0xFF6B9BFF);

  // Helper method to get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? FColors.black : FColors.white;
  }

  // -------------------- Leaderboard Module Colors --------------------

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
  static const Color adminLightPrimary = Color(0xFF5E72E4);
  static const Color adminLightSecondary = Color(0xFF2DCE89);
  static const Color adminLightAccent = Color(0xFF11CDEF);
  static const Color adminLightBackground = Color(0xFFF7F8FC);
  static const Color adminLightSurface = Color(0xFFFFFFFF);
  static const Color adminLightSurfaceVariant = Color(0xFFFBFCFD);

  static const Color adminLightText = Color(0xFF32325D);
  static const Color adminLightTextSecondary = Color(0xFF8898AA);
  static const Color adminLightTextMuted = Color(0xFFADB5BD);
  static const Color adminLightIcon = Color(0xFF525F7F);

  static const Color adminLightBorder = Color(0xFFE9ECEF);
  static const Color adminLightDivider = Color(0xFFDEE2E6);

  static const Color adminLightSuccess = Color(0xFF2DCE89);
  static const Color adminLightError = Color(0xFFF5365C);
  static const Color adminLightWarning = Color(0xFFFB6340);
  static const Color adminLightInfo = Color(0xFF11CDEF);

  static const Color adminLightHover = Color(0xFFF6F9FC);
  static const Color adminLightSelected = Color(0xFFE8EBFF);
  static const Color adminLightFocus = Color(0xFF5E72E4);

  static const Color adminDarkPrimary = Color(0xFF7B8CFF);
  static const Color adminDarkSecondary = Color(0xFF4FD69C);
  static const Color adminDarkAccent = Color(0xFF37D5F2);
  static const Color adminDarkBackground = Color(0xFF0B1929);
  static const Color adminDarkSurface = Color(0xFF111B2B);
  static const Color adminDarkSurfaceVariant = Color(0xFF1A2332);

  static const Color adminDarkText = Color(0xFFE2E8F0);
  static const Color adminDarkTextSecondary = Color(0xFF94A3B8);
  static const Color adminDarkTextMuted = Color(0xFF64748B);
  static const Color adminDarkIcon = Color(0xFFCBD5E1);

  static const Color adminDarkBorder = Color(0xFF1E293B);
  static const Color adminDarkDivider = Color(0xFF2D3748);

  static const Color adminDarkSuccess = Color(0xFF4FD69C);
  static const Color adminDarkError = Color(0xFFFC7C8A);
  static const Color adminDarkWarning = Color(0xFFFFB76D);
  static const Color adminDarkInfo = Color(0xFF37D5F2);

  static const Color adminDarkHover = Color(0xFF1E293B);
  static const Color adminDarkSelected = Color(0xFF2A3F5F);
  static const Color adminDarkFocus = Color(0xFF7B8CFF);

  static const List<Color> adminChartColors = [
    Color(0xFF5E72E4),
    Color(0xFF2DCE89),
    Color(0xFF11CDEF),
    Color(0xFFFB6340),
    Color(0xFFF5365C),
    Color(0xFFFBD38D),
    Color(0xFF8B5CF6),
  ];

  static const Color adminGlassLight = Color(0x0DFFFFFF);
  static const Color adminGlassDark = Color(0x1AFFFFFF);
  static const Color adminShadow = Color(0x1A000000);
}