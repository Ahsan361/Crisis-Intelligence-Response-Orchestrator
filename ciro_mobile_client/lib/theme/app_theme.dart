import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds and exposes the two [ThemeData] objects (dark + light) for CIRO.
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
          ? const Color(0xFF1A3D22)
          : const Color(0xFFD8EFDE),
      onSecondaryContainer: c.onBackground,
      // Tertiary (mapped to warning for Material 3 compatibility)
      tertiary: c.warning,
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: isDark
          ? const Color(0xFF3D2F00)
          : const Color(0xFFFFF3CD),
      onTertiaryContainer: c.onBackground,
      // Error
      error: c.error,
      onError: const Color(0xFFFFFFFF),
      errorContainer: isDark
          ? const Color(0xFF3D0B09)
          : const Color(0xFFFFDAD6),
      onErrorContainer: c.onBackground,
      // Surface
      surface: c.surface,
      onSurface: c.onBackground,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.onSurface,
      // Outline
      outline: c.divider,
      outlineVariant: c.divider.withValues(alpha: 0.5),
      // Scaffold / background
      shadow: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
      scrim: Colors.black.withValues(alpha: isDark ? 0.7 : 0.3),
      inverseSurface: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF161B22),
      onInverseSurface: isDark ? const Color(0xFF0D1117) : const Color(0xFFE6EDF3),
      inversePrimary: isDark ? const Color(0xFF0969DA) : const Color(0xFF2F81F7),
    );

    // ── Inter text theme via google_fonts ───────────────────────────────
    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        // Display — 32sp / w700
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: c.onBackground,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: c.onBackground,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: c.onBackground,
          height: 1.25,
        ),
        // Headline — 24sp / w600
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          height: 1.35,
        ),
        // Title — 18sp / w600
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.onBackground,
          height: 1.35,
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
        // Body — 14sp / w400
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: c.onBackground,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
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
        // Label — 12sp / w500
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
          letterSpacing: 0.5,
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
            systemNavigationBarColor: c.surface,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: c.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    // ════════════════════════════════════════════════════════════════════
    // COMPONENT THEMES
    // ════════════════════════════════════════════════════════════════════

    // ── AppBar ──────────────────────────────────────────────────────────
    final appBarTheme = AppBarTheme(
      backgroundColor: c.surface,
      foregroundColor: c.onBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: c.onBackground,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: c.onBackground, size: 24),
      actionsIconTheme: IconThemeData(color: c.onSurface, size: 24),
      systemOverlayStyle: systemOverlayStyle,
      shape: Border(
        bottom: BorderSide(color: c.divider, width: 1),
      ),
    );

    // ── Bottom Navigation Bar ───────────────────────────────────────────
    final bottomNavBarTheme = BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      selectedItemColor: c.primary,
      unselectedItemColor: c.onSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    );

    // ── NavigationBar (Material 3) ──────────────────────────────────────
    final navigationBarTheme = NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primaryContainer,
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
      color: c.surface,
      shadowColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    );

    // ── ElevatedButton ──────────────────────────────────────────────────
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            return Colors.white.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withValues(alpha: 0.06);
          }
          return Colors.transparent;
        }),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );

    // ── OutlinedButton ──────────────────────────────────────────────────
    final outlinedButtonTheme = OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        foregroundColor: WidgetStatePropertyAll(c.primary),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: c.divider);
          }
          return BorderSide(color: c.primary);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.primary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.primary.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
        elevation: const WidgetStatePropertyAll(0),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
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
            return c.primary.withValues(alpha: 0.10);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    // ── Chip ────────────────────────────────────────────────────────────
    final chipTheme = ChipThemeData(
      backgroundColor: c.surfaceVariant,
      selectedColor: c.primaryContainer,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      fillColor: c.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.divider, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
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
      backgroundColor: isDark
          ? const Color(0xFF2D333B)
          : const Color(0xFF24292F),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFE6EDF3),
      ),
      actionTextColor: c.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    );

    // ── Dialog ──────────────────────────────────────────────────────────
    final dialogTheme = DialogThemeData(
      backgroundColor: c.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.divider, width: 1),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: c.onBackground,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
    );

    // ── ProgressIndicator ───────────────────────────────────────────────
    final progressIndicatorTheme = ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceVariant,
      circularTrackColor: c.surfaceVariant,
      linearMinHeight: 4,
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
      selectedTileColor: c.primaryContainer,
      iconColor: c.onSurface,
      textColor: c.onBackground,
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c.onSurface,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: c.onBackground,
      ),
      minLeadingWidth: 24,
      minTileHeight: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );

    // ── Tooltip ─────────────────────────────────────────────────────────
    final tooltipTheme = TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D333B) : const Color(0xFF1F2328),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFE6EDF3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      waitDuration: const Duration(milliseconds: 500),
    );

    // ── IconButton ──────────────────────────────────────────────────────
    final iconButtonTheme = IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        iconSize: const WidgetStatePropertyAll(24),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.onSurface.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.onSurface.withValues(alpha: 0.06);
          }
          return Colors.transparent;
        }),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
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
      splashFactory: InkRipple.splashFactory,

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
      iconTheme: IconThemeData(color: c.onBackground, size: 24),
      primaryIconTheme: IconThemeData(color: c.primary, size: 24),

      // Ink / ripple
      highlightColor: c.onSurface.withValues(alpha: 0.06),
      splashColor: c.primary.withValues(alpha: 0.10),
      hoverColor: c.onSurface.withValues(alpha: 0.04),

      // Deprecated surface fields kept for widget back-compat
      // ignore: deprecated_member_use
      dialogBackgroundColor: c.surface,
    );
  }
}
