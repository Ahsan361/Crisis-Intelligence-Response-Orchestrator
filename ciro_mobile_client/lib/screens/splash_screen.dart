import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER — splash navigation timer
final splashTimerProvider = FutureProvider<void>((ref) async {
  await Future.delayed(_kSplashDuration);
});

const Duration _kSplashDuration = Duration(milliseconds: 3000);

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Navigation trigger ───────────────────────────────────────────────
    // ref.listen fires outside build — safe to call context.goNamed here.
    ref.listen<AsyncValue<void>>(splashTimerProvider, (_, next) {
      next.whenData((_) {
        if (context.mounted) {
          context.goNamed(CiroRoutes.landingName);
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: cityscape background ─────────────────────────────
          const _SplashBackground(),

          // ── Layer 2: dark gradient overlay ────────────────────────────
          const _DarkOverlay(),

          // ── Layer 3: content column ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Flexible top spacer — pushes logo+text to visual centre.
                const Spacer(flex: 3),

                // ── Shield logo ────────────────────────────────────────
                const _ShieldLogo(),

                const SizedBox(height: 28),

                // ── "CIRO" wordmark ────────────────────────────────────
                const _CiroWordmark(),

                const SizedBox(height: 10),

                // ── Tagline ────────────────────────────────────────────
                const _Tagline(),

                const Spacer(flex: 4),

                // ── Footer ─────────────────────────────────────────────
                const _PoweredByFooter(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE SUB-WIDGETS
// Decomposed so each piece has a single animation responsibility.
// ═══════════════════════════════════════════════════════════════════════════

// ── Background image ────────────────────────────────────────────────────────

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/splash_bg.png',
      fit: BoxFit.cover,
      // Semantic label — screen readers shouldn't announce decorative art.
      semanticLabel: '',
      excludeFromSemantics: true,
    );
  }
}

// ── Dark gradient overlay ───────────────────────────────────────────────────

class _DarkOverlay extends StatelessWidget {
  const _DarkOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D1117).withValues(alpha: 0.55),
            const Color(0xFF0D1117).withValues(alpha: 0.75),
            const Color(0xFF0D1117).withValues(alpha: 0.92),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ── Shield logo ─────────────────────────────────────────────────────────────

class _ShieldLogo extends StatelessWidget {
  const _ShieldLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ciro_shield.png',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      semanticLabel: 'CIRO shield logo',
    )
        // 1. Start invisible + 20% smaller
        .animate()
        .fadeIn(
          delay: 0.ms,
          duration: 600.ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.80, 0.80),
          end: const Offset(1.00, 1.00),
          delay: 0.ms,
          duration: 600.ms,
          curve: Curves.easeOut,
        )
        // 2. Subtle breathing pulse after entrance (loops)
        .then(delay: 200.ms)
        .shimmer(
          duration: 1800.ms,
          color: const Color(0xFF2F81F7).withValues(alpha: 0.25),
          angle: 0.0,
        );
  }
}

// ── "CIRO" wordmark ─────────────────────────────────────────────────────────

class _CiroWordmark extends StatelessWidget {
  const _CiroWordmark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'CIRO',
      style: CiroTextStyles.splashTitle,
      semanticsLabel: 'CIRO',
    )
        .animate()
        // Slide up from 18px below + fade in
        .slideY(
          begin: 0.4,
          end: 0.0,
          delay: 400.ms,
          duration: 500.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(
          delay: 400.ms,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Tagline ─────────────────────────────────────────────────────────────────

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Crisis Intelligence & Response Orchestrator',
      style: CiroTextStyles.splashSubtitle,
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(
          delay: 700.ms,   // 400ms (CIRO) + 300ms after
          duration: 450.ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          end: 0.0,
          delay: 700.ms,
          duration: 450.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Footer ──────────────────────────────────────────────────────────────────

class _PoweredByFooter extends StatelessWidget {
  const _PoweredByFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Powered by Google Antigravity',
      style: CiroTextStyles.splashFooter,
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(
          delay: 1100.ms,
          duration: 600.ms,
          curve: Curves.easeIn,
        );
  }
}
