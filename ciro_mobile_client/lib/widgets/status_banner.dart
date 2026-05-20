import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/system_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'animated_pulse.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STATUS BANNER — Dynamic gradient header with live city status
//
// Premium glassmorphism banner showing CIRO system operational status.
// Features animated pulse dot for active crisis/degraded states,
// gradient background, and glass overlay.
// ═══════════════════════════════════════════════════════════════════════════

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.status,
  });

  final SystemStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final ts = CiroTextStyles.of(context);
    final statusColor = status.dotColor;

    return Semantics(
      label: status.semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withAlpha(30),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor.withAlpha(12),
                  statusColor.withAlpha(5),
                ],
              ),
            ),
            child: Row(
              children: [
                // ── Animated status indicator ──────────────────────────
                AnimatedPulse(
                  color: statusColor,
                  size: 10,
                  showRing: status.shouldPulse,
                ),
                const SizedBox(width: 12),

                // ── Status text ────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISLAMABAD CRISIS MONITOR',
                        style: ts.label.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface.withAlpha(150),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        status.label,
                        style: ts.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status icon ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    status.icon,
                    color: statusColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
