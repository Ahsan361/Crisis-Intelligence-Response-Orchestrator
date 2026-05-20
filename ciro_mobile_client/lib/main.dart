import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — one-handed use under stress.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status + nav bars; each screen owns its overlay style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Edge-to-edge so the splash background fills notch / punch-hole area.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    const ProviderScope(
      child: CiroApp(),
    ),
  );
}

// ROOT APPLICATION WIDGET

class CiroApp extends ConsumerWidget {
  const CiroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // ── Identity ──────────────────────────────────────────────────────
      title: 'CIRO — Crisis Intelligence & Response Orchestrator',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────────
      theme: CiroTheme.light,
      darkTheme: CiroTheme.dark,
      themeMode: themeMode,

      // ── Router ────────────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Accessibility ─────────────────────────────────────────────────
      // Clamp text scale so crisis cards and severity badges never overflow.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.30,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
