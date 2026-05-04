import 'package:flutter/material.dart';

import 'animations/anim_motion.dart';

class AppTheme {
  // ── Core dark surfaces ───────────────────────────────────────────────────
  static const Color bg           = Color(0xFF111315);
  static const Color surface      = Color(0xFF1E2024);
  static const Color surfaceLow   = Color(0xFF181A1E);
  static const Color surfaceRaised = Color(0xFF23262B);
  static const Color surfaceHigh  = Color(0xFF2A2E34);

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color brand        = Color(0xFFFFFFFF);

  // ── Typography ───────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A5AA);
  static const Color textTertiary  = Color(0xFF666B72);   // ← new

  // ── Structural ───────────────────────────────────────────────────────────
  static const Color divider       = Color(0xFF2A2D32);
  static const Color outlineSoft   = Color(0x1CFFFFFF);
  static const Color outlineStrong = Color(0x33FFFFFF);
  static const Color mutedOverlay  = Color(0x0DFFFFFF);

  // ── Buttons ──────────────────────────────────────────────────────────────
  static const Color buttonText             = Color(0xFF111315);
  static const Color confirmationButtonText = Color(0xFF111315);
  static const Color error                  = Colors.redAccent;

  // ── Motion durations (alias for convenience) ─────────────────────────────
  static const Duration motionFast   = AppDurations.veryFast;
  static const Duration motionMedium = AppDurations.standard;
  static const Duration motionSlow   = AppDurations.slowReveal;

  // =========================================================================
  // EDITORIAL / VFX PALETTE
  // These tokens are used exclusively by the premium motion widgets and
  // editorial screen sections.
  // =========================================================================

  /// Warm cream — panel wipes, canvas interstitials, menu overlays.
  static const Color editorialCream      = Color(0xFFF5F0E8);

  /// Soft cream with very low opacity — menu row highlight bands.
  static const Color editorialCreamBand  = Color(0x16F5F0E8);

  /// Hairline divider on dark backgrounds.
  static const Color hairlineDark        = Color(0x20FFFFFF);

  /// Hairline divider on cream/light backgrounds.
  static const Color hairlineLight       = Color(0x30000000);

  /// Deep cinematic dark (slightly warmer than pure black).
  static const Color cinematicDark       = Color(0xFF0D0F10);

  /// Hero image overlay — dims the image for cinematic atmosphere.
  static const Color heroScrim           = Color(0xCC111315);

  // =========================================================================
  // GRADIENTS
  // =========================================================================
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x08FFFFFF), Color(0x00000000)],
  );

  /// Hero scrim gradient — dark at the bottom, transparent at the top.
  static const LinearGradient heroScrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00111315), Color(0xEE111315)],
    stops: [0.35, 1.0],
  );

  /// Subtle inner glow for premium cards.
  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0CFFFFFF), Color(0x00000000)],
  );

  // =========================================================================
  // SHADOWS
  // =========================================================================
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.015),
          blurRadius: 1,
          offset: const Offset(0, -1),
        ),
      ];

  /// Elevated card shadow — slightly more pronounced for hero cards.
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.32),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.02),
          blurRadius: 1,
          offset: const Offset(0, -1),
        ),
      ];

  // =========================================================================
  // CALENDAR
  // =========================================================================
  static const Color calendarSelectedBg   = Color(0xFF000000);
  static const Color calendarSelectedText = Color(0xFFFFFFFF);

  // =========================================================================
  // CARD ACCENT COLOURS
  // =========================================================================
  static const Color cardBlue   = Color(0xFF60A5FA);
  static const Color cardPurple = Color(0xFFA78BFA);
  static const Color cardYellow = Color(0xFFFBBF24);
  static const Color cardPink   = Color(0xFFF472B6);
  static const Color cardGreen  = Color(0xFF34D399);
  static const Color cardIndigo = Color(0xFF818CF8);
  static const Color cardRed    = Color(0xFFF87171);

  // =========================================================================
  // THEME DATA
  // =========================================================================
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: bg,
      primaryColor: brand,
      fontFamily: 'Bai Jamjuree',
      splashColor: brand.withValues(alpha: 0.05),
      highlightColor: brand.withValues(alpha: 0.03),
      hoverColor: brand.withValues(alpha: 0.04),
      dividerColor: divider,
      visualDensity: VisualDensity.compact,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Bai Jamjuree',
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 22),
      ),
      dividerTheme: DividerThemeData(
        color: divider.withValues(alpha: 0.8),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceRaised,
        modalBarrierColor: Color(0x99000000),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android:  AppPageTransitionsBuilder(),
          TargetPlatform.iOS:      AppPageTransitionsBuilder(),
          TargetPlatform.macOS:    AppPageTransitionsBuilder(),
          TargetPlatform.windows:  AppPageTransitionsBuilder(),
          TargetPlatform.linux:    AppPageTransitionsBuilder(),
          TargetPlatform.fuchsia:  AppPageTransitionsBuilder(),
        },
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        minLeadingWidth: 0,
        iconColor: textSecondary,
        textColor: textPrimary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: brand,
        labelColor: brand,
        unselectedLabelColor: textSecondary,
        labelStyle: TextStyle(
          fontFamily: 'Bai Jamjuree',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Bai Jamjuree',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: brand,
        onPrimary: bg,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
        secondary: textSecondary,
        onSecondary: Colors.white,
      ),
    );
  }

  // =========================================================================
  // EDITORIAL TEXT STYLES
  // Convenience getters for consistent editorial typography.
  // =========================================================================

  /// Large cinematic hero title.
  static TextStyle heroTitle({Color color = textPrimary}) => TextStyle(
        fontFamily: 'Bai Jamjuree',
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.8,
        height: 1.05,
      );

  /// Medium section heading.
  static TextStyle sectionHeading({Color color = textPrimary}) =>
      TextStyle(
        fontFamily: 'Bai Jamjuree',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.3,
        height: 1.2,
      );

  /// Refined overline / category label.
  static TextStyle overline({Color color = textTertiary}) => TextStyle(
        fontFamily: 'Bai Jamjuree',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2.0,
      );

  /// Editorial caption — small metadata text.
  static TextStyle caption({Color color = textSecondary}) => TextStyle(
        fontFamily: 'Bai Jamjuree',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.2,
        height: 1.45,
      );
}