import 'package:flutter/material.dart';

/// All colour tokens for the CIRO design system.
///
/// Usage:
///   CiroColors.dark.primary          → 0xFF2F81F7  (dark theme primary)
///   CiroColors.light.background      → 0xFFF6F8FA  (light theme background)
///   CiroColors.severity(Severity.critical) → 0xFFF85149
///
/// Never use raw hex literals in widgets — always reference this class.
abstract final class CiroColors {
  // ─── Private constructor — pure static class ───────────────────────────
  CiroColors._();

  // ═══════════════════════════════════════════════════════════════════════
  // DARK THEME TOKENS
  // ═══════════════════════════════════════════════════════════════════════
  static const CiroColorScheme dark = CiroColorScheme(
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceVariant: Color(0xFF21262D),
    primary: Color(0xFF2F81F7),
    primaryContainer: Color(0xFF1A3A5C),
    secondary: Color(0xFF3FB950),
    error: Color(0xFFF85149),
    warning: Color(0xFFE3B341),
    onBackground: Color(0xFFE6EDF3),
    onSurface: Color(0xFF8B949E),
    divider: Color(0xFF30363D),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // LIGHT THEME TOKENS
  // ═══════════════════════════════════════════════════════════════════════
  static const CiroColorScheme light = CiroColorScheme(
    background: Color(0xFFF6F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEAEEF2),
    primary: Color(0xFF0969DA),
    primaryContainer: Color(0xFFDDF4FF),
    secondary: Color(0xFF1A7F37),
    error: Color(0xFFCF222E),
    warning: Color(0xFF9A6700),
    onBackground: Color(0xFF1F2328),
    onSurface: Color(0xFF636C76),
    divider: Color(0xFFD0D7DE),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // SEVERITY COLOUR SYSTEM
  // These are theme-independent — the same vivid colours on both themes.
  // ═══════════════════════════════════════════════════════════════════════
  static const Color severityCritical = Color(0xFFF85149);
  static const Color severityHigh = Color(0xFFE3B341);
  static const Color severityMedium = Color(0xFF2F81F7);
  static const Color severityLow = Color(0xFF3FB950);
  static const Color severityUnknown = Color(0xFF8B949E);

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
  // SEMANTIC ALIASES (convenience — map to severity tokens)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color danger = severityCritical;
  static const Color alert = severityHigh;
  static const Color info = severityMedium;
  static const Color safe = severityLow;

  // ═══════════════════════════════════════════════════════════════════════
  // HERO REPORT BUTTON GRADIENT
  // Used on the landing page CTA card.
  // ═══════════════════════════════════════════════════════════════════════
  static const LinearGradient reportButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2F81F7), // primary blue
      Color(0xFF1A3A5C), // primary container deep blue
    ],
    stops: [0.0, 1.0],
  );

  /// Glow shadow for the hero report button (blue ambient).
  static List<BoxShadow> reportButtonGlow = [
    BoxShadow(
      color: const Color(0xFF2F81F7).withValues(alpha: 0.45),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // STATUS DOT COLOURS (system status banner)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color statusOperational = Color(0xFF3FB950);
  static const Color statusCrisis = Color(0xFFF85149);
  static const Color statusDegraded = Color(0xFFE3B341);

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

  /// Page scaffold background.
  final Color background;

  /// Card / sheet / dialog surface.
  final Color surface;

  /// Slightly elevated surface — used for chips, input fills, etc.
  final Color surfaceVariant;

  /// Brand blue — interactive elements, links, active indicators.
  final Color primary;

  /// Tinted container behind primary elements (subtle highlight).
  final Color primaryContainer;

  /// Positive / go colour — secondary actions, success states.
  final Color secondary;

  /// Destructive / critical state colour.
  final Color error;

  /// High-severity / warning state colour.
  final Color warning;

  /// Text / icons on [background].
  final Color onBackground;

  /// Secondary text / icons on [surface] — captions, metadata.
  final Color onSurface;

  /// Separator lines, card outlines.
  final Color divider;
}
