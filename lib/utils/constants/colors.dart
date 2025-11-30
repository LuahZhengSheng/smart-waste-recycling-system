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

  // -------------------- Transaction Details Colors --------------------
  static const Color transactionEarning = Color(0xFF4CAF50); // Green for earning
  static const Color transactionSpending = Color(0xFFE53935); // Red for spending
  static const Color transactionCardLight = Color(0xFFFFFFFF);
  static const Color transactionCardDark = Color(0xFF2A2A2A);
  static const Color transactionBorderLight = Color(0xFFE0E0E0);
  static const Color transactionBorderDark = Color(0xFF3A3A3A);
  static const Color transactionLabelLight = Color(0xFF757575);
  static const Color transactionLabelDark = Color(0xFF9E9E9E);
  static const Color transactionValueLight = Color(0xFF212121);
  static const Color transactionValueDark = Color(0xFFE0E0E0);

  // Badge Colors for Transaction Status
  static const Color badgeCompleted = Color(0xFF4CAF50);
  static const Color badgePending = Color(0xFFFFA726);
  static const Color badgeExpired = Color(0xFF757575);

  // -------------------- Carbon Footprint Calculator Module Colors --------------------
  
  // Category Colors - vibrant and distinct
  static const Color landTravel = Color(0xFF6B5CF6); // Purple
  static const Color airTravel = Color(0xFFE91E63); // Pink
  static const Color energy = Color(0xFFFFC107); // Amber/Yellow
  static const Color food = Color(0xFFFF5722); // Deep Orange
  static const Color stuff = Color(0xFFF44336); // Red

  // Light mode variants (with opacity for backgrounds)
  static Color landTravelLight = landTravel.withOpacity(0.1);
  static Color airTravelLight = airTravel.withOpacity(0.1);
  static Color energyLight = energy.withOpacity(0.1);
  static Color foodLight = food.withOpacity(0.1);
  static Color stuffLight = stuff.withOpacity(0.1);

  // Dark mode variants (lighter versions)
  static const Color landTravelDark = Color(0xFF9B8CF7);
  static const Color airTravelDark = Color(0xFFF48FB1);
  static const Color energyDark = Color(0xFFFFD54F);
  static const Color foodDark = Color(0xFFFF8A65);
  static const Color stuffDark = Color(0xFFEF5350);

  // -------------------- Community Module Colors --------------------

  // Community Dark Mode Colors
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

  // -------------------- Staff Side Colors (Blue Theme) --------------------

  // Staff Light Theme
  static const Color staffLightPrimary = Color(0xFF2196F3); // Blue
  static const Color staffLightSecondary = Color(0xFF4CAF50); // Green for success
  static const Color staffLightAccent = Color(0xFF00BCD4); // Cyan
  static const Color staffLightBackground = Color(0xFFF5F7FA);
  static const Color staffLightSurface = Color(0xFFFFFFFF);
  static const Color staffLightSurfaceVariant = Color(0xFFF8FAFB);

  static const Color staffLightText = Color(0xFF1E3A5F);
  static const Color staffLightTextSecondary = Color(0xFF7A8FA6);
  static const Color staffLightTextMuted = Color(0xFFA8B8CC);
  static const Color staffLightIcon = Color(0xFF4A5F7F);

  static const Color staffLightBorder = Color(0xFFE1E8F0);
  static const Color staffLightDivider = Color(0xFFD4DCE6);

  static const Color staffLightSuccess = Color(0xFF4CAF50);
  static const Color staffLightError = Color(0xFFE53935);
  static const Color staffLightWarning = Color(0xFFFFA726);
  static const Color staffLightInfo = Color(0xFF29B6F6);

  static const Color staffLightHover = Color(0xFFF0F4F8);
  static const Color staffLightSelected = Color(0xFFE3F2FD);
  static const Color staffLightFocus = Color(0xFF2196F3);

  static const Color adminLightCard = Color(0xFFFFFFFF);
  static const Color adminLightCardHover = Color(0xFFF6F9FC);
  static const Color adminLightGlass = Color(0x0DFFFFFF);
  static const Color adminLightShadow = Color(0x1A000000);

  // Status colors for recycling centers
  static const Color adminLightActive = Color(0xFF2DCE89);
  static const Color adminLightDisabled = Color(0xFF8898AA);

  // Badge colors
  static const Color adminLightBadgeVerified = Color(0xFF2DCE89);
  static const Color adminLightBadgeActive = Color(0xFF11CDEF);
  static const Color adminLightBadgeInactive = Color(0xFF8898AA);
  static const Color adminLightBadgeBanned = Color(0xFFF5365C);

  // Staff Dark Theme
  static const Color staffDarkPrimary = Color(0xFF64B5F6); // Light Blue
  static const Color staffDarkSecondary = Color(0xFF66BB6A); // Light Green
  static const Color staffDarkAccent = Color(0xFF4DD0E1); // Light Cyan
  static const Color staffDarkBackground = Color(0xFF0D1B2A);
  static const Color staffDarkSurface = Color(0xFF1B2838);
  static const Color staffDarkSurfaceVariant = Color(0xFF253447);

  static const Color staffDarkText = Color(0xFFE3EBF5);
  static const Color staffDarkTextSecondary = Color(0xFF9DB4CD);
  static const Color staffDarkTextMuted = Color(0xFF6B8199);
  static const Color staffDarkIcon = Color(0xFFB8CDE0);

  static const Color staffDarkBorder = Color(0xFF1E3247);
  static const Color staffDarkDivider = Color(0xFF2A3F54);

  static const Color staffDarkSuccess = Color(0xFF66BB6A);
  static const Color staffDarkError = Color(0xFFEF5350);
  static const Color staffDarkWarning = Color(0xFFFFB74D);
  static const Color staffDarkInfo = Color(0xFF4FC3F7);

  static const Color staffDarkHover = Color(0xFF1E3247);
  static const Color staffDarkSelected = Color(0xFF2A4A6E);
  static const Color staffDarkFocus = Color(0xFF64B5F6);

  static const Color adminDarkCard = Color(0xFF111B2B);
  static const Color adminDarkCardHover = Color(0xFF1E293B);
  static const Color adminDarkGlass = Color(0x1AFFFFFF);
  static const Color adminDarkShadow = Color(0x1A000000);

  // Status colors for recycling centers
  static const Color adminDarkActive = Color(0xFF4FD69C);
  static const Color adminDarkDisabled = Color(0xFF64748B);

  // Badge colors
  static const Color adminDarkBadgeVerified = Color(0xFF4FD69C);
  static const Color adminDarkBadgeActive = Color(0xFF37D5F2);
  static const Color adminDarkBadgeInactive = Color(0xFF64748B);
  static const Color adminDarkBadgeBanned = Color(0xFFFC7C8A);

  // Staff Chart Colors
  static const List<Color> staffChartColors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFF00BCD4),
    Color(0xFFFFA726),
    Color(0xFFE53935),
    Color(0xFFFDD835),
    Color(0xFF9C27B0),
  ];

  // Staff Gradients
  static const LinearGradient staffPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  static const LinearGradient staffSuccessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
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

  // Admin Light Button Colors
  static const Color adminLightButtonPrimary = Color(0xFF5E72E4);
  static const Color adminLightButtonSuccess = Color(0xFF2DCE89);
  static const Color adminLightButtonDanger = Color(0xFFF5365C);

  static const Color adminLightDeactivate = Color(0xFFF5365C); // Red for deactivate button
  static const Color adminLightActivate = Color(0xFF2DCE89); // Green for activate button

  // For badge/level colors, these helper gradients are useful:
  static const List<Color> levelColorsLight = [
    Color(0xFF9CA3AF), // Level 1 - Gray
    Color(0xFF059669), // Level 2 - Green
    Color(0xFF2563EB), // Level 3 - Blue
    Color(0xFF7C3AED), // Level 4 - Purple
    Color(0xFFD97706), // Level 5 - Orange
    Color(0xFFDC2626), // Level 6+ - Red
  ];

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

  // Admin Dark Button Colors
  static const Color adminDarkButtonPrimary = Color(0xFF7B8CFF);
  static const Color adminDarkButtonSuccess = Color(0xFF4FD69C);
  static const Color adminDarkButtonDanger = Color(0xFFFC7C8A);

  static const Color adminDarkDeactivate = Color(0xFFFC7C8A); // Light red for deactivate button
  static const Color adminDarkActivate = Color(0xFF4FD69C); // Light green for activate button

  static const List<Color> levelColorsDark = [
    Color(0xFF6B7280), // Level 1 - Gray
    Color(0xFF10B981), // Level 2 - Green
    Color(0xFF3B82F6), // Level 3 - Blue
    Color(0xFF8B5CF6), // Level 4 - Purple
    Color(0xFFF59E0B), // Level 5 - Orange
    Color(0xFFEF4444), // Level 6+ - Red
  ];

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

  // Map related colors
  static const Color mapPinRed = Color(0xFFEA4335);
  static const Color mapBorderActive = Color(0xFF4285F4);
  static const Color mapOverlay = Color(0x99000000);
}