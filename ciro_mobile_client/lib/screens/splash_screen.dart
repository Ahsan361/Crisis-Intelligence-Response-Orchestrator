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
    ref.listen<AsyncValue<void>>(splashTimerProvider, (_, next) {
      next.whenData((_) {
        if (context.mounted) {
          context.goNamed(CiroRoutes.landingName);
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: cityscape background ─────────────────────────────
          const _SplashBackground(),

          // ── Layer 2: premium gradient overlay ─────────────────────────
          const _DarkOverlay(),

          // ── Layer 3: radial glow accent ───────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 0.8,
                  colors: [
                    Color(0x1A4DA3FF),
                    Color(0x00060B14),
                  ],
                ),
              ),
            ),
          ),

          // ── Layer 4: content column ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const _ShieldLogo(),
                const SizedBox(height: 32),
                const _CiroWordmark(),
                const SizedBox(height: 12),
                const _Tagline(),
                const Spacer(flex: 4),
                const _LoadingBar(),
                const SizedBox(height: 32),
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
// ═══════════════════════════════════════════════════════════════════════════

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/splash_bg.png',
      fit: BoxFit.cover,
      semanticLabel: '',
      excludeFromSemantics: true,
    );
  }
}

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
            const Color(0xFF060B14).withAlpha(140),
            const Color(0xFF060B14).withAlpha(200),
            const Color(0xFF060B14).withAlpha(240),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _ShieldLogo extends StatelessWidget {
  const _ShieldLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ciro_shield.png',
      width: 110,
      height: 110,
      fit: BoxFit.contain,
      semanticLabel: 'CIRO shield logo',
    )
        .animate()
        .fadeIn(duration: 700.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1.0, 1.0),
          duration: 700.ms,
          curve: Curves.easeOut,
        )
        .then(delay: 300.ms)
        .shimmer(
          duration: 2000.ms,
          color: const Color(0xFF4DA3FF).withAlpha(50),
          angle: 0.0,
        );
  }
}

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
        .fadeIn(delay: 700.ms, duration: 450.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.2,
          end: 0.0,
          delay: 700.ms,
          duration: 450.ms,
          curve: Curves.easeOut,
        );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white.withAlpha(15),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF4DA3FF),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 400.ms);
  }
}

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
        .fadeIn(delay: 1100.ms, duration: 600.ms, curve: Curves.easeIn);
  }
}
