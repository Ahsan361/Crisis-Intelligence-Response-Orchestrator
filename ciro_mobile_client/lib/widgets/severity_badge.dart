import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SEVERITY BADGE
//
// Compact premium pill that communicates crisis severity at a glance.
// Glassmorphism-inspired with subtle glow matching severity color.
//
// Sizes:
//   SeverityBadge(severity: 'critical')          → standard (card use)
//   SeverityBadge.large(severity: 'critical')    → detail screen header
//   SeverityBadge.dot(severity: 'critical')      → list indicator dot only
// ═══════════════════════════════════════════════════════════════════════════

enum _BadgeSize { standard, large, dot }

class SeverityBadge extends StatelessWidget {
  const SeverityBadge({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.standard;

  /// Large variant — used on the Report Detail screen header.
  const SeverityBadge.large({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.large;

  /// Dot-only variant — used in dense list rows where space is tight.
  const SeverityBadge.dot({
    super.key,
    required this.severity,
  }) : _size = _BadgeSize.dot;

  final String severity;
  final _BadgeSize _size;

  @override
  Widget build(BuildContext context) {
    final color = CiroColors.forSeverity(severity);
    final label = _formatLabel(severity);

    // Dot-only variant
    if (_size == _BadgeSize.dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    final isLarge = _size == _BadgeSize.large;
    final horizontalPad = isLarge ? 14.0 : 10.0;
    final verticalPad = isLarge ? 6.0 : 4.0;
    final fontSize = isLarge ? 11.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        // Glass-like tinted background
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
          height: 1.0,
        ),
      ),
    );
  }

  String _formatLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'CRITICAL';
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'low':
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }
}
