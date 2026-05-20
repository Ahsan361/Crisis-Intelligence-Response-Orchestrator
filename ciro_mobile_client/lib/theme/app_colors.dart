import 'package:flutter/material.dart';

/// All colour tokens for the CIRO design system.
///
/// Premium emergency command-center palette.
/// Dark futuristic aesthetic with refined severity colors,
/// glassmorphism tokens, glow helpers, and gradient presets.
///
/// Usage:
///   CiroColors.dark.primary          → info blue
///   CiroColors.dark.background       → deep navy #060B14
///   CiroColors.forSeverity('critical') → #FF4D5E
///
/// Never use raw hex literals in widgets — always reference this class.
abstract final class CiroColors {
  // ─── Private constructor — pure static class ───────────────────────────
  CiroColors._();

  // ═══════════════════════════════════════════════════════════════════════
  // DARK THEME TOKENS (primary — command center)
  // ═══════════════════════════════════════════════════════════════════════
  static const CiroColorScheme dark = CiroColorScheme(
    background: Color(0xFF060B14),
    surface: Color(0xFF0E1623),
    surfaceVariant: Color(0xFF131D2E),
    primary: Color(0xFF4DA3FF),
    primaryContainer: Color(0xFF1A3052),
    secondary: Color(0xFF3DDC97),
    error: Color(0xFFFF4D5E),
    warning: Color(0xFFFFC857),
    onBackground: Color(0xFFF5F7FA),
    onSurface: Color(0xFF9AA4B2),
    divider: Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
  );

  // ═══════════════════════════════════════════════════════════════════════
  // LIGHT THEME TOKENS (kept for compatibility — dark-first design)
  // ═══════════════════════════════════════════════════════════════════════
  static const CiroColorScheme light = CiroColorScheme(
    background: Color(0xFFF0F2F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE8ECF1),
    primary: Color(0xFF2B7FE0),
    primaryContainer: Color(0xFFDCEAFC),
    secondary: Color(0xFF1A9A6B),
    error: Color(0xFFD93848),
    warning: Color(0xFFB8941E),
    onBackground: Color(0xFF111827),
    onSurface: Color(0xFF4B5563),
    divider: Color(0xFFE5E7EB),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // SEVERITY COLOUR SYSTEM — refined emergency palette
  // ═══════════════════════════════════════════════════════════════════════
  static const Color severityCritical = Color(0xFFFF4D5E);
  static const Color severityHigh = Color(0xFFFFC857);
  static const Color severityMedium = Color(0xFF4DA3FF);
  static const Color severityLow = Color(0xFF3DDC97);
  static const Color severityUnknown = Color(0xFF6B7280);

  /// Returns the severity colour for a given [severity] string.
  /// Accepted values (case-insensitive): critical, high, medium, low.
  /// Falls back to [severityUnknown] for any unrecognised value.
  static Color forSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return severityCritical;
      case 'high':
        return severityHigh;
      case 'medium':
        return severityMedium;
      case 'low':
        return severityLow;
      default:
        return severityUnknown;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SEMANTIC ALIASES
  // ═══════════════════════════════════════════════════════════════════════
  static const Color danger = severityCritical;
  static const Color alert = severityHigh;
  static const Color info = severityMedium;
  static const Color safe = severityLow;

  // ═══════════════════════════════════════════════════════════════════════
  // AI ACCENT — purple for AI-powered elements
  // ═══════════════════════════════════════════════════════════════════════
  static const Color aiAccent = Color(0xFFB26BFF);
  static const Color aiAccentDim = Color(0xFF7C3AED);

  // ═══════════════════════════════════════════════════════════════════════
  // MUTED TEXT
  // ═══════════════════════════════════════════════════════════════════════
  static const Color textMuted = Color(0xFF4B5563);

  // ═══════════════════════════════════════════════════════════════════════
  // GLASSMORPHISM TOKENS
  // ═══════════════════════════════════════════════════════════════════════
  static const Color glassWhite = Color(0x0AFFFFFF); // 4%
  static const Color glassBorder = Color(0x0FFFFFFF); // 6%
  static const Color glassHighlight = Color(0x14FFFFFF); // 8%

  // ═══════════════════════════════════════════════════════════════════════
  // GLOW COLOURS (soft ambient glows for active states)
  // ═══════════════════════════════════════════════════════════════════════
  static Color glowRed = const Color(0xFFFF4D5E).withAlpha(60);
  static Color glowAmber = const Color(0xFFFFC857).withAlpha(50);
  static Color glowGreen = const Color(0xFF3DDC97).withAlpha(50);
  static Color glowBlue = const Color(0xFF4DA3FF).withAlpha(50);
  static Color glowPurple = const Color(0xFFB26BFF).withAlpha(50);

  /// Returns a glow color for the given severity.
  static Color glowForSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return glowRed;
      case 'high':
        return glowAmber;
      case 'medium':
        return glowBlue;
      case 'low':
        return glowGreen;
      default:
        return const Color(0x1A6B7280);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GRADIENT PRESETS
  // ═══════════════════════════════════════════════════════════════════════

  /// Emergency red gradient for CTA buttons.
  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF4D5E),
      Color(0xFFD93848),
    ],
  );

  /// Primary blue gradient for report buttons.
  static const LinearGradient reportButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4DA3FF),
      Color(0xFF1A3052),
    ],
  );

  /// Subtle header gradient (radial background glow).
  static const RadialGradient headerGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [
      Color(0x1A4DA3FF),
      Color(0x00060B14),
    ],
  );

  /// Card subtle gradient overlay.
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x08FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  /// Glow shadow for the hero report button.
  static List<BoxShadow> reportButtonGlow = [
    BoxShadow(
      color: const Color(0xFF4DA3FF).withAlpha(90),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  /// Emergency button glow.
  static List<BoxShadow> emergencyButtonGlow = [
    BoxShadow(
      color: const Color(0xFFFF4D5E).withAlpha(80),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // STATUS DOT COLOURS (system status banner)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color statusOperational = Color(0xFF3DDC97);
  static const Color statusCrisis = Color(0xFFFF4D5E);
  static const Color statusDegraded = Color(0xFFFFC857);

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER — resolve scheme from current BuildContext brightness
  // ═══════════════════════════════════════════════════════════════════════
  static CiroColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOUR SCHEME VALUE OBJECT
// Immutable data class that holds one complete set of theme colour tokens.
// ═══════════════════════════════════════════════════════════════════════════
@immutable
final class CiroColorScheme {
  const CiroColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.error,
    required this.warning,
    required this.onBackground,
    required this.onSurface,
    required this.divider,
  });

  /// Page scaffold background — #060B14.
  final Color background;

  /// Card / sheet / dialog surface — #0E1623.
  final Color surface;

  /// Elevated surface — #131D2E.
  final Color surfaceVariant;

  /// Brand blue — interactive elements, links, active indicators.
  final Color primary;

  /// Tinted container behind primary elements.
  final Color primaryContainer;

  /// Positive / safe green.
  final Color secondary;

  /// Destructive / critical — emergency red.
  final Color error;

  /// High-severity / warning amber.
  final Color warning;

  /// Primary text on [background] — #F5F7FA.
  final Color onBackground;

  /// Secondary text on [surface] — #9AA4B2.
  final Color onSurface;

  /// Separator lines, card outlines — thin and subtle.
  final Color divider;
}
