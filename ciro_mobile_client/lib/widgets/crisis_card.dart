import 'package:flutter/material.dart';

import '../models/crisis_alert.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'severity_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS CARD — Premium Intelligence Card
//
// Layered dark surface card with severity color strip, glass icon container,
// AI confidence badge, live timestamp chip, and press-scale animation.
//
// Visual anatomy:
//  ┌─────────────────────────────────────────────────────┐
//  ║ ▌ [icon]  G-10 Markaz      [97%] [CRITICAL badge]  ║
//  ║ 4px       Flash flooding on main boulevard…         ║
//  ║ glow      🕐 12 mins ago  ·  Flood                 ║
//  └─────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

class CrisisCard extends StatefulWidget {
  const CrisisCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final CrisisAlert alert;
  final VoidCallback? onTap;

  @override
  State<CrisisCard> createState() => _CrisisCardState();
}

class _CrisisCardState extends State<CrisisCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = CiroColors.of(context);
    final severityColor = CiroColors.forSeverity(widget.alert.severityKey);
    final glowColor = CiroColors.glowForSeverity(widget.alert.severityKey);

    return Semantics(
      label: _semanticLabel,
      button: widget.onTap != null,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
              border: Border.all(
                color: _isPressed
                    ? severityColor.withAlpha(40)
                    : CiroColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withAlpha(_isPressed ? 40 : 15),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: CiroColors.cardGradient,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CiroTheme.cardRadius),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Severity accent bar (4px with glow) ────────────
                    _SeverityAccentBar(color: severityColor),

                    // ── Card body ─────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top row: icon + area + confidence + badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _CrisisIcon(
                                  iconAsset: widget.alert.iconAsset,
                                  severityColor: severityColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.alert.areaName ?? 'Unknown Area',
                                    style: CiroTextStyles.of(context).title.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // AI confidence badge
                                if (widget.alert.crisisConfidence > 0)
                                  _ConfidenceBadge(
                                    confidence: widget.alert.crisisConfidence,
                                    colors: colors,
                                  ),
                                const SizedBox(width: 8),
                                SeverityBadge(severity: widget.alert.severityKey),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // ── Description ──────────────────────────────
                            Padding(
                              padding: const EdgeInsets.only(left: 48),
                              child: Text(
                                widget.alert.reportText,
                                style: CiroTextStyles.of(context).bodySmall.copyWith(
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Footer: type chip + time chip ────────────
                            Padding(
                              padding: const EdgeInsets.only(left: 48),
                              child: Row(
                                children: [
                                  _TypeChip(
                                    label: widget.alert.crisisType?.displayName ?? 'Unknown',
                                    colors: colors,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusChip(
                                    status: widget.alert.status,
                                    colors: colors,
                                  ),
                                  const Spacer(),
                                  _TimeChip(
                                    timeAgo: widget.alert.timeAgo,
                                    colors: colors,
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
    final area = widget.alert.areaName ?? 'Unknown area';
    final sev = widget.alert.severity?.displayName ?? 'Unknown';
    final type = widget.alert.crisisType?.displayName ?? 'Unknown';
    return '$sev $type in $area. ${widget.alert.timeAgo}. '
        '${widget.alert.reportText}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEVERITY ACCENT BAR — 4px left border with glow
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
          topLeft: Radius.circular(22),
          bottomLeft: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(2, 0),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CRISIS ICON — glass circle with tinted icon
// ═══════════════════════════════════════════════════════════════════════════

class _CrisisIcon extends StatelessWidget {
  const _CrisisIcon({
    required this.iconAsset,
    required this.severityColor,
  });

  final String iconAsset;
  final Color severityColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: severityColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          iconAsset,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          color: severityColor,
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
// AI CONFIDENCE BADGE — small percentage indicator
// ═══════════════════════════════════════════════════════════════════════════

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({
    required this.confidence,
    required this.colors,
  });

  final int confidence;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: CiroColors.aiAccent.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CiroColors.aiAccent.withAlpha(30),
          width: 1,
        ),
      ),
      child: Text(
        '$confidence%',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: CiroColors.aiAccent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPE CHIP — small pill showing crisis category
// ═══════════════════════════════════════════════════════════════════════════

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.colors});
  final String label;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CiroColors.glassBorder, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS CHIP — shows report processing state
// ═══════════════════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.colors});
  final ReportStatus status;
  final CiroColorScheme colors;

  Color get _statusColor {
    switch (status) {
      case ReportStatus.pending:
        return CiroColors.severityMedium;
      case ReportStatus.analyzing:
        return CiroColors.aiAccent;
      case ReportStatus.resolved:
        return CiroColors.severityLow;
      case ReportStatus.simulated:
        return CiroColors.severityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIME CHIP — live timestamp with icon
// ═══════════════════════════════════════════════════════════════════════════

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.timeAgo, required this.colors});
  final String timeAgo;
  final CiroColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 11,
          color: colors.onSurface.withAlpha(150),
        ),
        const SizedBox(width: 4),
        Text(
          timeAgo,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }
}
