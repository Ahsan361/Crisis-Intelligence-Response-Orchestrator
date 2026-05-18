import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Named, pre-built [TextStyle] constants for the CIRO design system.
///
/// Every style is context-aware via the [of] factory — it resolves the
/// correct colour from the active theme's brightness:
///
/// ```dart
/// Text('CIRO', style: CiroTextStyles.of(context).display)
/// ```
///
/// Static constants (theme-independent) are also available when you need
/// a fixed colour (e.g., inside a coloured container):
///
/// ```dart
/// Text('Critical', style: CiroTextStyles.displayOnDark)
/// ```
///
/// Typography scale (from design spec):
/// ┌─────────────┬────────┬────────┬─────────────────────┐
/// │ Role        │ Size   │ Weight │ Usage                │
/// ├─────────────┼────────┼────────┼─────────────────────┤
/// │ display     │ 32 sp  │ 700    │ Hero numbers, splash │
/// │ headline    │ 24 sp  │ 600    │ Section titles       │
/// │ title       │ 18 sp  │ 600    │ Card headers, AppBar │
/// │ titleMedium │ 16 sp  │ 500    │ Sub-headers          │
/// │ body        │ 14 sp  │ 400    │ General content      │
/// │ bodyLarge   │ 16 sp  │ 400    │ Report text, dialogs │
/// │ bodySmall   │ 13 sp  │ 400    │ Supporting text      │
/// │ label       │ 12 sp  │ 500    │ Badges, timestamps   │
/// │ labelTiny   │ 11 sp  │ 500    │ Status chips, meta   │
/// │ caption     │ 12 sp  │ 400    │ Captions, footers    │
/// │ mono        │ 13 sp  │ 500    │ Codes, IDs, coords   │
/// └─────────────┴────────┴────────┴─────────────────────┘
abstract final class CiroTextStyles {
  CiroTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════
  // CONTEXT-AWARE FACTORY
  // Returns a [_CiroTextStyleSet] resolved for the current theme brightness.
  // ═══════════════════════════════════════════════════════════════════════

  /// Returns the full style set resolved against the current [BuildContext]
  /// theme brightness. Preferred usage for all widgets.
  static CiroTextStyleSet of(BuildContext context) {
    final c = CiroColors.of(context);
    return CiroTextStyleSet(colors: c);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STATIC DARK-THEME STYLES
  // Use these only inside containers with a fixed dark background
  // (e.g., splash screen, report button gradient card).
  // ═══════════════════════════════════════════════════════════════════════

  /// 32 sp / w700 — for splash screen hero text and large numeric displays.
  static final TextStyle displayOnDark = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: CiroColors.dark.onBackground,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 24 sp / w600 — section titles on a dark background.
  static final TextStyle headlineOnDark = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: CiroColors.dark.onBackground,
    height: 1.3,
  );

  /// 18 sp / w600 — card headers and AppBar titles on dark.
  static final TextStyle titleOnDark = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CiroColors.dark.onBackground,
    height: 1.35,
  );

  /// 14 sp / w400 — body text on dark background.
  static final TextStyle bodyOnDark = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CiroColors.dark.onBackground,
    height: 1.5,
  );

  /// 13 sp / w400 — secondary body text / subtitles on dark.
  static final TextStyle bodySmallOnDark = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: CiroColors.dark.onSurface,
    height: 1.5,
  );

  /// 12 sp / w500 — badges, labels, timestamps on dark.
  static final TextStyle labelOnDark = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: CiroColors.dark.onSurface,
    letterSpacing: 0.5,
  );

  // ── Splash-specific styles (white only, never theme-switched) ──────────

  /// "CIRO" splash title — 36 sp / w700 / pure white.
  static final TextStyle splashTitle = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.5,
    height: 1.1,
  );

  /// Splash subtitle line — 13 sp / w400 / subtle white.
  static final TextStyle splashSubtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.70),
    letterSpacing: 0.2,
    height: 1.5,
  );

  /// "Powered by …" footer — 11 sp / w400 / very dim white.
  static final TextStyle splashFooter = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.40),
    letterSpacing: 0.3,
  );

  // ── Report button card (sits on primary-blue gradient) ─────────────────

  /// Hero report button main label — 20 sp / w600 / white.
  static final TextStyle reportButtonLabel = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
  );

  /// Hero report button subtitle — 13 sp / w400 / white 75%.
  static final TextStyle reportButtonSubtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.75),
    height: 1.5,
  );

  // ── Severity badge text (always on a tinted background) ───────────────

  /// Severity badge label — 11 sp / w600 / white — tight tracking.
  static final TextStyle severityBadge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.8,
    height: 1.0,
  );

  // ── Monospaced (report IDs, coordinates, timestamps) ──────────────────

  /// 13 sp / w500 / JetBrains Mono fallback — report codes, lat/lng, IDs.
  static final TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: CiroColors.dark.onBackground,
    letterSpacing: 0.5,
  );

  /// Monospaced on dark background variant.
  static final TextStyle monoOnDark = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: CiroColors.dark.onBackground,
    letterSpacing: 0.5,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE RESOLVED STYLE SET
// Instantiated by CiroTextStyles.of(context) with live colour tokens.
// ═══════════════════════════════════════════════════════════════════════════

final class CiroTextStyleSet {
  const CiroTextStyleSet({required this.colors});

  final CiroColorScheme colors;

  // ── Display — 32 sp / w700 ─────────────────────────────────────────────
  /// Large hero text — splash numbers, alert counts.
  TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // ── Headline — 24 sp / w600 ────────────────────────────────────────────
  /// Screen-level section title (e.g. "Recent Alerts").
  TextStyle get headline => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
        height: 1.3,
      );

  // ── Title — 18 sp / w600 ──────────────────────────────────────────────
  /// Card title, AppBar heading.
  TextStyle get title => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
        height: 1.35,
      );

  // ── Title Medium — 16 sp / w500 ────────────────────────────────────────
  /// Sub-section headings, dialog titles.
  TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ── Body Large — 16 sp / w400 ──────────────────────────────────────────
  /// Report descriptions, dialog body.
  TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.onBackground,
        height: 1.55,
      );

  // ── Body — 14 sp / w400 ───────────────────────────────────────────────
  /// General content, list items, form values.
  TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.onBackground,
        height: 1.5,
      );

  // ── Body Small — 13 sp / w400 ─────────────────────────────────────────
  /// Supporting / secondary text under primary content.
  TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
        height: 1.5,
      );

  // ── Label — 12 sp / w500 ──────────────────────────────────────────────
  /// Timestamps, area names, metadata chips.
  TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
        letterSpacing: 0.5,
      );

  // ── Label Tiny — 11 sp / w500 ─────────────────────────────────────────
  /// Status chips, tab labels, very small identifiers.
  TextStyle get labelTiny => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
        letterSpacing: 0.5,
      );

  // ── Caption — 12 sp / w400 ────────────────────────────────────────────
  /// Footers, image captions, hint text.
  TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
        height: 1.5,
      );

  // ── Section Header — 12 sp / w600 / uppercase ─────────────────────────
  /// ALL-CAPS section dividers ("RECENT ALERTS", "RESPONDERS").
  TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
        letterSpacing: 1.2,
        height: 1.0,
      );

  // ── Primary-coloured variants ──────────────────────────────────────────

  /// 14 sp / w500 / primary colour — "View All" links, active nav labels.
  TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.primary,
        height: 1.5,
      );

  /// 12 sp / w500 / primary colour — small inline links.
  TextStyle get linkSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.primary,
        letterSpacing: 0.2,
      );

  // ── Status-coloured variants ───────────────────────────────────────────

  /// 14 sp / w500 / error colour — inline error messages.
  TextStyle get error => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.error,
        height: 1.4,
      );

  /// 14 sp / w500 / secondary (green) — success / operational messages.
  TextStyle get success => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.secondary,
        height: 1.4,
      );

  /// 14 sp / w500 / warning colour — cautionary inline text.
  TextStyle get warning => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.warning,
        height: 1.4,
      );

  // ── Monospaced ─────────────────────────────────────────────────────────

  /// 13 sp / w500 / JetBrains Mono — report IDs, coordinates, raw codes.
  TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.onBackground,
        letterSpacing: 0.5,
      );

  // ── Convenience copyWith helpers ───────────────────────────────────────

  /// Returns [body] with a custom [color] override — useful for severity text.
  TextStyle bodyColored(Color color) => body.copyWith(color: color);

  /// Returns [label] with a custom [color] override.
  TextStyle labelColored(Color color) => label.copyWith(color: color);

  /// Returns [title] with a custom [color] override.
  TextStyle titleColored(Color color) => title.copyWith(color: color);
}
