import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Named, pre-built [TextStyle] constants for the CIRO design system.
///
/// Premium SF Pro / Inter-inspired typography hierarchy for command-center UI.
///
/// Every style is context-aware via the [of] factory — it resolves the
/// correct colour from the active theme's brightness.
///
/// Typography scale:
/// ┌──────────────┬────────┬────────┬───────────────┬─────────────────────┐
/// │ Role         │ Size   │ Weight │ Tracking      │ Usage                │
/// ├──────────────┼────────┼────────┼───────────────┼─────────────────────┤
/// │ displayLarge │ 36 sp  │ 700    │ -0.5          │ Hero numbers, splash │
/// │ display      │ 32 sp  │ 700    │ -0.5          │ Alert counts, stats  │
/// │ headline     │ 28 sp  │ 600    │ -0.3          │ Section titles       │
/// │ title        │ 20 sp  │ 600    │ -0.2          │ Card headers         │
/// │ titleMedium  │ 16 sp  │ 500    │ 0.1           │ Sub-headers          │
/// │ body         │ 15 sp  │ 400    │ 0             │ General content      │
/// │ bodyLarge    │ 16 sp  │ 400    │ 0             │ Report text, dialogs │
/// │ bodySmall    │ 13 sp  │ 400    │ 0             │ Supporting text      │
/// │ label        │ 12 sp  │ 500    │ 1.2 uppercase │ Badges, timestamps   │
/// │ labelTiny    │ 11 sp  │ 500    │ 0.5           │ Status chips, meta   │
/// │ caption      │ 11 sp  │ 400    │ 0.3           │ Captions, footers    │
/// │ mono         │ 13 sp  │ 500    │ 0.5           │ Codes, IDs, coords   │
/// └──────────────┴────────┴────────┴───────────────┴─────────────────────┘
abstract final class CiroTextStyles {
  CiroTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════
  // CONTEXT-AWARE FACTORY
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

  /// 36 sp / w700 — hero display on dark background.
  static final TextStyle displayLargeOnDark = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: CiroColors.dark.onBackground,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// 32 sp / w700 — for splash screen hero text and large numeric displays.
  static final TextStyle displayOnDark = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: CiroColors.dark.onBackground,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 28 sp / w600 — section titles on a dark background.
  static final TextStyle headlineOnDark = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: CiroColors.dark.onBackground,
    letterSpacing: -0.3,
    height: 1.25,
  );

  /// 20 sp / w600 — card headers on dark.
  static final TextStyle titleOnDark = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: CiroColors.dark.onBackground,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// 15 sp / w400 — body text on dark background.
  static final TextStyle bodyOnDark = GoogleFonts.inter(
    fontSize: 15,
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

  /// 12 sp / w500 — badges, labels, timestamps on dark (uppercase).
  static final TextStyle labelOnDark = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: CiroColors.dark.onSurface,
    letterSpacing: 1.2,
  );

  // ── Splash-specific styles (white only, never theme-switched) ──────────

  /// "CIRO" splash title — 40 sp / w700 / pure white.
  static final TextStyle splashTitle = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 3.0,
    height: 1.1,
  );

  /// Splash subtitle line — 14 sp / w400 / subtle white.
  static final TextStyle splashSubtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white.withAlpha(178),
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// "Powered by …" footer — 11 sp / w400 / very dim white.
  static final TextStyle splashFooter = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.white.withAlpha(102),
    letterSpacing: 0.3,
  );

  // ── Report button card (sits on gradient) ─────────────────────────────

  /// Hero report button main label — 20 sp / w600 / white.
  static final TextStyle reportButtonLabel = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Hero report button subtitle — 13 sp / w400 / white 75%.
  static final TextStyle reportButtonSubtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white.withAlpha(191),
    height: 1.5,
  );

  // ── Severity badge text (always on a tinted background) ───────────────

  /// Severity badge label — 10 sp / w700 / white — tight tracking.
  static final TextStyle severityBadge = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.0,
    height: 1.0,
  );

  // ── Monospaced (report IDs, coordinates, timestamps) ──────────────────

  /// 13 sp / w500 / JetBrains Mono — report codes, lat/lng, IDs.
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
// RESOLVED STYLE SET
// Instantiated by CiroTextStyles.of(context) with live colour tokens.
// ═══════════════════════════════════════════════════════════════════════════

final class CiroTextStyleSet {
  const CiroTextStyleSet({required this.colors});

  final CiroColorScheme colors;

  // ── Display Large — 36 sp / w700 ───────────────────────────────────────
  /// Largest display — hero numbers, big stats.
  TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
        letterSpacing: -0.5,
        height: 1.15,
      );

  // ── Display — 32 sp / w700 ─────────────────────────────────────────────
  /// Large hero text — alert counts, splash numbers.
  TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // ── Headline — 28 sp / w600 ────────────────────────────────────────────
  /// Screen-level section title (e.g. "Recent Alerts").
  TextStyle get headline => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
        letterSpacing: -0.3,
        height: 1.25,
      );

  // ── Title — 20 sp / w600 ──────────────────────────────────────────────
  /// Card title, AppBar heading.
  TextStyle get title => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
        letterSpacing: -0.2,
        height: 1.3,
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

  // ── Body — 15 sp / w400 ───────────────────────────────────────────────
  /// General content, list items, form values.
  TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
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

  // ── Label — 12 sp / w500 / uppercase ──────────────────────────────────
  /// Timestamps, area names, metadata chips.
  TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
        letterSpacing: 1.2,
      );

  // ── Label Tiny — 11 sp / w500 ─────────────────────────────────────────
  /// Status chips, tab labels, very small identifiers.
  TextStyle get labelTiny => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
        letterSpacing: 0.5,
      );

  // ── Caption — 11 sp / w400 ────────────────────────────────────────────
  /// Footers, image captions, hint text.
  TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
        letterSpacing: 0.3,
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
