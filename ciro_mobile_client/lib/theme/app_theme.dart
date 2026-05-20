import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds and exposes the two [ThemeData] objects (dark + light) for CIRO.
///
/// Premium command-center theme with glassmorphism support, elevated corners,
/// and refined component styles matching the emergency palette.
///
/// Usage in [MaterialApp] / [MaterialApp.router]:
/// ```dart
/// MaterialApp.router(
///   theme:      CiroTheme.light,
///   darkTheme:  CiroTheme.dark,
///   themeMode:  ThemeMode.dark,   // default to dark
/// )
/// ```
abstract final class CiroTheme {
  CiroTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // PUBLIC ENTRY POINTS
  // ═══════════════════════════════════════════════════════════════════════

  static final ThemeData dark = _build(isDark: true);
  static final ThemeData light = _build(isDark: false);

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════

  /// Global corner radius for cards, sheets, dialogs.
  static const double cardRadius = 22.0;
  /// Smaller radius for chips, badges, input fields.
  static const double chipRadius = 12.0;
  /// Large radius for bottom sheets, modals.
  static const double sheetRadius = 28.0;
  /// Button corner radius.
  static const double buttonRadius = 14.0;

  // ═══════════════════════════════════════════════════════════════════════
  // BUILDER
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData _build({required bool isDark}) {
    final c = isDark ? CiroColors.dark : CiroColors.light;

    // ── Base ColorScheme ────────────────────────────────────────────────
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      // Primary
      primary: c.primary,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onBackground,
      // Secondary
      secondary: c.secondary,
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: isDark
          ? const Color(0xFF0F2A1B)
          : const Color(0xFFD8EFDE),
      onSecondaryContainer: c.onBackground,
      // Tertiary (mapped to warning)
      tertiary: c.warning,
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: isDark
          ? const Color(0xFF2D2200)
          : const Color(0xFFFFF3CD),
      onTertiaryContainer: c.onBackground,
      // Error
      error: c.error,
      onError: const Color(0xFFFFFFFF),
      errorContainer: isDark
          ? const Color(0xFF2D0A0E)
          : const Color(0xFFFFDAD6),
      onErrorContainer: c.onBackground,
      // Surface
      surface: c.surface,
      onSurface: c.onBackground,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.onSurface,
      // Outline
      outline: c.divider,
      outlineVariant: isDark
          ? const Color(0x08FFFFFF)
          : c.divider.withAlpha(128),
      // Scaffold / background
      shadow: Colors.black.withAlpha(isDark ? 153 : 38),
      scrim: Colors.black.withAlpha(isDark ? 178 : 76),
      inverseSurface: isDark ? const Color(0xFFF5F7FA) : const Color(0xFF0E1623),
      onInverseSurface: isDark ? const Color(0xFF060B14) : const Color(0xFFF5F7FA),
      inversePrimary: isDark ? const Color(0xFF2B7FE0) : const Color(0xFF4DA3FF),
    );

    // ── Inter text theme via google_fonts ───────────────────────────────
    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        // Display — 36sp / w700
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: c.onBackground,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: c.onBackground,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        // Headline — 28sp / w600
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          height: 1.35,
        ),
        // Title — 20sp / w600
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: c.onBackground,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: c.onBackground,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        // Body — 15sp / w400
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: c.onBackground,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: c.onBackground,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: c.onSurface,
          height: 1.5,
        ),
        // Label — 12sp / w500 / uppercase
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: c.onBackground,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: c.onSurface,
          letterSpacing: 1.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: c.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );

    // ── System overlay (status bar) ─────────────────────────────────────
    final systemOverlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    // ════════════════════════════════════════════════════════════════════
    // COMPONENT THEMES
    // ════════════════════════════════════════════════════════════════════

    // ── AppBar ──────────────────────────────────────────────────────────
    final appBarTheme = AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: c.onBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: c.onBackground,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: c.onBackground, size: 22),
      actionsIconTheme: IconThemeData(color: c.onSurface, size: 22),
      systemOverlayStyle: systemOverlayStyle,
    );

    // ── Bottom Navigation Bar ───────────────────────────────────────────
    final bottomNavBarTheme = BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: c.primary,
      unselectedItemColor: c.onSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );

    // ── NavigationBar (Material 3) ──────────────────────────────────────
    final navigationBarTheme = NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: c.primary.withAlpha(30),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primary, size: 24);
        }
        return IconThemeData(color: c.onSurface, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c.primary,
          );
        }
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: c.onSurface,
        );
      }),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
    );

    // ── Card ────────────────────────────────────────────────────────────
    final cardTheme = CardThemeData(
      color: c.surfaceVariant,
      shadowColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: c.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    );

    // ── ElevatedButton ──────────────────────────────────────────────────
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.surfaceVariant;
          }
          return c.primary;
        }),
        foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withAlpha(30);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withAlpha(15);
          }
          return Colors.transparent;
        }),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );

    // ── OutlinedButton ──────────────────────────────────────────────────
    final outlinedButtonTheme = OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        foregroundColor: WidgetStatePropertyAll(c.primary),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: c.divider);
          }
          return BorderSide(color: c.primary.withAlpha(128));
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.primary.withAlpha(25);
          }
          return Colors.transparent;
        }),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );

    // ── TextButton ──────────────────────────────────────────────────────
    final textButtonTheme = TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        foregroundColor: WidgetStatePropertyAll(c.primary),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.primary.withAlpha(25);
          }
          return Colors.transparent;
        }),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // ── FloatingActionButton ────────────────────────────────────────────
    final fabTheme = FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    // ── Chip ────────────────────────────────────────────────────────────
    final chipTheme = ChipThemeData(
      backgroundColor: c.surfaceVariant,
      selectedColor: c.primary.withAlpha(40),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: c.onBackground,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: c.primary,
      ),
      side: BorderSide(color: c.divider, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(chipRadius)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      pressElevation: 0,
    );

    // ── Divider ─────────────────────────────────────────────────────────
    final dividerTheme = DividerThemeData(
      color: c.divider,
      thickness: 1,
      space: 1,
    );

    // ── InputDecoration (TextField) ─────────────────────────────────────
    final inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceVariant.withAlpha(128),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: BorderSide(color: c.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: BorderSide(color: c.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: BorderSide(color: c.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: c.onSurface.withAlpha(128),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: c.primary,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c.error,
      ),
    );

    // ── SnackBar ────────────────────────────────────────────────────────
    final snackBarTheme = SnackBarThemeData(
      backgroundColor: c.surfaceVariant,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.onBackground,
      ),
      actionTextColor: c.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(chipRadius)),
      elevation: 0,
    );

    // ── Dialog ──────────────────────────────────────────────────────────
    final dialogTheme = DialogThemeData(
      backgroundColor: c.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: c.divider, width: 1),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: c.onBackground,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
    );

    // ── ProgressIndicator ───────────────────────────────────────────────
    final progressIndicatorTheme = ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceVariant,
      circularTrackColor: c.surfaceVariant,
      linearMinHeight: 3,
    );

    // ── Switch ──────────────────────────────────────────────────────────
    final switchTheme = SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return c.onSurface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.primary;
        return c.surfaceVariant;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return c.divider;
      }),
    );

    // ── ListTile ────────────────────────────────────────────────────────
    final listTileTheme = ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: c.primary.withAlpha(20),
      iconColor: c.onSurface,
      textColor: c.onBackground,
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: c.onBackground,
      ),
      minLeadingWidth: 24,
      minTileHeight: 52,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );

    // ── Tooltip ─────────────────────────────────────────────────────────
    final tooltipTheme = TooltipThemeData(
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.divider),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c.onBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 500),
    );

    // ── IconButton ──────────────────────────────────────────────────────
    final iconButtonTheme = IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        iconSize: const WidgetStatePropertyAll(22),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.onSurface.withAlpha(30);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.onSurface.withAlpha(15);
          }
          return Colors.transparent;
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(chipRadius),
          ),
        ),
      ),
    );

    // ════════════════════════════════════════════════════════════════════
    // FINAL ThemeData ASSEMBLY
    // ════════════════════════════════════════════════════════════════════
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      splashFactory: InkSplash.splashFactory,

      // Typography
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // Components
      appBarTheme: appBarTheme,
      bottomNavigationBarTheme: bottomNavBarTheme,
      navigationBarTheme: navigationBarTheme,
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      floatingActionButtonTheme: fabTheme,
      chipTheme: chipTheme,
      dividerTheme: dividerTheme,
      inputDecorationTheme: inputDecorationTheme,
      snackBarTheme: snackBarTheme,
      dialogTheme: dialogTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      switchTheme: switchTheme,
      listTileTheme: listTileTheme,
      tooltipTheme: tooltipTheme,
      iconButtonTheme: iconButtonTheme,

      // Global icon theme
      iconTheme: IconThemeData(color: c.onBackground, size: 22),
      primaryIconTheme: IconThemeData(color: c.primary, size: 22),

      // Ink / ripple
      highlightColor: c.onSurface.withAlpha(15),
      splashColor: c.primary.withAlpha(25),
      hoverColor: c.onSurface.withAlpha(10),

      // Deprecated surface fields kept for widget back-compat
      // ignore: deprecated_member_use
      dialogBackgroundColor: c.surface,
    );
  }
}
