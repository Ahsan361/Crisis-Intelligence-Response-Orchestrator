import 'package:flutter/material.dart';

import '../models/crisis_alert.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'severity_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS CARD
//
// Displays a single [CrisisAlert] row in the "Recent Alerts" list.
//
// Visual anatomy:
//  ┌─────────────────────────────────────────────────────┐
//  ║ ▌ [icon]  G-10 Markaz              [CRITICAL badge] ║
//  ║ 4px       Flash flooding on main boulevard…         ║
//  ║ accent    🕐 12 mins ago                            ║
//  └─────────────────────────────────────────────────────┘
//   └── left border colour = CiroColors.forSeverity(alert.severityKey)
//
// Usage:
//   CrisisCard(alert: alert)
//   CrisisCard(alert: alert, onTap: () => context.go(...))
// ═══════════════════════════════════════════════════════════════════════════

class CrisisCard extends StatelessWidget {
  const CrisisCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final CrisisAlert alert;

  /// Optional tap handler — navigates to the alert detail screen.
  /// When null the card is still tappable (ripple) but no action fires.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final severityColor = CiroColors.forSeverity(alert.severityKey);

    return Semantics(
      label: _semanticLabel,
      button: onTap != null,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: severityColor.withValues(alpha: 0.08),
          highlightColor: severityColor.withValues(alpha: 0.04),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Severity accent bar (4px) ──────────────────────
                    _SeverityAccentBar(color: severityColor),

                    // ── Card body ──────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top row: icon + area name + badge ──────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CrisisIcon(
                                  iconAsset: alert.iconAsset,
                                  severityColor: severityColor,
                                  colors: colors,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              alert.areaName ?? 'Unknown Area',
                                              style: CiroTextStyles.of(context)
                                                  .titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SeverityBadge(
                                            severity: alert.severityKey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // ── Description ────────────────────────────
                            Padding(
                              padding: const EdgeInsets.only(left: 38),
                              child: Text(
                                alert.reportText,
                                style: CiroTextStyles.of(context).bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── Footer row: type chip + time ago ───────
                            Padding(
                              padding: const EdgeInsets.only(left: 38),
                              child: Row(
                                children: [
                                  // Crisis type chip
                                  _TypeChip(
                                    label: alert.crisisType?.displayName ?? 'Unknown',
                                    colors: colors,
                                  ),
                                  const Spacer(),
                                  // Time ago
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: colors.onSurface,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        alert.timeAgo,
                                        style: CiroTextStyles.of(context)
                                            .label,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _semanticLabel {
    final area = alert.areaName ?? 'Unknown area';
    final sev = alert.severity?.displayName ?? 'Unknown';
    final type = alert.crisisType?.displayName ?? 'Unknown';
    return '$sev $type in $area. ${alert.timeAgo}. '
        '${alert.reportText}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEVERITY ACCENT BAR — 4px left border strip
// ═══════════════════════════════════════════════════════════════════════════

class _SeverityAccentBar extends StatelessWidget {
  const _SeverityAccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS ICON — tinted square with local asset icon
// ═══════════════════════════════════════════════════════════════════════════

class _CrisisIcon extends StatelessWidget {
  const _CrisisIcon({
    required this.iconAsset,
    required this.severityColor,
    required this.colors,
  });

  final String iconAsset;
  final Color severityColor;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          iconAsset,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          color: severityColor,
          // If the icon asset is missing during development, show a fallback.
          errorBuilder: (_, __, ___) => Icon(
            Icons.warning_rounded,
            size: 20,
            color: severityColor,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPE CHIP — small pill showing the crisis category name
// ═══════════════════════════════════════════════════════════════════════════

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.colors,
  });

  final String label;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: CiroTextStyles.of(context).labelTiny.copyWith(
              color: colors.onSurface,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
