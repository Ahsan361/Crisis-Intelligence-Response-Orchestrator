import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/system_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STATUS BANNER
//
// Full-width card displaying the current CIRO system health.
// Shown at the top of the landing page home tab.
//
// Visual anatomy:
//  ┌────────────────────────────────────────────────────────┐
//  │  ● [pulsing dot]  Islamabad Crisis Monitor — …        │
//  │                   All Systems Operational              │
//  └────────────────────────────────────────────────────────┘
//  └── dot colour and pulse behaviour driven by [SystemStatus]
//
// Usage:
//   StatusBanner(status: SystemStatus.operational)
//   StatusBanner(status: ref.watch(systemStatusProvider))
// ═══════════════════════════════════════════════════════════════════════════

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.status});

  final SystemStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);

    return Semantics(
      label: status.semanticLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: status.hasElevatedBackground
              ? status.dotColor.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: status.hasElevatedBackground
                ? status.dotColor.withValues(alpha: 0.35)
                : colors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Pulsing status dot ──────────────────────────────────────
            _StatusDot(status: status),

            const SizedBox(width: 12),

            // ── Text block ──────────────────────────────────────────────
            Expanded(
              child: _StatusText(status: status),
            ),

            // ── Trailing indicator (crisis mode only) ───────────────────
            if (status == SystemStatus.crisis)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  effects: [
                    ScaleEffect(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.15, 1.15),
                      duration: 700.ms,
                      curve: Curves.easeInOut,
                    ),
                  ],
                  child: Icon(
                    status.icon,
                    color: status.dotColor,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS DOT — animated pulsing circle
// ═══════════════════════════════════════════════════════════════════════════

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final SystemStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.dotColor;

    // The outer glow ring + inner dot are stacked.
    final dot = SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring — visible during pulse animation
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.20),
            ),
          ),
          // Inner solid dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!status.shouldPulse) {
      // Operational — gentle steady glow, no urgent animation.
      return Animate(
        onPlay: (controller) => controller.repeat(reverse: true),
        child: dot,
        effects: [
          ScaleEffect(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1.12, 1.12),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
          FadeEffect(
            begin: 0.70,
            end: 1.0,
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
        ],
      );
    }

    // Degraded / crisis — faster, more urgent pulse.
    final pulseDuration =
        status == SystemStatus.crisis ? 600.ms : 1000.ms;

    return Animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      child: dot,
      effects: [
        ScaleEffect(
          begin: const Offset(0.80, 0.80),
          end: const Offset(1.20, 1.20),
          duration: pulseDuration,
          curve: Curves.easeInOut,
        ),
        FadeEffect(
          begin: 0.60,
          end: 1.0,
          duration: pulseDuration,
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS TEXT — label + message lines
// ═══════════════════════════════════════════════════════════════════════════

class _StatusText extends StatelessWidget {
  const _StatusText({required this.status});

  final SystemStatus status;

  @override
  Widget build(BuildContext context) {
    final ts = CiroTextStyles.of(context);

    // Split the banner message into the prefix and the status portion.
    // "Islamabad Crisis Monitor — All Systems Operational"
    const prefix = 'Islamabad Crisis Monitor';
    final suffix = switch (status) {
      SystemStatus.operational => 'All Systems Operational',
      SystemStatus.degraded => 'High Alerts Detected',
      SystemStatus.crisis => 'CRISIS MODE ACTIVE',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefix,
          style: ts.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: ts.bodySmall.copyWith(
            color: status.textColor,
            fontWeight: FontWeight.w600,
          ),
          child: Text(
            suffix,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
